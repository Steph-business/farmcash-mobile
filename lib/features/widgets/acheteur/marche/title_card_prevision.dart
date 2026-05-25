import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';
import 'prevision_detail_constants.dart';

/// Title card de la page détail prévision : nom du produit, chip qualité,
/// prix prévu en gros et quantité prévue en sous-ligne.
class TitleCardPrevision extends StatelessWidget {
  const TitleCardPrevision({
    required this.nom,
    required this.qualite,
    required this.prixPrevu,
    required this.qteTotale,
    super.key,
  });

  final String nom;
  final String qualite;
  final int prixPrevu;
  final int qteTotale;

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
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: kPrevisionDetailPrimarySoft,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: kPrevisionDetailPrimarySoft),
                ),
                child: Text(
                  qualite,
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
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: '${kPrevisionDetailNumFmt.format(prixPrevu)} F/kg ',
                  style: AppTextStyles.displaySmall.copyWith(
                    fontFamily: 'Poppins',
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                    letterSpacing: -0.4,
                  ),
                ),
                TextSpan(
                  text: 'prévu',
                  style: AppTextStyles.bodySmall.copyWith(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '${kPrevisionDetailNumFmt.format(qteTotale)} kg prévus',
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
