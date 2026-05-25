import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_text_styles.dart';

/// Titre de section affiché en MAJUSCULES sur la page détail d'une mission
/// transporteur. Utilisé pour découper « Trajet », « Marchandise »,
/// « Montant » et « Suivi ».
class TitreSectionMission extends StatelessWidget {
  const TitreSectionMission(this.text, {super.key});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 2),
      child: Text(
        text.toUpperCase(),
        style: AppTextStyles.labelSmall.copyWith(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.3,
          color: AppColors.text,
        ),
      ),
    );
  }
}
