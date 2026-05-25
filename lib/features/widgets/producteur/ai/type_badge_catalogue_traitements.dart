import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_text_styles.dart';
import 'catalogue_traitements_constants.dart';

/// Petit badge en haut a droite d'une carte traitement.
///
/// Si `isBio` est vrai, fond vert pale + texte primaire ; sinon fond
/// neutre + texte secondaire. Le texte est upper-cased.
class TypeBadgeCatalogueTraitements extends StatelessWidget {
  const TypeBadgeCatalogueTraitements({
    required this.type,
    required this.isBio,
    super.key,
  });

  final String type;
  final bool isBio;

  @override
  Widget build(BuildContext context) {
    final upper = type.toUpperCase();
    final (bg, fg) = isBio
        ? (kPrimarySoftCatalogueTraitements, AppColors.primary)
        : (AppColors.surfaceSoft, AppColors.textSecondary);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        upper,
        style: AppTextStyles.labelSmall.copyWith(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: fg,
        ),
      ),
    );
  }
}
