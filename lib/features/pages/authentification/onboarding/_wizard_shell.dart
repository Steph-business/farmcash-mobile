// =====================================================================
//  Squelette de wizard onboarding partagé entre les 3 rôles (producteur,
//  acheteur, coopérative). Garantit la cohérence visuelle :
//   - progress bar fine en haut + compteur d'étape (« 1/2 », « 2/3 »…)
//   - pas de back button (impossible à esquiver — lien « Se déconnecter »
//     discret en bas comme dans completer_profil_page.dart)
//   - CTA primary sticky bottom avec SafeArea + Material ripple
//   - scroll vertical avec padding clavier pour les TextField
// =====================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../routing/route_names.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';
import '../../../state/auth_state.dart';

/// Shell réutilisable pour les 3 wizards.
///
/// Le contenu de l'étape courante est passé via [child]. Le CTA est rendu
/// par le shell — son label/handler/état viennent du parent.
class OnboardingWizardShell extends ConsumerWidget {
  const OnboardingWizardShell({
    super.key,
    required this.stepIndex,
    required this.stepCount,
    required this.title,
    required this.subtitle,
    required this.child,
    required this.ctaLabel,
    required this.onCta,
    required this.busy,
  });

  /// 0-based — affiché sous forme « ${stepIndex + 1}/${stepCount} ».
  final int stepIndex;
  final int stepCount;
  final String title;
  final String subtitle;
  final Widget child;
  final String ctaLabel;
  final VoidCallback? onCta;
  final bool busy;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = (stepIndex + 1) / stepCount;
    final kbInset = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      backgroundColor: AppColors.background,
      // PopScope true + onPopInvoked vide → bloquer le back natif Android.
      // L'utilisateur DOIT compléter le wizard ou se déconnecter — il ne
      // doit jamais pouvoir revenir en arrière vers une page protégée.
      body: PopScope(
        canPop: false,
        child: SafeArea(
          child: Column(
            children: [
              _Header(
                stepIndex: stepIndex,
                stepCount: stepCount,
                progress: progress,
                busy: busy,
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(20, 16, 20, 24 + kbInset),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        title,
                        style: AppTextStyles.displaySmall.copyWith(
                          fontFamily: 'Poppins',
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: AppColors.text,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        subtitle,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                          height: 1.45,
                        ),
                      ),
                      const SizedBox(height: 24),
                      child,
                    ],
                  ),
                ),
              ),
              _StickyFooter(
                ctaLabel: ctaLabel,
                onCta: onCta,
                busy: busy,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.stepIndex,
    required this.stepCount,
    required this.progress,
    required this.busy,
  });

  final int stepIndex;
  final int stepCount;
  final double progress;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Étape ${stepIndex + 1}/$stepCount',
                style: AppTextStyles.bodySmall.copyWith(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                  letterSpacing: 0.3,
                ),
              ),
              _LogoutLink(busy: busy),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 4,
              backgroundColor: AppColors.surfaceSoft,
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }
}

class _LogoutLink extends ConsumerWidget {
  const _LogoutLink({required this.busy});
  final bool busy;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return InkWell(
      onTap: busy
          ? null
          : () async {
              await ref.read(authStateProvider.notifier).logout();
              if (!context.mounted) return;
              context.go(RouteNames.connexionPath);
            },
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        child: Text(
          'Se déconnecter',
          style: AppTextStyles.bodySmall.copyWith(
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
            decoration: TextDecoration.underline,
            decorationColor: AppColors.textSubtle,
          ),
        ),
      ),
    );
  }
}

class _StickyFooter extends StatelessWidget {
  const _StickyFooter({
    required this.ctaLabel,
    required this.onCta,
    required this.busy,
  });

  final String ctaLabel;
  final VoidCallback? onCta;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 14),
          child: SizedBox(
            height: AppDimens.buttonHeight,
            width: double.infinity,
            child: Material(
              color: onCta == null
                  ? AppColors.primary.withValues(alpha: 0.4)
                  : AppColors.primary,
              borderRadius: AppDimens.brButton,
              child: InkWell(
                borderRadius: AppDimens.brButton,
                onTap: busy ? null : onCta,
                child: Center(
                  child: busy
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.4,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          ctaLabel,
                          style: AppTextStyles.button.copyWith(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
