import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../routing/route_names.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';

/// État vide affiché quand l'acheteur n'a aucune réservation.
class EtatVideReservationsAcheteur extends StatelessWidget {
  const EtatVideReservationsAcheteur({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimens.pagePaddingH),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.event_available_outlined,
              size: 48,
              color: AppColors.textSubtle.withValues(alpha: 0.85),
            ),
            const SizedBox(height: AppDimens.space12),
            Text(
              'Aucune réservation en cours',
              style: AppTextStyles.titleSmall,
            ),
            const SizedBox(height: AppDimens.space8),
            Text(
              'Réserve une part sur une prévision de récolte\ndepuis l\'onglet « Marché » → « Prévisions à venir ».',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: AppDimens.space24),
            InkWell(
              onTap: () => context.go(RouteNames.acheteurMarchePath),
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'Voir les prévisions',
                  style: AppTextStyles.button.copyWith(
                    fontSize: 13,
                    color: AppColors.onPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
