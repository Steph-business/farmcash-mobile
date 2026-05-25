import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';
import 'commandes_list_constants.dart';

/// Avatar carré d'un acheteur dans la liste des commandes producteur.
/// Affiche la photo distante si disponible, sinon les initiales en repli.
class AvatarAcheteur extends StatelessWidget {
  const AvatarAcheteur({
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
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: AppColors.surfaceSoft,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppColors.border,
          width: AppDimens.borderThin,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: hasPhoto
          ? CachedNetworkImage(
              imageUrl: photoUrl!,
              fit: BoxFit.cover,
              placeholder: (_, _) =>
                  const ColoredBox(color: AppColors.surfaceSoft),
              errorWidget: (_, _, _) => _AvatarInitiales(name: fallbackName),
            )
          : _AvatarInitiales(name: fallbackName),
    );
  }
}

class _AvatarInitiales extends StatelessWidget {
  const _AvatarInitiales({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        initialesDe(name),
        style: AppTextStyles.labelMedium.copyWith(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: AppColors.primary,
        ),
      ),
    );
  }
}
