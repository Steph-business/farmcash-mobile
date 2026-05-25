import 'package:flutter/material.dart';

import '../../../../models/produit.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_text_styles.dart';

/// Dropdown obligatoire pour choisir le produit recolte.
///
/// Le catalogue est charge par le parent (`CreerPrevisionBundle`). Le
/// champ est desactive quand `enabled == false` (pendant un submit).
class ProduitSelectorPrevision extends StatelessWidget {
  const ProduitSelectorPrevision({
    required this.produits,
    required this.selectedId,
    required this.enabled,
    required this.onChanged,
    super.key,
  });

  final List<Produit> produits;
  final String? selectedId;
  final bool enabled;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: selectedId,
      isExpanded: true,
      decoration: InputDecoration(
        hintText: 'Choisis un produit',
        hintStyle: AppTextStyles.hint.copyWith(fontSize: 13),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
      items: produits
          .map((p) => DropdownMenuItem(
                value: p.id,
                child: Text(
                  p.nom,
                  style: AppTextStyles.bodyMedium.copyWith(fontSize: 14),
                ),
              ))
          .toList(),
      onChanged: enabled
          ? (v) {
              if (v != null) onChanged(v);
            }
          : null,
    );
  }
}
