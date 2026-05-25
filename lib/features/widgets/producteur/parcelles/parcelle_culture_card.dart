import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../models/parcelle.dart';
import '../../../../models/produit.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';
import 'parcelle_status_chip.dart';

/// Map slug → URL Unsplash pour la vignette culture. Aligné avec la
/// maquette pour les 3 produits principaux. Fallback générique pour
/// les autres.
const Map<String, String> _kProduitThumbBySlug = {
  'mais': 'https://images.unsplash.com/photo-1601493700631-2b16ec4b4716?w=200&h=200&fit=crop&auto=format',
  'mais-blanc': 'https://images.unsplash.com/photo-1601493700631-2b16ec4b4716?w=200&h=200&fit=crop&auto=format',
  'mais-grain-blanc': 'https://images.unsplash.com/photo-1601493700631-2b16ec4b4716?w=200&h=200&fit=crop&auto=format',
  'tomate': 'https://images.unsplash.com/photo-1518977956812-cd3dbadaaf31?w=200&h=200&fit=crop&auto=format',
  'manioc': 'https://images.unsplash.com/photo-1567521464027-f127ff144326?w=200&h=200&fit=crop&auto=format',
};

const String _kProduitThumbFallback =
    'https://images.unsplash.com/photo-1601493700631-2b16ec4b4716?w=200&h=200&fit=crop&auto=format';

/// Card individuelle d'une culture sur la parcelle.
///
/// Vignette à gauche (par slug produit, fallback maïs) + nom +
/// superficie + chip de statut à droite ("À semer" warn ou "En
/// production" green).
class ParcelleCultureCard extends StatelessWidget {
  const ParcelleCultureCard({
    required this.culture,
    required this.produit,
    super.key,
  });

  final Culture culture;
  final Produit? produit;

  @override
  Widget build(BuildContext context) {
    final nom = (culture.produitNom != null && culture.produitNom!.isNotEmpty)
        ? culture.produitNom!
        : (produit?.nom ?? 'Culture');
    final thumb = (produit != null && _kProduitThumbBySlug[produit!.slug] != null)
        ? _kProduitThumbBySlug[produit!.slug]!
        : _kProduitThumbFallback;
    final ha = culture.superficieHa;
    final superficieTxt = ha != null
        ? (ha - ha.truncate()).abs() < 0.05
            ? '${ha.toStringAsFixed(0)} ha'
            : '${ha.toStringAsFixed(1)} ha'
        : '— ha';
    final statut = _formatStatut(culture);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: AppDimens.borderThin),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: AppColors.border,
                width: AppDimens.borderThin,
              ),
            ),
            clipBehavior: Clip.hardEdge,
            child: CachedNetworkImage(
              imageUrl: thumb,
              fit: BoxFit.cover,
              placeholder: (_, _) => Container(color: AppColors.surfaceSoft),
              errorWidget: (_, _, _) => Container(color: AppColors.surfaceSoft),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  nom,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  superficieTxt,
                  style: AppTextStyles.bodySmall.copyWith(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          ParcelleStatusChip(label: statut.label, isWarn: statut.isWarn),
        ],
      ),
    );
  }

  /// Mappe le `statut` libre côté API vers une étiquette FR + couleur.
  ({String label, bool isWarn}) _formatStatut(Culture c) {
    final raw = c.statut?.toUpperCase().trim() ?? '';
    if (raw.contains('SEMER') || raw == 'TO_SOW' || raw == 'PLANNED') {
      return (label: 'À semer', isWarn: true);
    }
    return (label: 'En production', isWarn: false);
  }
}
