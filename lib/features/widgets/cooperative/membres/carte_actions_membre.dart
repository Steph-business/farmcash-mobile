import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';

const BorderRadius _kBrCard = BorderRadius.all(Radius.circular(14));

/// Carte regroupant les actions disponibles pour la coop sur un membre.
class CarteActionsMembre extends StatelessWidget {
  const CarteActionsMembre({super.key, required this.onVerserAvance});

  /// Action « Verser une avance ».
  final VoidCallback onVerserAvance;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: _kBrCard,
        border: Border.all(
          color: AppColors.border,
          width: AppDimens.borderThin,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: AppColors.primary,
        child: InkWell(
          onTap: onVerserAvance,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12),
            alignment: Alignment.center,
            child: Text(
              'Verser une avance',
              style: AppTextStyles.titleSmall.copyWith(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.onPrimary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
