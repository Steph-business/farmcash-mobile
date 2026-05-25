import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../models/shipment_evaluation.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';

const Color _kPrimarySoft = Color(0xFFE8F5E9);

/// Vue lecture seule d'une evaluation deja soumise par l'acheteur
/// (note + commentaire + date).
class VueEvaluationExistanteCommande extends StatelessWidget {
  const VueEvaluationExistanteCommande({
    super.key,
    required this.evaluation,
  });

  final ShipmentEvaluation evaluation;

  @override
  Widget build(BuildContext context) {
    final dateLabel = evaluation.createdAt != null
        ? DateFormat('d MMM yyyy', 'fr_FR')
            .format(evaluation.createdAt!.toLocal())
        : '—';
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppDimens.pagePaddingH,
        12,
        AppDimens.pagePaddingH,
        24,
      ),
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: _kPrimarySoft,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.primary,
              width: AppDimens.borderThin,
            ),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.check_circle,
                color: AppColors.primary,
                size: 22,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Déjà évalué le $dateLabel',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.text,
                  ),
                ),
              ),
            ],
          ),
        ),
        AppDimens.vGap24,
        Text(
          'Votre note',
          style: AppTextStyles.labelMedium.copyWith(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (int i = 1; i <= 5; i++)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Icon(
                  i <= evaluation.note ? Icons.star : Icons.star_border,
                  size: 32,
                  color: i <= evaluation.note
                      ? AppColors.primary
                      : AppColors.textSubtle,
                ),
              ),
          ],
        ),
        if ((evaluation.commentaire ?? '').isNotEmpty) ...[
          AppDimens.vGap24,
          Text(
            'Votre commentaire',
            style: AppTextStyles.labelMedium.copyWith(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.border,
                width: AppDimens.borderThin,
              ),
            ),
            child: Text(
              evaluation.commentaire!,
              style: AppTextStyles.bodyMedium.copyWith(fontSize: 13),
            ),
          ),
        ],
      ],
    );
  }
}
