import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';
import 'accueil_constants.dart';

/// Tile carré d'un outil IA dans la grid 2×2 de la section "Outils IA" :
/// icône circulaire vert pâle + libellé sur 2 lignes max. Tappable.
class OutilTile extends StatelessWidget {
  const OutilTile({
    super.key,
    required this.icon,
    required this.titre,
    required this.onTap,
  });

  final IconData icon;
  final String titre;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: kAccueilBrCard,
      child: InkWell(
        onTap: onTap,
        borderRadius: kAccueilBrCard,
        child: Container(
          // Hauteur 116 (au lieu de 102) : laisse 4-8px de marge pour
          // que les titres en 2 lignes (« Diagnostiquer une plante »)
          // tiennent sans déborder. L'overflow "BOTTOM OVERFLOWED BY
          // 4.0 PIXELS" venait de cette contrainte trop serrée.
          height: 116,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: kAccueilBrCard,
            border: Border.all(
              color: AppColors.border,
              width: AppDimens.borderThin,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  color: kAccueilPrimarySoft,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Icon(icon, size: 18, color: AppColors.primary),
              ),
              Text(
                titre,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  height: 1.25,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
