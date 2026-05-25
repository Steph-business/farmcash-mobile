import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';

/// Séparateur visuel entre la zone "Détails de la demande" (lecture
/// seule) et la zone "Ma proposition" (formulaire).
///
/// Une ligne fine + un titre en gras pour rendre clair au producteur
/// qu'il passe de la consultation à l'action.
class DemandeProposalDivider extends StatelessWidget {
  const DemandeProposalDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 1,
          color: AppColors.border,
        ),
        const SizedBox(height: AppDimens.space12),
        Text(
          'Ma proposition',
          style: AppTextStyles.titleSmall.copyWith(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.text,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          'Remplis le formulaire pour candidater à cette demande.',
          style: AppTextStyles.bodySmall.copyWith(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
