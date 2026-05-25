import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../models/panier.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';

final NumberFormat _nf = NumberFormat('#,##0', 'fr_FR');

/// Carte d'un article du panier acheteur : thumbnail, titre, vendeur,
/// localisation, quantité × prix unitaire, sous-total, et bouton
/// suppression avec spinner pendant l'appel API.
class CarteItemPanier extends StatelessWidget {
  const CarteItemPanier({
    required this.item,
    required this.suppressionEnCours,
    required this.onSupprimer,
    super.key,
  });

  final PanierItem item;
  final bool suppressionEnCours;
  final VoidCallback onSupprimer;

  @override
  Widget build(BuildContext context) {
    final titre = item.annonceTitre ?? 'Annonce';
    final photo = item.annoncePhotoUrl;
    final vendeur = item.vendeurNom ?? 'Vendeur';
    final loc = item.localisation;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.border,
            width: AppDimens.borderThin,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.surfaceSoft,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: AppColors.border,
                  width: AppDimens.borderThin,
                ),
              ),
              clipBehavior: Clip.antiAlias,
              child: photo != null
                  ? CachedNetworkImage(
                      imageUrl: photo,
                      fit: BoxFit.cover,
                      placeholder: (_, _) =>
                          const ColoredBox(color: AppColors.surfaceSoft),
                      errorWidget: (_, _, _) => const Icon(
                        Icons.image_outlined,
                        size: 28,
                        color: AppColors.textSubtle,
                      ),
                    )
                  : const Icon(
                      Icons.image_outlined,
                      size: 28,
                      color: AppColors.textSubtle,
                    ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    titre,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$vendeur${loc != null ? ' · $loc' : ''}',
                    style: AppTextStyles.labelSmall.copyWith(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${_nf.format(item.quantiteKg.round())} kg · ${_nf.format(item.prixUnitaire.round())} F/kg',
                    style: AppTextStyles.labelSmall.copyWith(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${_nf.format(item.sousTotal.round())} F',
                    style: AppTextStyles.headlineSmall.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 4),
            InkWell(
              onTap: suppressionEnCours ? null : onSupprimer,
              borderRadius: BorderRadius.circular(6),
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: suppressionEnCours
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.textSubtle,
                        ),
                      )
                    : const Icon(
                        Icons.delete_outline,
                        size: 18,
                        color: AppColors.textSecondary,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
