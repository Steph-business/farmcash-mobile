import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_text_styles.dart';

/// Titre de section pour les formulaires (transporteur) : texte en
/// majuscules, espacement lettrage 0.4, poids 700, couleur secondaire.
class TitreSectionFormulaire extends StatelessWidget {
  const TitreSectionFormulaire(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: AppTextStyles.labelSmall.copyWith(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.4,
        color: AppColors.textSecondary,
      ),
    );
  }
}
