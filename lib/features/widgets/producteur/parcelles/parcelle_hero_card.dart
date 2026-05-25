import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../models/parcelle.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';
import 'parcelle_pill.dart';

const String _kHeroPhotoFallback =
    'https://images.unsplash.com/photo-1601493700631-2b16ec4b4716?w=600&h=400&fit=crop&auto=format';

/// Hero card en tête du détail parcelle : photo + nom + sous-titre
/// composé (zone, superficie, GPS) + pastille "Active".
class ParcelleHeroCard extends StatelessWidget {
  const ParcelleHeroCard({required this.parcelle, super.key});

  final Parcelle parcelle;

  @override
  Widget build(BuildContext context) {
    final sub = _formatSubtitle(parcelle);
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.border,
          width: AppDimens.borderThin,
        ),
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 140,
            width: double.infinity,
            child: CachedNetworkImage(
              imageUrl: _kHeroPhotoFallback,
              fit: BoxFit.cover,
              placeholder: (_, _) => Container(color: AppColors.surfaceSoft),
              errorWidget: (_, _, _) => Container(color: AppColors.surfaceSoft),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  parcelle.nom,
                  style: AppTextStyles.titleSmall.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  sub,
                  style: AppTextStyles.bodySmall.copyWith(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: const [
                    ParcellePill(label: 'Active'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatSubtitle(Parcelle p) {
    final parts = <String>[];
    // Ville/zone : inconnue côté modèle parcelle — on garde "Yopougon" si
    // pas mieux pour ne pas casser la mise en page (la maquette montre un
    // sous-titre composé). À remplacer par un vrai champ ville quand le
    // back l'expose.
    parts.add('Yopougon');
    if (p.superficieHa != null) {
      final ha = p.superficieHa!;
      final formatted = (ha - ha.truncate()).abs() < 0.05
          ? ha.toStringAsFixed(0)
          : ha.toStringAsFixed(1);
      parts.add('$formatted ha');
    }
    if (p.contour.isNotEmpty) {
      final pt = p.contour.first;
      parts.add('GPS ${pt.lat.toStringAsFixed(2)}, ${pt.lng.toStringAsFixed(2)}');
    } else {
      parts.add('GPS 5.36, -4.01');
    }
    return parts.join(' · ');
  }
}
