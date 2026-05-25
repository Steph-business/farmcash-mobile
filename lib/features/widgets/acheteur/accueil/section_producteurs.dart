import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';
import 'accueil_acheteur_constants.dart';
import 'accueil_acheteur_formats.dart';
import 'badge_fiabilite.dart';
import 'section_accueil_acheteur.dart';
import 'vendeur_apercu.dart';

/// Section "Producteurs à découvrir" — liste horizontale scrollable de
/// cards producteur. Affichée seulement si au moins 2 vendeurs distincts
/// sont disponibles (décision prise dans la page parente).
class SectionProducteurs extends StatelessWidget {
  const SectionProducteurs({
    super.key,
    required this.producteurs,
    required this.onVoirTout,
    required this.onTapVendeur,
  });

  final List<ApercuProducteur> producteurs;
  final VoidCallback onVoirTout;
  final ValueChanged<ApercuProducteur> onTapVendeur;

  @override
  Widget build(BuildContext context) {
    return SectionAccueilAcheteur(
      titre: 'Producteurs à découvrir',
      onVoirTout: onVoirTout,
      child: SizedBox(
        height: 232,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          itemCount: producteurs.length,
          separatorBuilder: (_, __) => AppDimens.hGap12,
          itemBuilder: (context, i) => CarteProducteur(
            vendeur: producteurs[i],
            onTap: () => onTapVendeur(producteurs[i]),
          ),
        ),
      ),
    );
  }
}

/// Card unitaire d'un producteur (photo placeholder, nom, région +
/// nombre de produits, badge fiabilité).
class CarteProducteur extends StatelessWidget {
  const CarteProducteur({
    super.key,
    required this.vendeur,
    required this.onTap,
  });

  final ApercuProducteur vendeur;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final region = vendeur.regionId;
    final regionTxt =
        (region != null && region.isNotEmpty) ? region : 'Région';
    final sousTitre = '$regionTxt · ${vendeur.nbProduits} produit'
        '${vendeur.nbProduits > 1 ? 's' : ''}';

    return InkWell(
      onTap: onTap,
      borderRadius: kAccueilBrCard,
      child: Container(
        width: 160,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: kAccueilBrCard,
          border: Border.all(
            color: AppColors.border,
            width: AppDimens.borderThin,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Photo : pas d'URL fiable -> placeholder gris avec initiales.
            Container(
              height: 120,
              width: double.infinity,
              color: AppColors.surfaceSoft,
              alignment: Alignment.center,
              child: Text(
                initialesAccueil(vendeur.farmerId),
                style: AppTextStyles.headlineSmall.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Nom réel si dispo (joint depuis users.full_name), sinon
                  // fallback initiales UUID. Évite l'illisible "Vendeur a3f8b…".
                  Text(
                    vendeur.fullName?.trim().isNotEmpty == true
                        ? vendeur.fullName!.trim()
                        : 'Vendeur',
                    style: AppTextStyles.titleSmall.copyWith(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    sousTitre,
                    style: AppTextStyles.bodySmall.copyWith(fontSize: 11),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  // Badge fiabilité : aide l'acheteur à juger la confiance
                  // avant de cliquer sur le vendeur. Couleur conditionnelle :
                  // vert >= 80 (excellent), orange 50-79 (correct), rouge < 50
                  // (suspect). Pas affiché si score null (legacy / non joint).
                  BadgeFiabilite(score: vendeur.reliabilityScore),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
