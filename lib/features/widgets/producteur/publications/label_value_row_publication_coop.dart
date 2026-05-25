import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_text_styles.dart';

/// Ligne label gauche + valeur droite. Variante `highlight` : la valeur
/// est en titleLarge primaire (mise en avant — quantite/membre, total).
class LabelValueRowPublicationCoop extends StatelessWidget {
  const LabelValueRowPublicationCoop({
    required this.label,
    required this.value,
    required this.highlight,
    super.key,
  });

  final String label;
  final String value;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: AppTextStyles.bodyMedium.copyWith(
              fontSize: 13,
              color: highlight ? AppColors.text : AppColors.textSecondary,
              fontWeight: highlight ? FontWeight.w500 : FontWeight.w400,
            ),
          ),
        ),
        Text(
          value,
          style: highlight
              ? AppTextStyles.titleLarge.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                  letterSpacing: -0.2,
                )
              : AppTextStyles.titleSmall.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
        ),
      ],
    );
  }
}
