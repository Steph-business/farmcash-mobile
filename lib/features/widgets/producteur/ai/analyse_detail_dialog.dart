import 'package:flutter/material.dart';

import '../../../../models/analyse_plante.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';
import 'analyse_plante_constants.dart';

/// Dialog compact affichant le détail d'une analyse plante quand on tape
/// sur une tuile de l'historique court. V1 : pas de page dédiée — on se
/// contente d'afficher maladie + date + recommandations en modale.
class AnalyseDetailDialog extends StatelessWidget {
  const AnalyseDetailDialog({required this.analyse, super.key});

  final AnalysePlante analyse;

  @override
  Widget build(BuildContext context) {
    final maladie = analyse.diseaseDetected?.trim();
    return Dialog(
      shape: const RoundedRectangleBorder(
        borderRadius: AppDimens.brCard,
      ),
      backgroundColor: AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(AppDimens.space16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              (maladie != null && maladie.isNotEmpty)
                  ? maladie
                  : 'Analyse en cours',
              style: AppTextStyles.titleLarge.copyWith(
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
            AppDimens.vGap8,
            Text(
              formatAnalyseDate(analyse.createdAt),
              style: AppTextStyles.bodySmall.copyWith(fontSize: 12),
            ),
            AppDimens.vGap16,
            if (analyse.recommendations != null &&
                analyse.recommendations!.trim().isNotEmpty)
              Text(
                analyse.recommendations!.trim(),
                style: AppTextStyles.bodyMedium,
              )
            else
              Text(
                "Aucune recommandation détaillée n'a été fournie pour cette "
                'analyse.',
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
