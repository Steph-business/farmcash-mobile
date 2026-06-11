import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../api_client/api_exception.dart';
import '../../../routing/route_names.dart';
import '../../../services/providers.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_dimens.dart';
import '../../../theme/app_text_styles.dart';
import '../../pages/communs/legal/contenu_legal.dart';
import '../../state/auth_state.dart';
import 'snackbars.dart';

/// Provider qui sait si l'utilisateur doit re-accepter les CGU/Privacy.
///
/// Retourne `true` si :
///   - l'utilisateur est authentifié ;
///   - ET la version courante des CGU OU de la Privacy n'est pas la même
///     que celle que l'utilisateur a déjà acceptée.
///
/// `autoDispose` pour laisser le cache se vider quand la page d'accueil
/// se démonte (changement de rôle, logout) ; on relance le check au
/// remount du wrapper.
final consentRequiredProvider =
    FutureProvider.autoDispose<bool>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return false;
  try {
    final legal = ref.read(legalServiceProvider);
    final status = await legal.getConsentStatus();
    final terms = status['terms_accepted_version']?.toString();
    final privacy = status['privacy_accepted_version']?.toString();
    return terms != kCurrentTermsVersion ||
        privacy != kCurrentPrivacyVersion;
  } on ApiException {
    // En cas d'erreur (offline, 500…), on n'embête pas l'utilisateur.
    // Le check sera retenté au prochain lancement.
    return false;
  } catch (_) {
    return false;
  }
});

/// Wrapper à placer autour du contenu des pages d'accueil des 4 rôles.
///
/// Au premier build après le frame, vérifie si un consentement est
/// requis ; si oui, affiche un dialog plein écran NON-dismissible avec
/// les 2 checkboxes (CGU + Privacy). Une fois accepté, l'événement est
/// enregistré côté backend et le dialog se ferme.
///
/// Le wrapper ne touche pas au rendu du `child` — il se contente
/// d'orchestrer le dialog.
class BandeauConsentementWrapper extends ConsumerStatefulWidget {
  /// Construit le wrapper.
  const BandeauConsentementWrapper({required this.child, super.key});

  /// Contenu de la page (généralement l'AccueilPage du rôle).
  final Widget child;

  @override
  ConsumerState<BandeauConsentementWrapper> createState() =>
      _BandeauConsentementWrapperState();
}

class _BandeauConsentementWrapperState
    extends ConsumerState<BandeauConsentementWrapper> {
  bool _dialogShown = false;

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(consentRequiredProvider);
    async.whenData((needed) {
      if (needed && !_dialogShown) {
        _dialogShown = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          _afficherDialogConsentement();
        });
      }
    });
    return widget.child;
  }

  Future<void> _afficherDialogConsentement() async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const _DialogConsentement(),
    );
    // Réessaie le provider au cas où l'utilisateur a accepté (devrait
    // retourner false ensuite et ne plus déclencher le dialog).
    if (mounted) {
      ref.invalidate(consentRequiredProvider);
    }
  }
}

/// Dialog plein-écran modal bloquant pour la première acceptation des
/// CGU + Politique de Confidentialité.
class _DialogConsentement extends ConsumerStatefulWidget {
  const _DialogConsentement();

  @override
  ConsumerState<_DialogConsentement> createState() =>
      _DialogConsentementState();
}

class _DialogConsentementState
    extends ConsumerState<_DialogConsentement> {
  bool _acceptCgu = false;
  bool _acceptPrivacy = false;
  bool _submitting = false;

  Future<void> _onAccepter() async {
    setState(() => _submitting = true);
    try {
      final legal = ref.read(legalServiceProvider);
      await legal.recordConsent(
        termsVersion: kCurrentTermsVersion,
        privacyVersion: kCurrentPrivacyVersion,
      );
      if (!mounted) return;
      Navigator.of(context).pop();
    } on ApiException catch (e) {
      if (!mounted) return;
      Snackbars.showErreur(context, e.message);
    } catch (e) {
      if (!mounted) return;
      Snackbars.showErreurInattendue(context, e);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ready = _acceptCgu && _acceptPrivacy;

    // PopScope.canPop=false → ferme le back natif Android pour
    // garantir le caractère bloquant.
    return PopScope(
      canPop: false,
      child: Dialog(
        backgroundColor: AppColors.background,
        insetPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 32,
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: AppDimens.brCard,
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.10),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.verified_user_outlined,
                    color: AppColors.primary,
                    size: 28,
                  ),
                ),
              ),
              AppDimens.vGap16,
              Text(
                'Bienvenue sur FarmCash',
                textAlign: TextAlign.center,
                style: AppTextStyles.titleMedium.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              AppDimens.vGap8,
              Text(
                'Avant de continuer, on a besoin de ton accord sur nos '
                'conditions et notre politique de confidentialité.',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
              AppDimens.vGap24,
              _CaseConsentement(
                checked: _acceptCgu,
                onChanged: (v) => setState(() => _acceptCgu = v),
                children: [
                  TextSpan(
                    text: "J'accepte les ",
                    style: AppTextStyles.bodyMedium,
                  ),
                  _SpanLien(
                    label: 'Conditions Générales d\'Utilisation',
                    onTap: () => context.push(
                      RouteNames.documentLegalPathFor(LegalDocType.cgu),
                    ),
                  ),
                ],
              ),
              AppDimens.vGap12,
              _CaseConsentement(
                checked: _acceptPrivacy,
                onChanged: (v) => setState(() => _acceptPrivacy = v),
                children: [
                  TextSpan(
                    text: "J'accepte la ",
                    style: AppTextStyles.bodyMedium,
                  ),
                  _SpanLien(
                    label: 'Politique de Confidentialité',
                    onTap: () => context.push(
                      RouteNames.documentLegalPathFor(LegalDocType.privacy),
                    ),
                  ),
                ],
              ),
              AppDimens.vGap24,
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: ready && !_submitting ? _onAccepter : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.onPrimary,
                    disabledBackgroundColor: AppColors.borderStrong,
                    disabledForegroundColor: AppColors.textSubtle,
                    elevation: 0,
                    shape: const RoundedRectangleBorder(
                      borderRadius: AppDimens.brButton,
                    ),
                  ),
                  child: _submitting
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.4,
                            color: AppColors.onPrimary,
                          ),
                        )
                      : const Text(
                          'J\'accepte et je continue',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
              ),
              AppDimens.vGap12,
              Text(
                'Tu peux toujours retrouver ces documents dans '
                'Profil → Légal et confidentialité.',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSubtle,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CaseConsentement extends StatelessWidget {
  const _CaseConsentement({
    required this.checked,
    required this.onChanged,
    required this.children,
  });

  final bool checked;
  final ValueChanged<bool> onChanged;
  final List<InlineSpan> children;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onChanged(!checked),
      borderRadius: AppDimens.brInput,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 24,
              height: 24,
              child: Checkbox(
                value: checked,
                onChanged: (v) => onChanged(v ?? false),
                visualDensity: VisualDensity.compact,
                materialTapTargetSize:
                    MaterialTapTargetSize.shrinkWrap,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
                activeColor: AppColors.primary,
              ),
            ),
            AppDimens.hGap12,
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text.rich(
                  TextSpan(children: children),
                  style: AppTextStyles.bodyMedium,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SpanLien extends TextSpan {
  _SpanLien({required String label, required VoidCallback onTap})
      : super(
          text: label,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w700,
            decoration: TextDecoration.underline,
          ),
          recognizer: _buildRecognizer(onTap),
        );
}

// Helper externe car les TextSpan const n'autorisent pas la création
// inline d'un TapGestureRecognizer.
GestureRecognizer _buildRecognizer(VoidCallback onTap) {
  final r = TapGestureRecognizer();
  r.onTap = onTap;
  return r;
}
