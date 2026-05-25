import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_text_styles.dart';

/// Ligne label + valeur dans le dialog de detail d'un traitement.
///
/// Le label est en `labelMedium` 12 px gras secondaire, la valeur en
/// `bodyMedium` standard, separes par 2 px verticaux.
class DetailLineCatalogueTraitements extends StatelessWidget {
  const DetailLineCatalogueTraitements({
    required this.label,
    required this.value,
    super.key,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.labelMedium.copyWith(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 2),
        Text(value, style: AppTextStyles.bodyMedium),
      ],
    );
  }
}
