import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_text_styles.dart';

/// Etiquette d'un champ du formulaire de reception d'un lot ("Produit",
/// "Quantite receptionnee", "Qualite", "Date de recolte").
class EtiquetteChampLot extends StatelessWidget {
  const EtiquetteChampLot(this.label, {super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: AppTextStyles.labelMedium.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: AppColors.textSecondary,
      ),
    );
  }
}
