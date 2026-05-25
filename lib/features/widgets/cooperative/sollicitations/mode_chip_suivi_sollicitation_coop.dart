import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_text_styles.dart';
import 'modele_sollicitation_suivi_coop.dart';

/// Chip pastel vert affichant le mode de réponse du fournisseur dans la
/// liste des réponses (« Maintenant », à terme « +X jours »). Toujours
/// posé à côté de la quantité kg engagée.
class ModeChipSuiviSollicitationCoop extends StatelessWidget {
  const ModeChipSuiviSollicitationCoop({
    required this.label,
    super.key,
  });

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: kPrimarySoftSollicitationCoop,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: AppTextStyles.labelSmall.copyWith(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: AppColors.primary,
        ),
      ),
    );
  }
}
