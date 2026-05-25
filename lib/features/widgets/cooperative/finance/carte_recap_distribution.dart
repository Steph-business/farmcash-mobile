import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';
import 'initiales_personne.dart';

const Color _kPrimarySoft = Color(0xFFE8F5E9);

/// Ligne recap d'un contributeur credite : photo + libelle FULL + montant.
class LigneRecapDistribution {
  /// URL de la photo Unsplash (ou autre).
  final String photo;

  /// Libelle FULL (nom complet + meta). La coop voit ses membres en clair.
  final String label;

  /// Montant formate avec suffixe (ex: "50 750 F").
  final String montant;

  const LigneRecapDistribution({
    required this.photo,
    required this.label,
    required this.montant,
  });
}

/// Carte recap apres distribution : titre + lignes contributeurs + total.
class CarteRecapDistribution extends StatelessWidget {
  const CarteRecapDistribution({
    required this.titre,
    required this.items,
    required this.totalLabel,
    required this.totalValue,
    super.key,
  });

  /// Titre de la publication (ex: "Publication Maïs blanc · 500 kg").
  final String titre;

  /// Lignes recap des contributeurs.
  final List<LigneRecapDistribution> items;

  /// Libelle de la ligne total (ex: "Total distribué").
  final String totalLabel;

  /// Valeur de la ligne total (ex: "175 000 F").
  final String totalValue;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.border,
          width: AppDimens.borderThin,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            titre,
            style: AppTextStyles.titleSmall.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          for (final l in items) _LigneRecapItem(line: l),
          const SizedBox(height: 6),
          Container(
            margin: const EdgeInsets.only(top: 6),
            padding: const EdgeInsets.only(top: 12),
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
                Expanded(
                  child: Text(
                    totalLabel,
                    style: AppTextStyles.titleSmall.copyWith(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Text(
                  totalValue,
                  style: AppTextStyles.titleLarge.copyWith(
                    fontFamily: AppTextStyles.displayLarge.fontFamily,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.text,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LigneRecapItem extends StatelessWidget {
  const _LigneRecapItem({required this.line});

  final LigneRecapDistribution line;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: _kPrimarySoft,
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.border,
                width: AppDimens.borderThin,
              ),
            ),
            clipBehavior: Clip.antiAlias,
            child: CachedNetworkImage(
              imageUrl: line.photo,
              fit: BoxFit.cover,
              placeholder: (_, _) => const ColoredBox(color: _kPrimarySoft),
              errorWidget: (_, _, _) => Center(
                child: Text(
                  initialesPersonne(line.label),
                  style: AppTextStyles.labelSmall.copyWith(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              line.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.bodyMedium.copyWith(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.text,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            line.montant,
            style: AppTextStyles.titleSmall.copyWith(
              fontFamily: AppTextStyles.displayLarge.fontFamily,
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}
