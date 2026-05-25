import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_text_styles.dart';

/// Récapitulatif court du nombre de membres dans la coopérative.
class ResumeMembres extends StatelessWidget {
  const ResumeMembres({super.key, required this.total});

  /// Nombre total de membres.
  final int total;

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: AppTextStyles.bodySmall.copyWith(
          fontSize: 13,
          color: AppColors.textSecondary,
        ),
        children: [
          TextSpan(
            text: '$total membre${total > 1 ? 's' : ''}',
            style: AppTextStyles.bodySmall.copyWith(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.text,
            ),
          ),
          const TextSpan(text: ' dans la coopérative'),
        ],
      ),
    );
  }
}
