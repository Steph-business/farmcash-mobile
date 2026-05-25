import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_text_styles.dart';

/// Label de champ de formulaire de la page edition du profil producteur.
class LabelProfilEditer extends StatelessWidget {
  const LabelProfilEditer(this.label, {super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: AppTextStyles.labelMedium.copyWith(
        fontWeight: FontWeight.w600,
        color: AppColors.text,
      ),
    );
  }
}
