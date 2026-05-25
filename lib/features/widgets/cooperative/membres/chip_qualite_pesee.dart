import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';

const BorderRadius _kBrChip = BorderRadius.all(Radius.circular(14));

/// Puce de sélection d'une qualité produit (Standard / Premium / Bio /
/// Équitable) dans le formulaire de pesée. Couleur primaire pleine quand
/// active, contour gris sinon.
class ChipQualitePesee extends StatelessWidget {
  const ChipQualitePesee({
    required this.label,
    required this.active,
    required this.onTap,
    super.key,
  });
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: _kBrChip,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: active ? AppColors.primary : AppColors.background,
          borderRadius: _kBrChip,
          border: Border.all(
            color: active ? AppColors.primary : AppColors.borderStrong,
            width: AppDimens.borderThin,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.labelMedium.copyWith(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: active ? AppColors.onPrimary : AppColors.text,
          ),
        ),
      ),
    );
  }
}
