import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_text_styles.dart';

/// Titre de section dans le formulaire de creation de prevision.
///
/// Note : volontairement distinct du `TitreSection` du wizard publier
/// (publish flow). Ici padding-bottom 4 px + left 2 px pour s'aligner sur
/// les inputs.
class TitreSectionPrevision extends StatelessWidget {
  const TitreSectionPrevision({required this.title, super.key});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 2, bottom: 4),
      child: Text(
        title,
        style: AppTextStyles.titleSmall.copyWith(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: AppColors.text,
        ),
      ),
    );
  }
}
