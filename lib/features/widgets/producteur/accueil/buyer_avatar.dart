import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';
import 'accueil_constants.dart';
import 'accueil_helpers.dart';

/// Avatar pour les cards d'annonces d'achat sur l'accueil producteur : si
/// une `photoUrl` est dispo (jointure backend `users.photo_url`), on
/// l'affiche. Sinon, on retombe sur les initiales du nom dans une bulle
/// vert pâle. Évite d'avoir une photo placeholder grise quand le nom est
/// lisible.
class BuyerAvatar extends StatelessWidget {
  const BuyerAvatar({
    super.key,
    required this.photoUrl,
    required this.fallbackName,
  });

  final String? photoUrl;
  final String fallbackName;

  @override
  Widget build(BuildContext context) {
    final hasPhoto = photoUrl != null && photoUrl!.isNotEmpty;
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: kAccueilPrimarySoft,
        shape: BoxShape.circle,
        border:
            Border.all(color: AppColors.border, width: AppDimens.borderThin),
      ),
      clipBehavior: Clip.antiAlias,
      child: hasPhoto
          ? CachedNetworkImage(
              imageUrl: photoUrl!,
              fit: BoxFit.cover,
              placeholder: (_, _) => const ColoredBox(color: kAccueilPrimarySoft),
              errorWidget: (_, _, _) => Center(
                child: Text(
                  initialesAccueil(fallbackName),
                  style: AppTextStyles.labelSmall.copyWith(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
            )
          : Center(
              child: Text(
                initialesAccueil(fallbackName),
                style: AppTextStyles.labelSmall.copyWith(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ),
    );
  }
}
