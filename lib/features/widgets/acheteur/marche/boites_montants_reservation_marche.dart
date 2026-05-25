import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';

final NumberFormat _nf = NumberFormat('#,##0', 'fr_FR');

/// Boite affichant l'acompte de 10% a payer maintenant.
class AcompteBoxReservationMarche extends StatelessWidget {
  const AcompteBoxReservationMarche({super.key, required this.montant});

  final int montant;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: AppColors.primary, width: AppDimens.borderThin),
      ),
      child: Column(
        children: [
          Text(
            'Tu paies aujourd\'hui',
            style: AppTextStyles.labelSmall.copyWith(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${_nf.format(montant)} F',
            style: AppTextStyles.displayLarge.copyWith(
              fontFamily: 'Poppins',
              fontSize: 36,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
              letterSpacing: -0.8,
            ),
          ),
        ],
      ),
    );
  }
}

/// Boite affichant le reste a payer (90%) et la date prevue.
class ResteBoxReservationMarche extends StatelessWidget {
  const ResteBoxReservationMarche({
    super.key,
    required this.montant,
    required this.libelle,
  });

  final int montant;
  final String libelle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border:
            Border.all(color: AppColors.border, width: AppDimens.borderThin),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            libelle,
            style: AppTextStyles.bodySmall.copyWith(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            '${_nf.format(montant)} F',
            style: AppTextStyles.titleSmall.copyWith(
              fontFamily: 'Poppins',
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
