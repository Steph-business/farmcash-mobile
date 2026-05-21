import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_dimens.dart';
import '../../../theme/app_text_styles.dart';

/// Card raccourci action — utilisée sur l'accueil de la coop pour les
/// 4 actions critiques (Collecte, Inviter, Avancer, Publier).
///
/// Conforme DESIGN.md : fond blanc, bordure 1px, radius 12, sans ombre.
/// L'icône peut être affichée dans un cercle coloré (32×32) en passant
/// `accentColor` — sinon, icône simple en vert primaire (fallback historique).
class TileRaccourci extends StatelessWidget {
  const TileRaccourci({
    required this.icon,
    required this.titre,
    required this.onTap,
    this.sousTitre,
    this.badge,
    this.accentColor,
    super.key,
  });

  final IconData icon;
  final String titre;
  final String? sousTitre;
  final VoidCallback onTap;

  /// Petite valeur affichée en haut à droite (ex: "8" pour 8 produits à
  /// collecter). Caché si null.
  final String? badge;

  /// Si fourni, l'icône est placée dans un cercle plein de cette couleur
  /// (icône blanche dessus). Permet de différencier visuellement les tiles.
  final Color? accentColor;

  @override
  Widget build(BuildContext context) {
    final Widget iconWidget = accentColor != null
        ? Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: accentColor,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Icon(icon, color: AppColors.onPrimary, size: 18),
          )
        : Icon(icon, color: AppColors.primary, size: 28);

    return Material(
      color: AppColors.surface,
      borderRadius: AppDimens.brCard,
      child: InkWell(
        borderRadius: AppDimens.brCard,
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: AppDimens.brCard,
            border: Border.all(color: AppColors.border, width: 1),
          ),
          padding: const EdgeInsets.all(AppDimens.space16),
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                mainAxisSize: MainAxisSize.min,
                children: [
                  iconWidget,
                  AppDimens.vGap12,
                  Text(
                    titre,
                    style: AppTextStyles.titleSmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (sousTitre != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      sousTitre!,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
              if (badge != null)
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.error,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      badge!,
                      style: const TextStyle(
                        color: AppColors.onError,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
