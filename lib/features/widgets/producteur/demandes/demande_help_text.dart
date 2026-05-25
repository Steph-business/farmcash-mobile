import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_text_styles.dart';

/// Petit texte d'aide gris sous un champ de formulaire.
///
/// Utilisé pour guider le producteur (ex. rappel du prix max accepté
/// par l'acheteur, info sur la superficie de la parcelle, etc.).
class DemandeHelpText extends StatelessWidget {
  const DemandeHelpText({required this.text, super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        text,
        style: AppTextStyles.bodySmall.copyWith(
          fontSize: 11,
          color: AppColors.textSecondary,
          height: 1.5,
        ),
      ),
    );
  }
}
