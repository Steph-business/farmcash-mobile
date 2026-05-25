import 'package:flutter/material.dart';

import '../../../../models/annonce_vente.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';
import 'annonce_detail_constants.dart';
import 'section_annonce.dart';
import 'traitement_tile_annonce.dart';

/// Section traçabilité : liste des traitements phytosanitaires déclarés.
/// Toujours visible — si la liste est vide on affiche un encart positif
/// "Aucun traitement déclaré — production naturelle" (signal honnête pour
/// l'acheteur).
class SectionTracabiliteAnnonce extends StatelessWidget {
  const SectionTracabiliteAnnonce({required this.traitements, super.key});
  final List<AnnonceTraitement> traitements;

  @override
  Widget build(BuildContext context) {
    return SectionAnnonce(
      title: 'Traçabilité',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Origine et traitements appliqués',
            style: AppTextStyles.bodySmall.copyWith(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          if (traitements.isEmpty)
            // Empty state honnête : pas de mock, pas de bla-bla. Le manque
            // d'info devient une info en soi pour l'acheteur.
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: kAnnonceDetailPrimarySoft,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: AppColors.border,
                  width: AppDimens.borderThin,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.eco_outlined,
                    size: 18,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Aucun traitement déclaré — production naturelle',
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontSize: 13,
                        color: AppColors.text,
                      ),
                    ),
                  ),
                ],
              ),
            )
          else
            Column(
              children: [
                for (var i = 0; i < traitements.length; i++)
                  Padding(
                    padding: EdgeInsets.only(
                      bottom: i == traitements.length - 1 ? 0 : 10,
                    ),
                    child: TraitementTileAnnonce(t: traitements[i]),
                  ),
              ],
            ),
          const SizedBox(height: 10),
          Text(
            'Données fournies par le producteur',
            style: AppTextStyles.labelSmall.copyWith(
              fontSize: 10,
              color: AppColors.textSubtle,
            ),
          ),
        ],
      ),
    );
  }
}
