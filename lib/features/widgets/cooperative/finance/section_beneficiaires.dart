import 'package:flutter/material.dart';

import '../../../../models/payout.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_text_styles.dart';
import 'carte_contributeurs.dart';
import 'format_montant_fcfa.dart';
import 'ligne_total_distribution.dart';

/// Section listant les beneficiaires d'un PayoutBatch avec total.
class SectionBeneficiaires extends StatelessWidget {
  const SectionBeneficiaires({required this.batch, super.key});

  final PayoutBatch batch;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Text(
            'Bénéficiaires',
            style: AppTextStyles.titleSmall.copyWith(
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        if (batch.items.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Text(
              'Aucun bénéficiaire dans ce batch.',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          )
        else ...[
          CarteContributeurs(items: batch.items),
          const SizedBox(height: 10),
          LigneTotalDistribution(
            label: 'Total',
            value: '${formatMontantFcfa(batch.totalAmount)} F',
          ),
        ],
      ],
    );
  }
}
