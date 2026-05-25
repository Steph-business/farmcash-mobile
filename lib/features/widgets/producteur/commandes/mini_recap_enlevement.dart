import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import 'recap_row_enlevement.dart';

/// Mini recap (produit, quantite, destination, montant a recevoir) du
/// bordereau d'enlevement QR. Affiche les memes valeurs que la maquette.
class MiniRecapEnlevement extends StatelessWidget {
  const MiniRecapEnlevement({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceSoft,
        borderRadius: BorderRadius.circular(12),
        border:
            Border.all(color: AppColors.border, width: AppDimens.borderThin),
      ),
      padding: const EdgeInsets.all(14),
      child: const Column(
        children: [
          RecapRowEnlevement(label: 'Produit', value: 'Maïs grain blanc'),
          RecapRowEnlevement(label: 'Quantité', value: '500 kg'),
          RecapRowEnlevement(
            label: 'Destination',
            value: 'Restaurant Le Baoulé · Cocody',
          ),
          RecapRowEnlevement(
            label: 'À recevoir à l\'enlèvement',
            value: '169 750 F',
            valueColor: AppColors.primary,
            usePoppins: true,
            isLast: true,
          ),
        ],
      ),
    );
  }
}
