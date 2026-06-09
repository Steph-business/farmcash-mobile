import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../api_client/api_exception.dart';
import '../../../models/membre_coop.dart';
import '../../../services/providers.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_dimens.dart';
import '../../../theme/app_text_styles.dart';
import '../../widgets/communs/snackbars.dart';
import '../../widgets/cooperative/membres/bouton_envoyer_invitation.dart';
import '../../widgets/cooperative/membres/carte_info_invitation.dart';
import '../../widgets/cooperative/membres/carte_invitation_historique.dart';
import '../../widgets/cooperative/membres/champ_message_invitation.dart';
import '../../widgets/cooperative/membres/champ_telephone_invitation.dart';
import '../../widgets/cooperative/membres/entete_inviter_farmer.dart';
import '../../widgets/cooperative/membres/etat_vide_invitations.dart';
import '../../widgets/cooperative/membres/libelle_champ_invitation.dart';

/// Charge l'historique des invitations envoyées par la coop.
///
/// ⚠️ Fix 2026-06-06 : utilisait `listMyInvitations` qui est l'endpoint
/// FARMER (invitations REÇUES) → 403 Forbidden côté coop. Le bon
/// endpoint est `listSentInvitations` (`GET /coop/invitations/sent`).
final _invitationsProvider =
    FutureProvider.autoDispose<List<CoopInvitation>>((ref) async {
  return ref.read(cooperativesServiceProvider).listSentInvitations();
});

/// Page Inviter un farmer — SMS d'invitation via l'endpoint `coopInvitations`.
class InviterFarmerPage extends ConsumerStatefulWidget {
  const InviterFarmerPage({super.key});

  @override
  ConsumerState<InviterFarmerPage> createState() => _InviterFarmerPageState();
}

class _InviterFarmerPageState extends ConsumerState<InviterFarmerPage> {
  final _telCtrl = TextEditingController();
  final _messageCtrl = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _telCtrl.dispose();
    _messageCtrl.dispose();
    super.dispose();
  }

  Future<void> _envoyer() async {
    if (_busy) return;
    final raw = _telCtrl.text.trim();
    if (raw.isEmpty) {
      Snackbars.showErreur(context, 'Saisis un numéro de téléphone.');
      return;
    }
    // Normalisation en E.164 : "07 12 34 56 78" → "+22507123456 78"
    var phone = raw.replaceAll(RegExp(r'\s+'), '');
    if (!phone.startsWith('+')) {
      phone = phone.startsWith('00')
          ? '+${phone.substring(2)}'
          : (phone.startsWith('225') ? '+$phone' : '+225$phone');
    }
    setState(() => _busy = true);
    try {
      await ref.read(cooperativesServiceProvider).invite(
            invitedPhone: phone,
            message: _messageCtrl.text.trim().isEmpty
                ? null
                : _messageCtrl.text.trim(),
          );
      if (!mounted) return;
      Snackbars.showSucces(context, 'Invitation envoyée par SMS à $phone.');
      _telCtrl.clear();
      _messageCtrl.clear();
      ref.invalidate(_invitationsProvider);
    } on ApiException catch (e) {
      if (mounted) Snackbars.showErreur(context, e.message);
    } catch (e) {
      if (mounted) Snackbars.showErreurInattendue(context, e);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final asyncInvitations = ref.watch(_invitationsProvider);
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const EnteteInviterFarmer(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppDimens.pagePaddingH,
                  0,
                  AppDimens.pagePaddingH,
                  AppDimens.space16,
                ),
                children: [
                  const CarteInfoInvitation(),
                  const SizedBox(height: 20),
                  const LibelleChampInvitation('Téléphone'),
                  const SizedBox(height: 6),
                  ChampTelephoneInvitation(
                    controller: _telCtrl,
                    enabled: !_busy,
                  ),
                  const SizedBox(height: 14),
                  const LibelleChampInvitation(
                    'Message personnalisé (optionnel)',
                  ),
                  const SizedBox(height: 6),
                  ChampMessageInvitation(
                    controller: _messageCtrl,
                    enabled: !_busy,
                    placeholder:
                        'Ex : Salut, rejoins COOP Lagunes pour vendre au juste prix.',
                  ),
                  const SizedBox(height: 20),
                  BoutonEnvoyerInvitation(
                    label: _busy ? 'Envoi…' : 'Envoyer l\'invitation',
                    busy: _busy,
                    onTap: _busy ? null : _envoyer,
                  ),
                  const SizedBox(height: 28),
                  Text(
                    'Invitations envoyées',
                    style: AppTextStyles.titleSmall.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  asyncInvitations.when(
                    loading: () => const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Center(
                        child: SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                    ),
                    error: (e, _) => Text(
                      'Impossible de charger l\'historique. $e',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.error,
                      ),
                    ),
                    data: (list) {
                      if (list.isEmpty) {
                        return const EtatVideInvitations();
                      }
                      return Column(
                        children: [
                          for (final inv in list)
                            CarteInvitationHistorique(invitation: inv),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
