import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_text_styles.dart';
import 'section_annonce.dart';

/// Section "Description" : restitue le texte libre saisi par le producteur
/// (peut être absent — la page ne rend cette section que si non vide).
class SectionDescriptionAnnonce extends StatelessWidget {
  const SectionDescriptionAnnonce({required this.description, super.key});
  final String description;

  @override
  Widget build(BuildContext context) {
    return SectionAnnonce(
      title: 'Description',
      child: Text(
        description,
        style: AppTextStyles.bodyMedium.copyWith(
          fontSize: 13,
          color: AppColors.text,
          height: 1.5,
        ),
      ),
    );
  }
}
