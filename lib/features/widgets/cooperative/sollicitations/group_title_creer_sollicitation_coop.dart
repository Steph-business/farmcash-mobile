import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_text_styles.dart';

/// Titre de groupe gras-noir (14 pt, weight 700) en tête de chaque
/// section du formulaire de création de sollicitation : « Offre cliente
/// à couvrir », « Besoin à combler », « Qui solliciter ? », etc.
class GroupTitleCreerSollicitationCoop extends StatelessWidget {
  const GroupTitleCreerSollicitationCoop({
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
