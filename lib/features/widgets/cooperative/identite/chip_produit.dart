import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_text_styles.dart';

/// Chip d'un produit géré par la coop (cacao, café, anacarde, etc.).
/// Style miroir de `ChipZoneAchat` côté acheteur, factorisable plus tard
/// si besoin (les deux ressemblent beaucoup).
class ChipProduitCoop extends StatelessWidget {
  /// Construit le chip.
  const ChipProduitCoop({
    super.key,
    required this.label,
    required this.editable,
    this.onSupprimer,
  });

  /// Nom du produit affiché.
  final String label;

  /// Si vrai, affiche un bouton X.
  final bool editable;

  /// Callback de suppression.
  final VoidCallback? onSupprimer;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 12,
        right: editable ? 4 : 12,
        top: 6,
        bottom: 6,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.eco_outlined,
            size: 13,
            color: AppColors.primary,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTextStyles.labelMedium.copyWith(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
          if (editable) ...[
            const SizedBox(width: 4),
            InkWell(
              onTap: onSupprimer,
              borderRadius: BorderRadius.circular(999),
              child: const Padding(
                padding: EdgeInsets.all(2),
                child: Icon(
                  Icons.close,
                  size: 14,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
