import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_text_styles.dart';

/// Libelle de section du formulaire de creation de publication (en-tete de
/// chaque champ : "Produit a publier", "Titre de l'annonce", etc.).
class LibelleSectionPublication extends StatelessWidget {
  const LibelleSectionPublication({required this.label, super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: AppTextStyles.bodyMedium.copyWith(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppColors.text,
      ),
    );
  }
}
