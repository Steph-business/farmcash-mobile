import 'package:flutter/material.dart';

import '../../../../models/enums.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_text_styles.dart';

const Color _kPrimarySoft = Color(0xFFE8F5E9);
const Color _kWarnSoft = Color(0xFFFEF3C7);
const Color _kWarn = Color(0xFFB45309);

/// Badge coloré indiquant le statut d'une mission transporteur dans la
/// liste : « À accepter », « Acceptée », « Enlèvement », « En route »,
/// « Livrée », « Annulée », ou « — ».
class BadgeStatutMission extends StatelessWidget {
  const BadgeStatutMission({super.key, required this.status});

  final ShipmentStatus status;

  @override
  Widget build(BuildContext context) {
    final (bg, fg, label) = _spec();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 5,
            height: 5,
            decoration: BoxDecoration(color: fg, shape: BoxShape.circle),
          ),
          const SizedBox(width: 5),
          Text(
            label.toUpperCase(),
            style: AppTextStyles.labelSmall.copyWith(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: fg,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  (Color, Color, String) _spec() {
    switch (status) {
      case ShipmentStatus.requested:
        return (_kWarnSoft, _kWarn, 'À accepter');
      case ShipmentStatus.accepted:
        return (_kPrimarySoft, AppColors.primary, 'Acceptée');
      case ShipmentStatus.loading:
        return (_kPrimarySoft, AppColors.primary, 'Enlèvement');
      case ShipmentStatus.inTransit:
        return (_kPrimarySoft, AppColors.primary, 'En route');
      case ShipmentStatus.delivered:
        return (_kPrimarySoft, AppColors.primary, 'Livrée');
      case ShipmentStatus.cancelled:
        return (const Color(0xFFE5E7EB), AppColors.textSecondary, 'Annulée');
      case ShipmentStatus.unknown:
        return (const Color(0xFFE5E7EB), AppColors.textSecondary, '—');
    }
  }
}
