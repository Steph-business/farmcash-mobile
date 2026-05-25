import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';
import 'initiales_nom.dart';

const Color _kPrimarySoft = Color(0xFFE8F5E9);

/// Avatar circulaire d'un demandeur d'adhesion : photo distante si dispo,
/// sinon initiales sur fond primary-soft.
class AvatarAdhesion extends StatelessWidget {
  const AvatarAdhesion({required this.url, required this.nom, super.key});

  /// URL distante (peut etre `null` ou vide pour fallback initiales).
  final String? url;

  /// Nom du demandeur, utilise pour generer les initiales.
  final String nom;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: _kPrimarySoft,
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.border,
          width: AppDimens.borderThin,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: (url == null || url!.isEmpty)
          ? Center(
              child: Text(
                initialesNom(nom),
                style: AppTextStyles.titleSmall.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            )
          : CachedNetworkImage(
              imageUrl: url!,
              fit: BoxFit.cover,
              placeholder: (_, _) => const ColoredBox(color: _kPrimarySoft),
              errorWidget: (_, _, _) => Center(
                child: Text(
                  initialesNom(nom),
                  style: AppTextStyles.titleSmall.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
    );
  }
}
