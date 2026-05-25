import 'package:flutter/material.dart';

import '../../../../models/enums.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_text_styles.dart';
import 'offre_modeles.dart';

/// Petit chip d'état d'une offre côté FARMER (en attente, acceptée, etc.).
class ChipStatutOffre extends StatelessWidget {
  const ChipStatutOffre({super.key, required this.status});

  final NegotiationStatus status;

  @override
  Widget build(BuildContext context) {
    final (bg, fg, label) = _spec();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: AppTextStyles.labelSmall.copyWith(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: fg,
          letterSpacing: 0.4,
        ),
      ),
    );
  }

  (Color, Color, String) _spec() {
    switch (status) {
      case NegotiationStatus.pending:
        return (kWarnSoft, kWarn, 'EN ATTENTE');
      case NegotiationStatus.accepted:
        return (kPrimarySoft, AppColors.primary, 'ACCEPTÉE');
      case NegotiationStatus.rejected:
        return (kRedSoft, AppColors.error, 'REFUSÉE');
      case NegotiationStatus.counterOffered:
        return (kWarnSoft, kWarn, 'CONTRE-OFFRE');
      case NegotiationStatus.cancelled:
        return (const Color(0xFFE5E7EB), AppColors.textSecondary, 'ANNULÉE');
      case NegotiationStatus.unknown:
        return (const Color(0xFFE5E7EB), AppColors.textSecondary, '—');
    }
  }
}
