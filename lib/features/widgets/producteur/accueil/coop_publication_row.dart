import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../models/publication_coop.dart';
import '../../../../routing/route_names.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';
import 'accueil_helpers.dart';

/// Ligne d'une publication récente de la coopérative dans la SectionCoop
/// (collecte ouverte, communication interne, etc.). Tappable pour ouvrir
/// le détail de la publication.
class CoopPublicationRow extends StatelessWidget {
  const CoopPublicationRow({super.key, required this.publication});

  final PublicationCoop publication;

  @override
  Widget build(BuildContext context) {
    final qte = NumberFormat('#,##0', 'fr_FR').format(publication.quantiteKg);
    final titre = publication.titre.trim().isNotEmpty
        ? publication.titre.trim()
        : 'Publication';
    return InkWell(
      onTap: () => context.push(
        RouteNames.producteurPublicationCoopDetailPathFor(publication.id),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(
              color: AppColors.border,
              width: AppDimens.borderThin,
            ),
          ),
        ),
        child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: AppColors.surfaceSoft,
              borderRadius: BorderRadius.circular(AppDimens.radiusS),
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.inventory_2_outlined,
              size: 16,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Nouvelle publication : $titre $qte kg',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (publication.createdAt != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    ageRelatifCourt(publication.createdAt),
                    style: AppTextStyles.bodySmall.copyWith(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ],
        ),
      ),
    );
  }
}
