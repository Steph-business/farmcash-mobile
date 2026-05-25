import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../models/cooperative.dart';
import '../../../../routing/route_names.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';
import 'accueil_constants.dart';
import 'accueil_helpers.dart';
import 'coop_logo_placeholder.dart';

/// Bandeau "Ma coopérative" : logo + nom + date d'adhésion + lien "Voir →".
/// Tap → ouvre l'écran coopérative. Posé en haut de la card SectionCoop.
class CoopBanner extends StatelessWidget {
  const CoopBanner({super.key, required this.coop});

  final Cooperative coop;

  @override
  Widget build(BuildContext context) {
    final logoUrl = coop.logoUrl;
    return InkWell(
      onTap: () =>
          context.push(RouteNames.producteurCooperativePath),
      child: Container(
        color: kAccueilPrimarySoft,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: AppColors.border,
                  width: AppDimens.borderThin,
                ),
              ),
              clipBehavior: Clip.hardEdge,
              child: (logoUrl != null && logoUrl.isNotEmpty)
                  ? CachedNetworkImage(
                      imageUrl: logoUrl,
                      fit: BoxFit.cover,
                      placeholder: (_, __) =>
                          CoopLogoPlaceholder(nom: coop.nom),
                      errorWidget: (_, __, ___) =>
                          CoopLogoPlaceholder(nom: coop.nom),
                    )
                  : CoopLogoPlaceholder(nom: coop.nom),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    coop.nom,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    formatMembreDepuis(coop.createdAt),
                    style: AppTextStyles.bodySmall.copyWith(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Text(
              'Voir →',
              style: AppTextStyles.link.copyWith(
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
