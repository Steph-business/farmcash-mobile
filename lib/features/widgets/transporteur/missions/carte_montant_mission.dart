import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../models/livraison.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';

const BorderRadius _kBrCard = BorderRadius.all(Radius.circular(12));
final NumberFormat _nf = NumberFormat('#,##0', 'fr_FR');

/// Carte « Montant » du détail mission : affiche la rémunération attendue
/// (devis ou prix final) ou « À fixer » si le backend n'a pas encore
/// chiffré la mission.
class CarteMontantMission extends StatelessWidget {
  const CarteMontantMission({required this.mission, super.key});
  final Livraison mission;

  @override
  Widget build(BuildContext context) {
    final prix = mission.prixDevis ?? mission.prixFinal;
    final prixLabel =
        prix != null ? '${_nf.format(prix.round())} F' : 'À fixer';
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: _kBrCard,
        border: Border.all(
          color: AppColors.border,
          width: AppDimens.borderThin,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Rémunération mission',
              style: AppTextStyles.bodyMedium.copyWith(
                fontSize: 13,
                color: AppColors.text,
              ),
            ),
          ),
          Text(
            prixLabel,
            style: AppTextStyles.titleSmall.copyWith(
              fontFamily: 'Poppins',
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}
