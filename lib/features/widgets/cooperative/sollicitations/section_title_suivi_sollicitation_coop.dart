import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_text_styles.dart';

/// Titre de section gras-noir (14 pt, weight 700) affiché au-dessus des
/// blocs de la page suivi sollicitation coopérative : « Récap »,
/// « Progression du remplissage », « Réponses reçues (X) ».
class SectionTitleSuiviSollicitationCoop extends StatelessWidget {
  const SectionTitleSuiviSollicitationCoop({
    required this.title,
    super.key,
  });

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: AppTextStyles.titleSmall.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: AppColors.text,
      ),
    );
  }
}
