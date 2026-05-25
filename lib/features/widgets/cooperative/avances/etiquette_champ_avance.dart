import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_text_styles.dart';

/// Étiquette de champ de formulaire utilisée sur la page « Verser une
/// avance » (libellé court au-dessus du contrôle, ex « Membre »,
/// « Motif (optionnel) »).
class EtiquetteChampAvance extends StatelessWidget {
  const EtiquetteChampAvance(this.label, {super.key});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: AppTextStyles.labelMedium.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: AppColors.text,
      ),
    );
  }
}
