import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../api_client/api_exception.dart';
import '../../../../services/providers.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';
import '../../../state/auth_state.dart';
import '../../../widgets/communs/litige/motifs_litige.dart';
import '../../../widgets/communs/litige/tuile_motif_litige.dart';
import '../../../widgets/communs/profil_settings/entete_profil_settings.dart';
import '../../../widgets/communs/profil_settings/groupe_settings.dart';
import '../../../widgets/communs/profil_settings/titre_section_settings.dart';
import '../../../widgets/communs/snackbars.dart';

/// Page Signaler un problème — dédiée (pas un dialog modal). L'utilisateur
/// choisit un motif prédéfini, peut éventuellement préciser dans un champ
/// libre, et envoie. Crée un Dispute côté backend via
/// `ordersService.openDispute`.
///
/// La page détecte automatiquement le rôle de l'utilisateur courant pour
/// adapter la liste de motifs (acheteur vs vendeur/coop).
///
/// Validation minimale : un motif **doit** être sélectionné. Si "Autre"
/// est choisi, le champ libre doit faire au moins 10 caractères (contrainte
/// backend `OpenDisputeDto.raison` ≥ 10). Sinon les détails sont
/// optionnels.
class SignalerProblemePage extends ConsumerStatefulWidget {
  /// Construit la page Signaler un problème pour la commande [commandeId].
  const SignalerProblemePage({
    required this.commandeId,
    super.key,
  });

  /// ID de la commande concernée par le litige.
  final String commandeId;

  @override
  ConsumerState<SignalerProblemePage> createState() =>
      _SignalerProblemePageState();
}

class _SignalerProblemePageState
    extends ConsumerState<SignalerProblemePage> {
  MotifLitige? _motifSelectionne;
  final _autreCtrl = TextEditingController();
  bool _sending = false;

  @override
  void dispose() {
    _autreCtrl.dispose();
    super.dispose();
  }

  /// Construit la `raison` à envoyer au backend (≥ 10 chars).
  ///
  /// Pour un motif prédéfini → on envoie son label (toujours ≥ 10 chars
  /// vu la longueur de nos libellés). Pour "Autre" → on envoie le texte
  /// libre saisi par l'utilisateur.
  String _construireRaison() {
    final motif = _motifSelectionne!;
    if (motif.code == MotifLitige.autre.code) {
      return _autreCtrl.text.trim();
    }
    return motif.label;
  }

  bool _peutEnvoyer() {
    if (_motifSelectionne == null) return false;
    if (_motifSelectionne!.code == MotifLitige.autre.code) {
      return _autreCtrl.text.trim().length >= 10;
    }
    return true;
  }

  Future<void> _envoyer() async {
    if (!_peutEnvoyer() || _sending) return;
    final raison = _construireRaison();
    if (raison.length < 10) {
      Snackbars.showErreur(
        context,
        'Décris ton problème en au moins 10 caractères.',
      );
      return;
    }
    setState(() => _sending = true);
    try {
      await ref.read(ordersServiceProvider).openDispute(
            commandeId: widget.commandeId,
            raison: raison,
          );
      if (!mounted) return;
      Snackbars.showSucces(
        context,
        'Litige ouvert · le support FarmCash te recontacte sous 24h',
      );
      // Retour à la page précédente avec `true` pour signaler au parent
      // qu'un litige a été créé — il doit invalider son provider pour
      // refléter le nouveau statut DISPUTED côté UI.
      if (context.canPop()) {
        context.pop(true);
      }
    } on ApiException catch (e) {
      if (mounted) Snackbars.showErreur(context, e.message);
    } catch (_) {
      if (mounted) {
        Snackbars.showErreur(
          context,
          'Impossible d\'ouvrir le litige. Réessaie.',
        );
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final role = ref.watch(currentUserProvider)?.role;
    final motifs = motifsPourRole(role);
    final isAutre =
        _motifSelectionne?.code == MotifLitige.autre.code;

    return Scaffold(
      backgroundColor: AppColors.surfaceSoft,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            EnteteProfilSettings(
              fallbackPath: '/',
              titre: 'Signaler un problème',
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppDimens.pagePaddingH,
                  AppDimens.space8,
                  AppDimens.pagePaddingH,
                  AppDimens.space24,
                ),
                children: [
                  // Intro courte
                  Container(
                    padding: const EdgeInsets.all(AppDimens.space16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF3CD),
                      borderRadius: AppDimens.brCard,
                      border: Border.all(
                        color: const Color(0xFFB45309).withValues(alpha: 0.2),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.shield_outlined,
                          size: 20,
                          color: Color(0xFFB45309),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Ton paiement reste protégé en escrow tant que '
                            'le problème n\'est pas résolu. Le support '
                            'FarmCash interviendra sous 24h.',
                            style: AppTextStyles.bodySmall.copyWith(
                              fontSize: 13,
                              color: AppColors.text,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  AppDimens.vGap24,

                  // Liste motifs
                  const TitreSectionSettings('Que se passe-t-il ?'),
                  GroupeSettings(
                    rows: [
                      for (final m in motifs)
                        TuileMotifLitige(
                          label: m.label,
                          selectionne:
                              _motifSelectionne?.code == m.code,
                          onTap: () =>
                              setState(() => _motifSelectionne = m),
                        ),
                    ],
                  ),
                  AppDimens.vGap24,

                  // Champ texte libre — affiché UNIQUEMENT si l'utilisateur
                  // a sélectionné "Autre". Pour tous les autres motifs, le
                  // libellé prédéfini se suffit à lui-même : pas besoin
                  // d'imposer plus de texte au support.
                  if (isAutre) ...[
                    const TitreSectionSettings('Décris ton problème'),
                    TextField(
                      controller: _autreCtrl,
                      enabled: !_sending,
                      maxLines: 5,
                      minLines: 4,
                      maxLength: 1000,
                      onChanged: (_) => setState(() {}),
                      style: AppTextStyles.bodyMedium,
                      decoration: InputDecoration(
                        hintText:
                            'Explique ce qui s\'est passé en quelques lignes…',
                        hintStyle: AppTextStyles.hint,
                        filled: true,
                        fillColor: AppColors.background,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: AppDimens.space12,
                          vertical: 12,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: AppDimens.brInput,
                          borderSide: BorderSide(
                            color: AppColors.borderStrong,
                            width: AppDimens.borderThin,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: AppDimens.brInput,
                          borderSide: const BorderSide(
                            color: AppColors.primary,
                            width: AppDimens.borderMedium,
                          ),
                        ),
                      ),
                    ),
                    AppDimens.vGap16,
                  ],

                  AppDimens.vGap8,

                  // CTA Envoyer
                  FilledButton(
                    onPressed:
                        (_sending || !_peutEnvoyer()) ? null : _envoyer,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.error,
                      foregroundColor: AppColors.onPrimary,
                      disabledBackgroundColor:
                          AppColors.error.withValues(alpha: 0.4),
                      minimumSize:
                          const Size.fromHeight(AppDimens.buttonHeight),
                      shape: RoundedRectangleBorder(
                        borderRadius: AppDimens.brButton,
                      ),
                      textStyle: AppTextStyles.button.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    child: _sending
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: AppColors.onPrimary,
                            ),
                          )
                        : const Text('Envoyer le signalement'),
                  ),
                  AppDimens.vGap8,
                  TextButton(
                    onPressed: _sending
                        ? null
                        : () => context.canPop()
                            ? context.pop()
                            : null,
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.textSecondary,
                      minimumSize:
                          const Size.fromHeight(AppDimens.buttonHeight),
                    ),
                    child: const Text(
                      'Annuler',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
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
