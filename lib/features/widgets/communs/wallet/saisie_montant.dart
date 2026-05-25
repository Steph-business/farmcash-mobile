import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_text_styles.dart';

/// Champ de saisie du montant — chiffres centrés gros + libellé « F CFA ».
///
/// Visuel unifié sur les pages Recharger et Retirer. Le formatage du
/// contrôleur reste à la charge de l'appelant (utilise [NumberFormat] côté
/// page pour éviter de coupler ce widget à `intl`).
class SaisieMontant extends StatelessWidget {
  const SaisieMontant({
    super.key,
    required this.controller,
    this.devise = 'F CFA',
  });

  /// Contrôleur du champ (initialise et met à jour le texte affiché).
  final TextEditingController controller;

  /// Libellé de la devise affichée sous le montant.
  final String devise;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Column(
        children: [
          TextField(
            controller: controller,
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            style: AppTextStyles.displayLarge.copyWith(
              fontSize: 36,
              fontWeight: FontWeight.w700,
              color: AppColors.text,
              letterSpacing: -1,
            ),
            decoration: InputDecoration(
              hintText: '0',
              hintStyle: AppTextStyles.displayLarge.copyWith(
                fontSize: 36,
                fontWeight: FontWeight.w700,
                color: AppColors.textSubtle,
                letterSpacing: -1,
              ),
              border: InputBorder.none,
              focusedBorder: InputBorder.none,
              enabledBorder: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            devise,
            style: AppTextStyles.titleSmall.copyWith(
              fontFamily: AppTextStyles.displayLarge.fontFamily,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
