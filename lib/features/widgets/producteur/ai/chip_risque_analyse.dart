import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_text_styles.dart';
import 'analyse_plante_constants.dart';

/// Chip colorée matérialisant le niveau de risque d'une analyse plante.
/// Mappe les valeurs API ("high", "eleve", "medium", "low"…) vers un
/// libellé français + une paire de couleurs cohérente.
class ChipRisqueAnalyse extends StatelessWidget {
  const ChipRisqueAnalyse({required this.risk, super.key});

  final String risk;

  @override
  Widget build(BuildContext context) {
    final (label, bg, fg) = switch (risk) {
      'high' || 'eleve' || 'haut' => (
          'Élevé',
          kAnalysePlanteRedSoft,
          AppColors.error
        ),
      'medium' || 'moyen' => (
          'Moyen',
          kAnalysePlanteWarnSoft,
          kAnalysePlanteWarn,
        ),
      'low' || 'faible' => (
          'Faible',
          kAnalysePlantePrimarySoft,
          AppColors.primary,
        ),
      _ => (risk, AppColors.surfaceSoft, AppColors.textSecondary),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: AppTextStyles.labelSmall.copyWith(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: fg,
        ),
      ),
    );
  }
}
