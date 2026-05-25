import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_text_styles.dart';
import 'kyc_doc_type_kyc.dart';

/// Chip d'etat d'un document KYC : Valide (vert), Refuse (rouge), En
/// attente (bleu). Tout autre statut fallback sur « En attente ».
class StatusChipKyc extends StatelessWidget {
  const StatusChipKyc({required this.status, super.key});

  final String status;

  @override
  Widget build(BuildContext context) {
    late final String label;
    late final Color fg;
    late final Color bg;
    switch (status) {
      case 'VALIDATED':
        label = 'Validé';
        fg = AppColors.primary;
        bg = kPrimarySoftKyc;
        break;
      case 'REJECTED':
        label = 'Refusé';
        fg = AppColors.error;
        bg = const Color(0xFFFDECEA);
        break;
      case 'PENDING':
      default:
        label = 'En attente';
        fg = const Color(0xFF1D4ED8);
        bg = const Color(0xFFDBEAFE);
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: AppTextStyles.labelSmall.copyWith(
          color: fg,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
