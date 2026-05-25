import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_text_styles.dart';

/// Titre de section au sein d'une étape du wizard (ex. « Quantité »,
/// « Qualité »).
///
/// Style : 14 px, bold, texte primaire.
class TitreSection extends StatelessWidget {
  const TitreSection(this.label, {super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: AppTextStyles.titleSmall.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: AppColors.text,
      ),
    );
  }
}
