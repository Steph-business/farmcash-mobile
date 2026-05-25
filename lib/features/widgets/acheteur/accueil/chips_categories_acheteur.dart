import 'package:flutter/material.dart';

import '../../../../models/produit.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';

/// Liste horizontale de chips catégories pour filtrer l'accueil acheteur.
///
/// Affiche d'abord un chip "Tout" (value `null`), puis un chip par catégorie.
/// Le chip actif est colorié `AppColors.primary`. Le callback `onChanged`
/// reçoit la valeur sélectionnée (nom de catégorie ou `null` pour "Tout").
class ChipsCategoriesAcheteur extends StatelessWidget {
  const ChipsCategoriesAcheteur({
    super.key,
    required this.categories,
    required this.selection,
    required this.onChanged,
  });

  final List<Categorie> categories;
  final String? selection;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    final items = <_ChipData>[
      const _ChipData(label: 'Tout', value: null),
      ...categories.map((c) => _ChipData(label: c.nom, value: c.nom)),
    ];

    return SizedBox(
      height: 34,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: items.length,
        separatorBuilder: (_, __) => AppDimens.hGap8,
        itemBuilder: (context, i) {
          final item = items[i];
          final active = item.value == selection;
          return ChipCategorieAcheteur(
            label: item.label,
            active: active,
            onTap: () => onChanged(item.value),
          );
        },
      ),
    );
  }
}

class _ChipData {
  const _ChipData({required this.label, required this.value});
  final String label;
  final String? value;
}

/// Chip pilule simple (texte + état actif). Utilisé par
/// [ChipsCategoriesAcheteur] mais aussi réutilisable comme un chip de filtre
/// générique.
class ChipCategorieAcheteur extends StatelessWidget {
  const ChipCategorieAcheteur({
    super.key,
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimens.radiusPill),
      child: Container(
        height: 34,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: active ? AppColors.primary : AppColors.background,
          borderRadius: BorderRadius.circular(AppDimens.radiusPill),
          border: Border.all(
            color: active ? AppColors.primary : AppColors.borderStrong,
            width: AppDimens.borderThin,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.labelMedium.copyWith(
            color: active ? AppColors.onPrimary : AppColors.text,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
