import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';
import 'publier_demande_constants.dart';

/// Tuile cliquable qui ouvre le bottom-sheet de sélection produit. Affiche
/// l'icône fleur, le nom du produit choisi et la qualité courante.
class TuileSelectionProduitDemande extends StatelessWidget {
  const TuileSelectionProduitDemande({
    required this.produit,
    required this.qualite,
    required this.onTap,
    super.key,
  });

  final PublierDemandeProduitOption? produit;
  final String qualite;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = produit;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.border,
            width: AppDimens.borderThin,
          ),
        ),
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: kPublierDemandePrimarySoft,
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.local_florist_outlined,
                size: 18,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    p?.nom ?? 'Choisir un produit',
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$qualite · catalogue FarmCash',
                    style: AppTextStyles.bodySmall.copyWith(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.keyboard_arrow_down,
              color: AppColors.textSubtle,
            ),
          ],
        ),
      ),
    );
  }
}
