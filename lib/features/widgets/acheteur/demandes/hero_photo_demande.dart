import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';

/// Hero photo 100 px de hauteur — illustration du produit sélectionné.
class HeroPhotoDemande extends StatelessWidget {
  const HeroPhotoDemande({required this.photoUrl, super.key});

  final String photoUrl;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        height: 100,
        decoration: BoxDecoration(
          color: AppColors.surfaceSoft,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.border,
            width: AppDimens.borderThin,
          ),
        ),
        clipBehavior: Clip.hardEdge,
        child: CachedNetworkImage(
          imageUrl: photoUrl,
          fit: BoxFit.cover,
          placeholder: (_, _) => Container(color: AppColors.surfaceSoft),
          errorWidget: (_, _, _) => Container(color: AppColors.surfaceSoft),
        ),
      ),
    );
  }
}
