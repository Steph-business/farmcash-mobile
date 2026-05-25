import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_text_styles.dart';

/// Libellé court placé au-dessus d'un champ du formulaire « membre
/// géré ». Sobre, fontWeight 600.
class LibelleChampManaged extends StatelessWidget {
  const LibelleChampManaged(this.label, {super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: AppTextStyles.bodySmall.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: AppColors.text,
      ),
    );
  }
}
