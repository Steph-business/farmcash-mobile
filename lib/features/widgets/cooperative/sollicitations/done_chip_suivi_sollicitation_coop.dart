import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';

/// Chip neutre (gris pastel + bordure fine) servant d'état terminal
/// non-actionnable à droite des tuiles de réponse. Utilisé pour les
/// états « En attente » ou « Acceptée » (défaut), selon `label`.
class DoneChipSuiviSollicitationCoop extends StatelessWidget {
  const DoneChipSuiviSollicitationCoop({
    this.label = 'Acceptée',
    super.key,
  });

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.surfaceSoft,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppColors.border,
          width: AppDimens.borderThin,
        ),
      ),
      child: Text(
        label,
        style: AppTextStyles.labelSmall.copyWith(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}
