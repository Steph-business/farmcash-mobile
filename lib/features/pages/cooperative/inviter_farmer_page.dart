import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../api_client/api_exception.dart';
import '../../../models/membre_coop.dart';
import '../../../routing/route_names.dart';
import '../../../services/providers.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_dimens.dart';
import '../../../theme/app_text_styles.dart';
import '../../widgets/communs/snackbars.dart';

const Color _kPrimarySoft = Color(0xFFE8F5E9);
const BorderRadius _kBrInput = BorderRadius.all(Radius.circular(10));
const BorderRadius _kBrCard12 = BorderRadius.all(Radius.circular(12));
const BorderRadius _kBrCard14 = BorderRadius.all(Radius.circular(14));

/// Charge l'historique des invitations envoyées par la coop.
final _invitationsProvider =
    FutureProvider.autoDispose<List<CoopInvitation>>((ref) async {
  return ref.read(cooperativesServiceProvider).listMyInvitations();
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
            phone: phone,
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
      if (mounted) Snackbars.showErreur(context, 'Erreur : $e');
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
            const _Header(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppDimens.pagePaddingH,
                  0,
                  AppDimens.pagePaddingH,
                  AppDimens.space16,
                ),
                children: [
                  const _InfoCard(),
                  const SizedBox(height: 20),
                  const _FieldLabel('Téléphone'),
                  const SizedBox(height: 6),
                  _PhoneInput(controller: _telCtrl, enabled: !_busy),
                  const SizedBox(height: 14),
                  const _FieldLabel('Message personnalisé (optionnel)'),
                  const SizedBox(height: 6),
                  _MultilineInput(
                    controller: _messageCtrl,
                    enabled: !_busy,
                    placeholder:
                        'Ex : Salut, rejoins COOP Lagunes pour vendre au juste prix.',
                  ),
                  const SizedBox(height: 20),
                  _FullButton(
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
                        return _EmptyHistory();
                      }
                      return Column(
                        children: [
                          for (final inv in list) _InvitationCard(invitation: inv),
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

// ─── Header ─────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  const _Header();
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppDimens.pagePaddingH,
        AppDimens.space8,
        AppDimens.pagePaddingH,
        AppDimens.space12,
      ),
      child: Row(
        children: [
          InkWell(
            onTap: () => context.canPop()
                ? context.pop()
                : context.go(RouteNames.cooperativeMembresPath),
            borderRadius: BorderRadius.circular(20),
            child: const SizedBox(
              width: 40,
              height: 40,
              child: Icon(
                Icons.arrow_back_ios_new,
                size: 20,
                color: AppColors.text,
              ),
            ),
          ),
          Expanded(
            child: Text(
              'Inviter un farmer',
              style: AppTextStyles.titleSmall.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.label);
  final String label;
  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: AppTextStyles.labelMedium.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: AppColors.text,
      ),
    );
  }
}

// ─── Info card ─────────────────────────────────────────────────────

class _InfoCard extends StatelessWidget {
  const _InfoCard();
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _kPrimarySoft,
        borderRadius: _kBrCard14,
        border: Border.all(
          color: AppColors.border,
          width: AppDimens.borderThin,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppColors.border,
                width: AppDimens.borderThin,
              ),
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.sms_outlined,
              size: 18,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Le farmer reçoit un SMS avec un lien pour s\'inscrire et rejoindre ta coop. Aucun frais d\'envoi.',
              style: AppTextStyles.bodySmall.copyWith(
                fontSize: 12,
                color: AppColors.text,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PhoneInput extends StatelessWidget {
  const _PhoneInput({required this.controller, required this.enabled});
  final TextEditingController controller;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: _kBrInput,
        border: Border.all(
          color: AppColors.borderStrong,
          width: AppDimens.borderThin,
        ),
      ),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Text(
              '+225',
              style: AppTextStyles.bodyMedium.copyWith(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.text,
              ),
            ),
          ),
          Container(
            width: 1,
            height: 28,
            color: AppColors.border,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              enabled: enabled,
              keyboardType: TextInputType.phone,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9 ]')),
              ],
              style: AppTextStyles.bodyMedium.copyWith(fontSize: 14),
              decoration: InputDecoration(
                hintText: '07 12 34 56 78',
                hintStyle: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSubtle,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 0),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MultilineInput extends StatelessWidget {
  const _MultilineInput({
    required this.controller,
    required this.enabled,
    required this.placeholder,
  });
  final TextEditingController controller;
  final bool enabled;
  final String placeholder;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: _kBrInput,
        border: Border.all(
          color: AppColors.borderStrong,
          width: AppDimens.borderThin,
        ),
      ),
      child: TextField(
        controller: controller,
        enabled: enabled,
        minLines: 3,
        maxLines: 5,
        textCapitalization: TextCapitalization.sentences,
        decoration: InputDecoration(
          hintText: placeholder,
          hintStyle: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSubtle,
          ),
          border: InputBorder.none,
          isDense: true,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        ),
      ),
    );
  }
}

class _FullButton extends StatelessWidget {
  const _FullButton({
    required this.label,
    required this.busy,
    required this.onTap,
  });
  final String label;
  final bool busy;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: _kBrCard12,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: onTap == null ? AppColors.borderStrong : AppColors.primary,
          borderRadius: _kBrCard12,
        ),
        child: busy
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white,
                ),
              )
            : Text(
                label,
                style: AppTextStyles.button.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.onPrimary,
                ),
              ),
      ),
    );
  }
}

class _InvitationCard extends StatelessWidget {
  const _InvitationCard({required this.invitation});
  final CoopInvitation invitation;

  @override
  Widget build(BuildContext context) {
    final df = DateFormat('d MMM y', 'fr_FR');
    final dateLabel = invitation.createdAt != null
        ? df.format(invitation.createdAt!)
        : '—';
    final statutLabel = _statutLabel(invitation.status);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: _kBrCard12,
        border: Border.all(
          color: AppColors.border,
          width: AppDimens.borderThin,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: _kPrimarySoft,
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.send_outlined,
              size: 16,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  invitation.phone,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$statutLabel · $dateLabel',
                  style: AppTextStyles.bodySmall.copyWith(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _statutLabel(String status) {
    switch (status.toUpperCase()) {
      case 'ACCEPTED':
        return 'Acceptée';
      case 'REJECTED':
        return 'Refusée';
      case 'EXPIRED':
        return 'Expirée';
      case 'PENDING':
      default:
        return 'En attente';
    }
  }
}

class _EmptyHistory extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceSoft,
        borderRadius: _kBrCard12,
      ),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.outbox_outlined,
            size: 28,
            color: AppColors.textSubtle,
          ),
          const SizedBox(height: 8),
          Text(
            'Pas d\'invitation envoyée',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
