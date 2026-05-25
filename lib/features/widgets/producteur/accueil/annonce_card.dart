import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../models/annonce_vente.dart';
import '../../../../routing/route_names.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';
import 'accueil_constants.dart';

/// Card horizontale d'une annonce de vente du producteur dans la
/// SectionAnnonces : photo principale + titre + qte/vues + prix au kg.
/// Tappable pour ouvrir le détail de l'annonce.
class AnnonceCard extends StatelessWidget {
  const AnnonceCard({super.key, required this.annonce});

  final AnnonceVente annonce;

  @override
  Widget build(BuildContext context) {
    final photoUrl = annonce.photos.isNotEmpty ? annonce.photos.first : null;
    final qte = NumberFormat('#,##0', 'fr_FR').format(annonce.quantiteKg);
    final prix = NumberFormat('#,##0', 'fr_FR').format(annonce.prixParKg);

    return Material(
      color: AppColors.surface,
      borderRadius: kAccueilBrCard,
      clipBehavior: Clip.hardEdge,
      child: InkWell(
        onTap: () => context.push(
          RouteNames.producteurAnnonceDetailPathFor(annonce.id),
        ),
        child: Container(
          width: 200,
          decoration: BoxDecoration(
            borderRadius: kAccueilBrCard,
            border:
                Border.all(color: AppColors.border, width: AppDimens.borderThin),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 132,
                width: double.infinity,
                child: photoUrl != null && photoUrl.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: photoUrl,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => Container(
                          color: AppColors.surfaceSoft,
                        ),
                        errorWidget: (_, __, ___) => Container(
                          color: AppColors.surfaceSoft,
                          alignment: Alignment.center,
                          child: Text(
                            'Photo',
                            style: AppTextStyles.labelSmall.copyWith(
                              color: AppColors.textSubtle,
                            ),
                          ),
                        ),
                      )
                    : Container(
                        color: AppColors.surfaceSoft,
                        alignment: Alignment.center,
                        child: Text(
                          'Photo',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.textSubtle,
                          ),
                        ),
                      ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      annonce.titre,
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$qte kg · ${annonce.viewsCount} vues',
                      style: AppTextStyles.bodySmall.copyWith(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$prix F/kg',
                      style: AppTextStyles.titleLarge.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                        letterSpacing: -0.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
