import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_text_styles.dart';

/// Ligne de mini recap (label a gauche, valeur a droite) du bordereau
/// d'enlevement QR. Option `usePoppins` pour les valeurs numeriques.
class RecapRowEnlevement extends StatelessWidget {
  const RecapRowEnlevement({
    required this.label,
    required this.value,
    this.valueColor,
    this.usePoppins = false,
    this.isLast = false,
    super.key,
  });

  final String label;
  final String value;
  final Color? valueColor;
  final bool usePoppins;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: usePoppins
                  ? AppTextStyles.displayLarge.copyWith(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: valueColor ?? AppColors.text,
                    )
                  : AppTextStyles.bodyMedium.copyWith(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: valueColor ?? AppColors.text,
                    ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
