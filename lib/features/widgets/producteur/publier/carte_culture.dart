import 'package:flutter/material.dart';

import '../../../../models/parcelle.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';
import '_couleurs_publier.dart';
import 'point_radio.dart';

/// Carte sélectionnable d'une culture du producteur à l'étape 1 du
/// wizard de publication.
///
/// Affiche le nom du produit, le nom + la superficie de la parcelle
/// associée, et un [PointRadio] de sélection. La carte se colore en
/// vert pâle quand [selected] est vrai.
class CarteCulture extends StatelessWidget {
  const CarteCulture({
    super.key,
    required this.culture,
    required this.parcelle,
    required this.selected,
    required this.onTap,
  });

  final Culture culture;
  final Parcelle? parcelle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final parcelleNom = parcelle?.nom ?? 'Parcelle inconnue';
    final ha = parcelle?.superficieHa;
    final haTxt = ha == null ? null : '${ha.toStringAsFixed(1)} ha';
    final sousTitre = haTxt == null ? parcelleNom : '$parcelleNom · $haTxt';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: selected ? kSoftBgPublier : AppColors.background,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? AppColors.primary : AppColors.border,
              width: selected ? 1.5 : AppDimens.borderThin,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.eco_outlined,
                  size: 22,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      culture.produitNom ?? '(produit inconnu)',
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      sousTitre,
                      style: AppTextStyles.bodySmall.copyWith(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              PointRadio(selected: selected),
            ],
          ),
        ),
      ),
    );
  }
}
