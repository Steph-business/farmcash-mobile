import 'package:flutter/material.dart';

import '../../../../models/annonce_vente.dart';
import '../../../../models/produit.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';
import 'accueil_acheteur_constants.dart';
import 'accueil_acheteur_formats.dart';
import 'photo_annonce_acheteur.dart';

/// Grille 2 colonnes d'annonces de vente pour l'accueil acheteur.
///
/// Utilisée pour les sections "Recommandé pour toi" et "Près de chez toi".
/// `shrinkWrap` + `NeverScrollableScrollPhysics` car la grid vit dans le
/// `ListView` parent de la page d'accueil.
class AnnoncesGridAcheteur extends StatelessWidget {
  const AnnoncesGridAcheteur({
    super.key,
    required this.annonces,
    required this.produitsParId,
    required this.onTap,
  });

  final List<AnnonceVente> annonces;
  final Map<String, Produit> produitsParId;
  final ValueChanged<AnnonceVente> onTap;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: AppDimens.space12,
        mainAxisSpacing: AppDimens.space12,
        mainAxisExtent: 224,
      ),
      itemCount: annonces.length,
      itemBuilder: (context, i) {
        final a = annonces[i];
        return CarteAnnonceAcheteur(
          annonce: a,
          produitNom: produitsParId[a.produitId]?.nom,
          onTap: () => onTap(a),
        );
      },
    );
  }
}

/// Card d'annonce de vente côté acheteur (photo + titre + vendeur + prix
/// + disponibilité). Largeur fluide pour fonctionner en grid 2 colonnes.
class CarteAnnonceAcheteur extends StatelessWidget {
  const CarteAnnonceAcheteur({
    super.key,
    required this.annonce,
    required this.produitNom,
    required this.onTap,
  });

  final AnnonceVente annonce;
  final String? produitNom;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final photoUrl =
        annonce.photos.isNotEmpty ? annonce.photos.first : null;
    final titreCard = produitNom ?? annonce.titre;

    return InkWell(
      onTap: onTap,
      borderRadius: kAccueilBrCard,
      child: Container(
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
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 104,
              child: PhotoAnnonceAcheteur(url: photoUrl),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      titreCard,
                      style: AppTextStyles.titleSmall.copyWith(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _vendeurLigne(annonce),
                      style: AppTextStyles.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      formatPrixAccueil(annonce.prixParKg),
                      style: AppTextStyles.titleSmall.copyWith(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _disponibiliteLigne(annonce),
                      style: AppTextStyles.labelSmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _vendeurLigne(AnnonceVente a) {
    final region = a.regionId;
    if (region != null && region.isNotEmpty) {
      return 'Vendeur · $region';
    }
    return 'Vendeur';
  }

  String _disponibiliteLigne(AnnonceVente a) {
    final dispo = formatKgAccueil(a.quantiteKg);
    return '$dispo dispo';
  }
}
