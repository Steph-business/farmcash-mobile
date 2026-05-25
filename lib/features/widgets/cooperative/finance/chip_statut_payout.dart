import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_text_styles.dart';
import 'format_montant_fcfa.dart';

const Color _kPrimarySoft = Color(0xFFE8F5E9);

/// Puce affichant le statut d'un payout (En attente / En cours / etc.).
/// Style : fond primary-soft, libelle primaire.
class ChipStatutPayout extends StatelessWidget {
  const ChipStatutPayout({required this.status, super.key});

  /// Statut brut backend (PENDING / PROCESSING / COMPLETED / FAILED).
  final String status;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _kPrimarySoft,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        statusPayoutLabel(status),
        style: AppTextStyles.labelSmall.copyWith(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: AppColors.primary,
        ),
      ),
    );
  }
}
