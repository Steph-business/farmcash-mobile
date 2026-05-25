import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';
import 'modele_sollicitation_suivi_coop.dart';

/// Card de progression du remplissage : ligne d'entête (quantité engagée /
/// quantité cible + pourcentage) et barre horizontale qui se remplit
/// proportionnellement à `pct` (valeur dans [0..1]).
class ProgressCardSuiviSollicitationCoop extends StatelessWidget {
  const ProgressCardSuiviSollicitationCoop({
    required this.quantiteOfferteKg,
    required this.quantiteCibleKg,
    required this.pct,
    super.key,
  });

  final double quantiteOfferteKg;
  final double quantiteCibleKg;
  final double pct;

  @override
  Widget build(BuildContext context) {
    final pctLabel = '${(pct * 100).round()}%';
    final mainLabel = quantiteCibleKg > 0
        ? '${formatKgSollicitationCoop(quantiteOfferteKg)} / '
            '${formatKgSollicitationCoop(quantiteCibleKg)} kg engagés'
        : '${formatKgSollicitationCoop(quantiteOfferteKg)} kg engagés';
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
          Row(
            children: [
              Expanded(
                child: Text(
                  mainLabel,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                pctLabel,
                style: AppTextStyles.titleLarge.copyWith(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            height: 16,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: FractionallySizedBox(
                widthFactor: pct,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
