import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../models/payout.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';
import 'chip_statut_payout.dart';
import 'format_montant_fcfa.dart';

/// Bloc Hero affichant les informations principales d'un PayoutBatch :
/// date de creation, nombre de beneficiaires, montant total et chip statut.
class HeroInfoDistribution extends StatelessWidget {
  const HeroInfoDistribution({required this.batch, super.key});

  final PayoutBatch batch;

  @override
  Widget build(BuildContext context) {
    final dateStr = batch.createdAt != null
        ? 'Créé le ${DateFormat('dd/MM/yyyy').format(batch.createdAt!.toLocal())}'
        : 'Date inconnue';
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: AppDimens.brCard,
        border: Border.all(
          color: AppColors.border,
          width: AppDimens.borderThin,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            dateStr,
            style: AppTextStyles.bodySmall.copyWith(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${batch.items.length} bénéficiaire(s)',
            style: AppTextStyles.titleLarge.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${formatMontantFcfa(batch.totalAmount)} F au total',
            style: AppTextStyles.bodySmall.copyWith(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 10),
          ChipStatutPayout(status: batch.status),
        ],
      ),
    );
  }
}
