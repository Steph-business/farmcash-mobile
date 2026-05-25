import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_text_styles.dart';

/// Étiquette de section sur la page de pesée d'une livraison
/// coopérative (ex. « Poids réel mesuré », « Qualité observée »).
class EtiquettePesee extends StatelessWidget {
  const EtiquettePesee(this.text, {super.key});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: AppTextStyles.labelMedium.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: AppColors.text,
      ),
    );
  }
}
