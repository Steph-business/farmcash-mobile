import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';
import '_constantes_accueil_coop.dart';

/// CTA hero "Collecte du jour" affiché en haut de l'accueil coopérative
/// lorsqu'il y a des produits à peser. Couleur primary pleine, sous-titre
/// indiquant le nombre de produits en attente.
class CtaCollecteCoop extends StatelessWidget {
  const CtaCollecteCoop({
    super.key,
    required this.nbAValider,
    required this.onTap,
  });

  final int nbAValider;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final sousTitre = nbAValider > 0
        ? '$nbAValider ${nbAValider > 1 ? "produits" : "produit"} à peser'
        : 'Aucun produit en attente';

    return Material(
      color: AppColors.primary,
      borderRadius: kBrHeroCoop,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: kBrHeroCoop,
        child: Stack(
          children: [
            // Cercle décoratif blanc semi-transparent en bas-droite —
            // "embellish" subtil, ne modifie pas le layout du contenu.
            Positioned(
              right: -28,
              bottom: -28,
              child: IgnorePointer(
                child: Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    color: AppColors.onPrimary.withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Collecte du jour',
                          style: AppTextStyles.titleSmall.copyWith(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.onPrimary,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          sousTitre,
                          style: AppTextStyles.bodySmall.copyWith(
                            fontSize: 12,
                            color: AppColors.onPrimary.withValues(alpha: 0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                  AppDimens.hGap12,
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.onPrimary.withValues(alpha: 0.18),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.assignment_outlined,
                      size: 20,
                      color: AppColors.onPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
