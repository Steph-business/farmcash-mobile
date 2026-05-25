import 'package:flutter/material.dart';

import '../../../../models/traitement.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';
import 'traitement_detail_dialog_catalogue.dart';
import 'type_badge_catalogue_traitements.dart';

/// Carte traitement pour la liste du catalogue.
///
/// Affiche nom + badge type/bio + maladies traitees + cultures concernees.
/// Tap → ouvre `TraitementDetailDialogCatalogue` (modal scrollable).
class TraitementCardCatalogue extends StatelessWidget {
  const TraitementCardCatalogue({required this.traitement, super.key});

  final Traitement traitement;

  @override
  Widget build(BuildContext context) {
    final maladies = traitement.maladies;
    final produits = traitement.produits;
    final type = traitement.type?.trim();
    return InkWell(
      onTap: () => _showDetail(context),
      borderRadius: AppDimens.brCard,
      child: Container(
        padding: const EdgeInsets.all(AppDimens.space12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppDimens.brCard,
          border: Border.all(
            color: AppColors.border,
            width: AppDimens.borderThin,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    traitement.nom,
                    style: AppTextStyles.titleSmall.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (type != null && type.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  TypeBadgeCatalogueTraitements(
                    type: type,
                    isBio: traitement.isBio,
                  ),
                ],
              ],
            ),
            if (maladies.isNotEmpty) ...[
              AppDimens.vGap8,
              Text(
                'Maladies : ${maladies.join(", ")}',
                style: AppTextStyles.bodySmall.copyWith(fontSize: 12),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            if (produits.isNotEmpty) ...[
              AppDimens.vGap4,
              Text(
                'Cultures : ${produits.join(", ")}',
                style: AppTextStyles.bodySmall.copyWith(fontSize: 12),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: 4),
          ],
        ),
      ),
    );
  }

  void _showDetail(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (_) => TraitementDetailDialogCatalogue(traitement: traitement),
    );
  }
}
