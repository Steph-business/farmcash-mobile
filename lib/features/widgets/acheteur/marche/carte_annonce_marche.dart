import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../models/annonce_vente.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';
import 'photo_carte_marche.dart';

const BorderRadius _kBrCard = BorderRadius.all(Radius.circular(12));

/// Carte d'une annonce de vente dans la grille du marché : photo en
/// haut + titre, vendeur, localisation, prix/kg, quantité dispo et
/// date de publication.
///
/// `nomProduit` est résolu en amont (vue mère) à partir du catalogue
/// produit pour éviter un fallback texte libre quand le `produit_nom`
/// renvoyé par l'API est absent.
class CarteAnnonceMarche extends StatelessWidget {
  const CarteAnnonceMarche({
    required this.annonce,
    required this.nomProduit,
    required this.onTap,
    super.key,
  });

  final AnnonceVente annonce;
  final String? nomProduit;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final nf = NumberFormat('#,##0', 'fr_FR');
    final photoUrl = annonce.photos.isNotEmpty ? annonce.photos.first : null;
    final titre = nomProduit ?? annonce.titre;
    final vendeur = annonce.vendeurNom ?? 'Vendeur';
    final loc = annonce.localisationLabel ?? '—';
    final publie = annonce.createdAt;
    final recolte = annonce.dateRecolte;
    // Pour un produit frais, la date de RÉCOLTE compte plus que la
    // date de publication (info fraîcheur). On la met en priorité.
    // Si elle est absente, on retombe sur « Publié le X ».
    final String? metaLigne;
    if (recolte != null) {
      metaLigne =
          'Récolté le ${DateFormat('d MMM', 'fr_FR').format(recolte)}';
    } else if (publie != null) {
      metaLigne = 'Publié ${DateFormat('d MMM', 'fr_FR').format(publie)}';
    } else {
      metaLigne = null;
    }

    return InkWell(
      onTap: onTap,
      borderRadius: _kBrCard,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: _kBrCard,
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
              height: 110,
              child: PhotoCarteMarche(url: photoUrl),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(11, 9, 11, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titre,
                      style: AppTextStyles.titleSmall.copyWith(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        height: 1.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      vendeur,
                      style: AppTextStyles.bodySmall.copyWith(
                        fontSize: 11,
                        height: 1.3,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          size: 11,
                          color: AppColors.textSubtle,
                        ),
                        const SizedBox(width: 3),
                        Expanded(
                          child: Text(
                            loc,
                            style: AppTextStyles.labelSmall.copyWith(
                              fontSize: 10,
                              color: AppColors.textSubtle,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${nf.format(annonce.prixParKg.round())} F/kg',
                      style: AppTextStyles.titleSmall.copyWith(
                        fontFamily: 'Poppins',
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      '${nf.format(annonce.quantiteKg.round())} kg dispo',
                      style: AppTextStyles.labelSmall.copyWith(
                        fontSize: 10,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    if (metaLigne != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        metaLigne,
                        style: AppTextStyles.labelSmall.copyWith(
                          fontSize: 9,
                          color: AppColors.textSubtle,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
