import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../routing/route_names.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';

/// État vide global de l'accueil producteur : affiché quand TOUTES les
/// sections sont vides (pas d'annonces, pas d'offres, pas d'acheteurs,
/// pas de coop, pas d'insights). Encourage à publier une première annonce.
class EtatVide extends StatelessWidget {
  const EtatVide({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppDimens.space32),
      child: Column(
        children: [
          Text(
            'Aucune annonce pour l\'instant',
            style: AppTextStyles.titleMedium.copyWith(
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          AppDimens.vGap8,
          Text(
            'Publiez votre première annonce pour commencer à vendre.',
            style: AppTextStyles.bodySmall,
            textAlign: TextAlign.center,
          ),
          AppDimens.vGap16,
          SizedBox(
            height: AppDimens.buttonHeight,
            child: ElevatedButton(
              onPressed: () => context.push(
                RouteNames.producteurPublierAnnoncePath,
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.onPrimary,
                elevation: 0,
                shape: const RoundedRectangleBorder(
                  borderRadius: AppDimens.brButton,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimens.space24,
                ),
              ),
              child: Text('Publier ma première annonce', style: AppTextStyles.button),
            ),
          ),
        ],
      ),
    );
  }
}
