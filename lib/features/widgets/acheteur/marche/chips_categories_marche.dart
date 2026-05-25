import 'package:flutter/material.dart';

import '../../../../models/produit.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';

/// Une chip de catégorie (label + id). `id == null` représente la chip
/// « Tous » qui n'applique aucun filtre.
class _ChipCategorie {
  const _ChipCategorie({required this.libelle, required this.valeur});
  final String libelle;
  final String? valeur;
}

/// Liste horizontale de chips pour filtrer les annonces par catégorie.
/// La première chip « Tous » désélectionne le filtre (`null`).
class ChipsCategoriesMarche extends StatelessWidget {
  const ChipsCategoriesMarche({
    required this.categories,
    required this.selectionId,
    required this.onChanged,
    super.key,
  });

  final List<Categorie> categories;
  final String? selectionId;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    final items = <_ChipCategorie>[
      const _ChipCategorie(libelle: 'Tous', valeur: null),
      ...categories.map((c) => _ChipCategorie(libelle: c.nom, valeur: c.id)),
    ];

    return SizedBox(
      height: 34,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: items.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final it = items[i];
          final actif = it.valeur == selectionId;
          return InkWell(
            onTap: () => onChanged(it.valeur),
            borderRadius: BorderRadius.circular(18),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: actif ? AppColors.primary : AppColors.background,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: actif ? AppColors.primary : AppColors.border,
                  width: AppDimens.borderThin,
                ),
              ),
              child: Text(
                it.libelle,
                style: AppTextStyles.labelMedium.copyWith(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: actif ? AppColors.onPrimary : AppColors.textSecondary,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
