import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_text_styles.dart';

/// Texte d'aide secondaire (11 px gris) sous un champ du formulaire de
/// prevision (par ex. explication du « prix cible »).
class HelpTextPrevision extends StatelessWidget {
  const HelpTextPrevision({required this.text, super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: AppTextStyles.bodySmall.copyWith(
        fontSize: 11,
        color: AppColors.textSecondary,
        height: 1.4,
      ),
    );
  }
}
