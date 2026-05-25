import 'package:flutter/material.dart';

import '../../../../models/analyse_plante.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';
import 'analyse_detail_dialog.dart';
import 'analyse_plante_constants.dart';
import 'chip_risque_analyse.dart';

/// Tile compact pour une analyse — utilisé inline dans l'historique court
/// de la page diagnostic. Vignette de la photo, libellé maladie (ou "En
/// cours…"), date courte, chip de risque puis chevron. Tap → dialog détail.
class AnalyseListTile extends StatelessWidget {
  const AnalyseListTile({
    required this.analyse,
    required this.isLast,
    super.key,
  });

  final AnalysePlante analyse;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final maladie = analyse.diseaseDetected?.trim();
    final libelle =
        (maladie != null && maladie.isNotEmpty) ? maladie : 'En cours…';
    final risk = analyse.riskLevel?.toLowerCase();
    final date = analyse.createdAt;
    return InkWell(
      onTap: () {
        // V1 : pas de page détail dédiée. On affiche un dialog compact.
        showDialog<void>(
          context: context,
          builder: (_) => AnalyseDetailDialog(analyse: analyse),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimens.space16,
          vertical: 12,
        ),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isLast ? Colors.transparent : AppColors.border,
              width: AppDimens.borderThin,
            ),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.surfaceSoft,
                borderRadius: BorderRadius.circular(8),
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
                        size: 20,
                      ),
                    )
                  : const Icon(
                      Icons.eco_outlined,
                      color: AppColors.textSubtle,
                      size: 20,
                    ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    libelle,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    formatAnalyseDate(date),
                    style: AppTextStyles.bodySmall.copyWith(fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (risk != null && risk.isNotEmpty) ...[
              ChipRisqueAnalyse(risk: risk),
              const SizedBox(width: 8),
            ],
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
