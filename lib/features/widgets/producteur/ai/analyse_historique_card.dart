import 'package:flutter/material.dart';

import '../../../../models/analyse_plante.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';
import 'analyse_historique_detail_dialog.dart';
import 'analyse_plante_constants.dart';
import 'chip_risque_analyse.dart';

/// Carte d'une analyse dans la page historique : vignette photo (ou icone
/// fallback), titre maladie (ou "Diagnostic en cours"), date, chip risque,
/// chevron. Tap → dialog detail avec image.
class AnalyseHistoriqueCard extends StatelessWidget {
  const AnalyseHistoriqueCard({required this.analyse, super.key});

  final AnalysePlante analyse;

  @override
  Widget build(BuildContext context) {
    final maladie = analyse.diseaseDetected?.trim();
    final titre = (maladie != null && maladie.isNotEmpty)
        ? maladie
        : 'Diagnostic en cours';
    final risk = analyse.riskLevel?.toLowerCase();
    return InkWell(
      onTap: () => showDialog<void>(
        context: context,
        builder: (_) => AnalyseHistoriqueDetailDialog(analyse: analyse),
      ),
      borderRadius: AppDimens.brCard,
      child: Container(
        padding: const EdgeInsets.all(AppDimens.space12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppDimens.brCard,
          border: Border.all(
            color: AppColors.border,
            width: AppDimens.borderThin,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.surfaceSoft,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: AppColors.border,
                  width: AppDimens.borderThin,
                ),
              ),
              clipBehavior: Clip.antiAlias,
              child: analyse.imageUrl.isNotEmpty
                  ? Image.network(
                      analyse.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => const Icon(
                        Icons.image_outlined,
                        color: AppColors.textSubtle,
                        size: 24,
                      ),
                    )
                  : const Icon(
                      Icons.eco_outlined,
                      color: AppColors.textSubtle,
                      size: 24,
                    ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    titre,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    formatAnalyseDate(analyse.createdAt),
                    style: AppTextStyles.bodySmall.copyWith(fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            if (risk != null && risk.isNotEmpty) ChipRisqueAnalyse(risk: risk),
            const SizedBox(width: 4),
            const Icon(
              Icons.chevron_right,
              color: AppColors.textSubtle,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
