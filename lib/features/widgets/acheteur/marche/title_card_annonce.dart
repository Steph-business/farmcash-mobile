import 'package:flutter/material.dart';

import '../../../../models/enums.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';
import 'annonce_detail_constants.dart';

/// Carte titre du détail annonce acheteur : nom du produit + chip qualité +
/// prix par kg (gros chiffre vert) + quantité disponible. Posée directement
/// sous le hero, séparée du reste par une bordure inférieure.
class TitleCardAnnonce extends StatelessWidget {
  const TitleCardAnnonce({
    required this.nom,
    required this.prixParKg,
    required this.qteDispo,
    required this.qualite,
    super.key,
  });

  final String nom;
  final int prixParKg;
  final int qteDispo;
  final ProductQuality qualite;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 14),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppColors.border,
            width: AppDimens.borderThin,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  nom,
                  style: AppTextStyles.titleLarge.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: kAnnonceDetailPrimarySoft,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: kAnnonceDetailPrimarySoft),
                ),
                child: Text(
                  qualiteLabelAnnonceDetail(qualite),
                  style: AppTextStyles.labelSmall.copyWith(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${kAnnonceDetailNumFmt.format(prixParKg)} F/kg',
            style: AppTextStyles.displaySmall.copyWith(
              fontFamily: 'Poppins',
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '${kAnnonceDetailNumFmt.format(qteDispo)} kg disponibles',
            style: AppTextStyles.bodySmall.copyWith(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
