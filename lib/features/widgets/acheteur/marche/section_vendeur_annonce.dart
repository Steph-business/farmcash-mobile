import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../models/annonce_vente.dart';
import '../../../../routing/route_names.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';
import 'annonce_detail_constants.dart';
import 'section_annonce.dart';

/// Section "Vendeur" : avatar (avec fallback Icon), nom du farmer, rating
/// si dispo, bouton outline "Voir profil" qui pousse la page vendeur.
class SectionVendeurAnnonce extends StatelessWidget {
  const SectionVendeurAnnonce({required this.annonce, super.key});
  final AnnonceVente annonce;

  @override
  Widget build(BuildContext context) {
    final nom = annonce.vendeurNom ?? 'Vendeur';
    final rating = annonce.vendeur?.rating;
    final photo = annonce.vendeur?.photoUrl;
    final farmerId = annonce.vendeur?.id ?? annonce.farmerId;

    return SectionAnnonce(
      title: 'Vendeur',
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.border,
                width: AppDimens.borderThin,
              ),
            ),
            clipBehavior: Clip.hardEdge,
            child: photo != null && photo.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: photo,
                    fit: BoxFit.cover,
                    placeholder: (_, _) =>
                        Container(color: AppColors.surfaceSoft),
                    errorWidget: (_, _, _) =>
                        Container(color: AppColors.surfaceSoft),
                  )
                : Container(
                    color: kAnnonceDetailPrimarySoft,
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.person_outline,
                      size: 24,
                      color: AppColors.primary,
                    ),
                  ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  nom,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (rating != null) ...[
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      const Text(
                        '★',
                        style: TextStyle(
                          color: kAnnonceDetailWarn,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        rating.toStringAsFixed(1),
                        style: AppTextStyles.labelSmall.copyWith(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          InkWell(
            onTap: () => context
                .push(RouteNames.acheteurVendeurDetailPathFor(farmerId)),
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: AppColors.primary,
                  width: AppDimens.borderThin,
                ),
              ),
              child: Text(
                'Voir profil',
                style: AppTextStyles.labelMedium.copyWith(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

