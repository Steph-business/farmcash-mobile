import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../models/livraison.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';

const Color _kPrimarySoft = Color(0xFFE8F5E9);
const BorderRadius _kBrCard = BorderRadius.all(Radius.circular(12));
final NumberFormat _nf = NumberFormat('#,##0', 'fr_FR');

/// Carte « Rémunération transporteur » d'une demande entrante : affiche le
/// prix devis ou final, ou « À négocier » si aucun prix n'est encore fixé.
class CarteMontantDemande extends StatelessWidget {
  const CarteMontantDemande({required this.mission, super.key});

  final Livraison mission;

  @override
  Widget build(BuildContext context) {
    final prix = mission.prixDevis ?? mission.prixFinal;
    final prixLabel =
        prix != null ? '+${_nf.format(prix.round())} F' : 'À négocier';
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _kPrimarySoft,
        borderRadius: _kBrCard,
        border: Border.all(
          color: AppColors.border,
          width: AppDimens.borderThin,
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.payments_outlined,
            size: 18,
            color: AppColors.primary,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Rémunération transporteur',
              style: AppTextStyles.bodyMedium.copyWith(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            prixLabel,
            style: AppTextStyles.titleSmall.copyWith(
              fontFamily: 'Poppins',
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}
