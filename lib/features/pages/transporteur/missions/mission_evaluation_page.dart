import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../routing/route_names.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';
import '../../../widgets/communs/entete_page_standard.dart';

const Color _kPrimarySoft = Color(0xFFE8F5E9);

/// Écran d'évaluation du client après une livraison confirmée.
///
/// **V1 : pas d'endpoint d'évaluation côté backend.** On affiche un
/// état "à venir" honnête plutôt que simuler un succès. Le bouton
/// principal renvoie vers la liste des missions.
class MissionEvaluationPage extends ConsumerWidget {
  const MissionEvaluationPage({required this.missionId, super.key});

  final String missionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Écran terminal post-livraison : le back ramène aux missions
            // (pas de pop vers le scanner/détail intermédiaire).
            EntetePageStandard(
              titre: 'Évaluer le client',
              onBack: () => context.canPop()
                  ? context.pop()
                  : context.go(RouteNames.transporteurMissionsPath),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                    AppDimens.pagePaddingH, 24, AppDimens.pagePaddingH, 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 88,
                      height: 88,
                      decoration: const BoxDecoration(
                        color: _kPrimarySoft,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.star_outline,
                        size: 44,
                        color: AppColors.primary,
                      ),
                    ),
                    AppDimens.vGap16,
                    Text(
                      'Évaluations bientôt disponibles',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.headlineLarge.copyWith(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tu pourras noter tes clients après chaque livraison '
                      'dans une prochaine mise à jour. Ta livraison a bien été '
                      'enregistrée et le paiement est crédité sur ton wallet.',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            _StickyAction(missionId: missionId),
          ],
        ),
      ),
    );
  }
}

class _StickyAction extends StatelessWidget {
  const _StickyAction({required this.missionId});

  final String missionId;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(
          top:
              BorderSide(color: AppColors.border, width: AppDimens.borderThin),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: SizedBox(
        width: double.infinity,
        height: 48,
        child: ElevatedButton(
          onPressed: () =>
              context.go(RouteNames.transporteurMissionsPath),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)),
          ),
          child: Text(
            'Retour aux missions',
            style: AppTextStyles.button.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
