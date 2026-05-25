import 'package:flutter/material.dart';

import '../../../../models/produit.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';

/// Grille de puces sélectionnables (`Wrap`) pour la liste des produits.
///
/// Affiche un message vide si [produits] est vide. Chaque puce est
/// rendue via [PuceCulture] et notifie le parent via [onToggle].
class PucesCultures extends StatelessWidget {
  const PucesCultures({
    required this.produits,
    required this.selectedIds,
    required this.enabled,
    required this.onToggle,
    super.key,
  });

  final List<Produit> produits;
  final Set<String> selectedIds;
  final bool enabled;
  final ValueChanged<String> onToggle;

  @override
  Widget build(BuildContext context) {
    if (produits.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Text(
          'Aucun produit trouvé.',
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      );
    }
    return Wrap(
      spacing: AppDimens.space8,
      runSpacing: AppDimens.space8,
      children: [
        for (final p in produits)
          PuceCulture(
            label: p.nom,
            selected: selectedIds.contains(p.id),
            enabled: enabled,
            onTap: () => onToggle(p.id),
          ),
      ],
    );
  }
}

/// Puce unitaire (chip) sélectionnable pour une culture : vert plein
/// quand sélectionnée, blanc bordé sinon.
class PuceCulture extends StatelessWidget {
  const PuceCulture({
    required this.label,
    required this.selected,
    required this.enabled,
    required this.onTap,
    super.key,
  });

  final String label;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: selected ? AppColors.primary : AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected ? AppColors.primary : AppColors.border,
              width: AppDimens.borderThin,
            ),
          ),
          child: Text(
            label,
            style: AppTextStyles.labelMedium.copyWith(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: selected ? AppColors.onPrimary : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}
