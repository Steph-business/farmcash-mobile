import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../models/annonce_vente.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';
import 'libelle_qualite_produit.dart';

const Color _kPrimarySoft = Color(0xFFE8F5E9);
const BorderRadius _kBrCard12 = BorderRadius.all(Radius.circular(12));
final NumberFormat _nf = NumberFormat('#,##0', 'fr_FR');

/// Carte hero affichée tout en haut de la page de pesée d'une livraison :
/// photo du produit (ou placeholder), nom du producteur, quantité
/// annoncée + qualité et puce « En attente de pesée ».
class CarteHeroPesee extends StatelessWidget {
  const CarteHeroPesee({required this.annonce, super.key});
  final AnnonceVente annonce;

  @override
  Widget build(BuildContext context) {
    final farmerNom = annonce.vendeurNom ?? 'Producteur';
    final qteAnnonce = '${_nf.format(annonce.quantiteKg.round())} kg';
    final qualite = libelleQualiteProduit(annonce.qualite);
    final photo =
        annonce.photos.isNotEmpty ? annonce.photos.first : null;
    return ClipRRect(
      borderRadius: _kBrCard12,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: _kBrCard12,
          border: Border.all(
            color: AppColors.border,
            width: AppDimens.borderThin,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 140,
              width: double.infinity,
              child: photo != null
                  ? CachedNetworkImage(
                      imageUrl: photo,
                      fit: BoxFit.cover,
                      placeholder: (_, _) =>
                          const ColoredBox(color: _kPrimarySoft),
                      errorWidget: (_, _, _) =>
                          const ColoredBox(color: _kPrimarySoft),
                    )
                  : Container(
                      color: _kPrimarySoft,
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.shopping_basket_outlined,
                        size: 48,
                        color: AppColors.primary,
                      ),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    farmerNom,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.titleSmall.copyWith(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Annoncé : $qteAnnonce · Qualité $qualite',
                    style: AppTextStyles.bodySmall.copyWith(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: AppColors.border,
                        width: AppDimens.borderThin,
                      ),
                    ),
                    child: Text(
                      'En attente de pesée',
                      style: AppTextStyles.labelSmall.copyWith(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
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
