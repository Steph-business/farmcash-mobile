import 'package:flutter/material.dart';

import '../../../../models/traitement.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';
import 'analyse_plante_constants.dart';

/// Carte d'un traitement recommandé suite à une analyse : nom + chip BIO si
/// applicable, puis dosage / mode d'application / description. Les champs
/// vides sont omis pour rester compact.
class TraitementCardAnalyse extends StatelessWidget {
  const TraitementCardAnalyse({required this.traitement, super.key});

  final Traitement traitement;

  @override
  Widget build(BuildContext context) {
    final dosage = traitement.dosage?.trim();
    final mode = traitement.mode?.trim();
    return Container(
      padding: const EdgeInsets.all(AppDimens.space12),
      decoration: BoxDecoration(
        color: AppColors.surface,
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
          Row(
            children: [
              Expanded(
                child: Text(
                  traitement.nom,
                  style: AppTextStyles.titleSmall.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (traitement.isBio) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: kAnalysePlantePrimarySoft,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    'BIO',
                    style: AppTextStyles.labelSmall.copyWith(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ],
          ),
          if (dosage != null && dosage.isNotEmpty) ...[
            AppDimens.vGap4,
            Text(
              'Dosage : $dosage',
              style: AppTextStyles.bodySmall.copyWith(fontSize: 12),
            ),
          ],
          if (mode != null && mode.isNotEmpty) ...[
            AppDimens.vGap4,
            Text(
              'Mode : $mode',
              style: AppTextStyles.bodySmall.copyWith(fontSize: 12),
            ),
          ],
          if (traitement.description != null &&
              traitement.description!.trim().isNotEmpty) ...[
            AppDimens.vGap8,
            Text(
              traitement.description!.trim(),
              style: AppTextStyles.bodyMedium.copyWith(fontSize: 13),
            ),
          ],
        ],
      ),
    );
  }
}
