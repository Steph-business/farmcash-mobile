import 'package:flutter/material.dart';

import '../../../../models/analyse_plante.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';
import 'analyse_plante_constants.dart';

/// Dialog detail d'une analyse depuis l'historique. Difference cle avec
/// `AnalyseDetailDialog` (court historique) : affiche l'image hero en
/// premier (apercu visuel).
class AnalyseHistoriqueDetailDialog extends StatelessWidget {
  const AnalyseHistoriqueDetailDialog({required this.analyse, super.key});

  final AnalysePlante analyse;

  @override
  Widget build(BuildContext context) {
    final maladie = analyse.diseaseDetected?.trim();
    final recommandations = analyse.recommendations?.trim();
    return Dialog(
      shape: const RoundedRectangleBorder(borderRadius: AppDimens.brCard),
      backgroundColor: AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(AppDimens.space16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (analyse.imageUrl.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: AspectRatio(
                  aspectRatio: 16 / 10,
                  child: Image.network(
                    analyse.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => Container(
                      color: AppColors.surfaceSoft,
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.image_outlined,
                        color: AppColors.textSubtle,
                      ),
                    ),
                  ),
                ),
              ),
            AppDimens.vGap12,
            Text(
              (maladie != null && maladie.isNotEmpty)
                  ? maladie
                  : 'Analyse en cours',
              style: AppTextStyles.titleLarge.copyWith(
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
            AppDimens.vGap4,
            Text(
              formatAnalyseDate(analyse.createdAt),
              style: AppTextStyles.bodySmall.copyWith(fontSize: 12),
            ),
            AppDimens.vGap12,
            if (recommandations != null && recommandations.isNotEmpty)
              Text(recommandations, style: AppTextStyles.bodyMedium)
            else
              Text(
                "Aucune recommandation détaillée n'a été fournie.",
                style: AppTextStyles.bodySmall,
              ),
            AppDimens.vGap16,
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Fermer'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
