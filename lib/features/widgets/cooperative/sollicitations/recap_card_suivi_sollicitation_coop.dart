import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';
import 'modele_sollicitation_suivi_coop.dart';

/// Card de récap en haut du suivi sollicitation : nom du produit + quantité
/// cible, statut courant, et badge informatif indiquant le nombre total
/// de destinataires ayant reçu la sollicitation.
class RecapCardSuiviSollicitationCoop extends StatelessWidget {
  const RecapCardSuiviSollicitationCoop({
    required this.produit,
    required this.quantiteCibleKg,
    required this.totalRecipients,
    required this.status,
    super.key,
  });

  final String produit;
  final double quantiteCibleKg;
  final int totalRecipients;
  final String status;

  @override
  Widget build(BuildContext context) {
    final cibleLabel = quantiteCibleKg > 0
        ? '$produit · ${formatKgSollicitationCoop(quantiteCibleKg)} kg'
        : produit;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppDimens.radiusCard),
        border: Border.all(
          color: AppColors.border,
          width: AppDimens.borderThin,
        ),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            cibleLabel,
            style: AppTextStyles.titleLarge.copyWith(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Statut : $status',
            style: AppTextStyles.bodySmall.copyWith(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.surfaceSoft,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.border,
                width: AppDimens.borderThin,
              ),
            ),
            child: Text(
              'Sollicitation envoyée à $totalRecipients destinataire(s)',
              style: AppTextStyles.labelSmall.copyWith(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
