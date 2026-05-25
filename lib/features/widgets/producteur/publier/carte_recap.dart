import 'package:flutter/material.dart';

import '../../../../models/parcelle.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';
import 'ligne_recap.dart';

/// Carte récapitulative affichée à la dernière étape du wizard avant
/// publication.
///
/// Toutes les valeurs numériques sont déjà formatées par l'appelant
/// (séparateurs FR, kg / F/kg, total). La carte se contente de
/// composer les lignes et le bloc total.
class CarteRecap extends StatelessWidget {
  const CarteRecap({
    super.key,
    required this.culture,
    required this.parcelle,
    required this.qteFormatee,
    required this.prixFormate,
    required this.totalFormate,
    required this.qualite,
  });

  final Culture culture;
  final Parcelle? parcelle;
  final String qteFormatee;
  final String prixFormate;
  final String totalFormate;
  final String qualite;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceSoft,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.border,
          width: AppDimens.borderThin,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Récapitulatif',
            style: AppTextStyles.titleSmall.copyWith(
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          LigneRecap('Culture', culture.produitNom ?? '(inconnu)'),
          LigneRecap(
            'Parcelle',
            parcelle?.nom ?? '—',
          ),
          LigneRecap('Quantité', '$qteFormatee kg'),
          LigneRecap(
            'Prix',
            '$prixFormate F/kg',
          ),
          LigneRecap('Qualité', qualite),
          const Divider(height: 16, color: AppColors.border),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Total estimé',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                '$totalFormate F',
                style: AppTextStyles.titleMedium.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
