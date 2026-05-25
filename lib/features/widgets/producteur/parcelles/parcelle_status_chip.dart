import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_text_styles.dart';

const Color _kPrimarySoft = Color(0xFFE8F5E9);
const Color _kWarnSoft = Color(0xFFFFF8E1);
const Color _kWarn = Color(0xFFB26A00);

/// Étiquette de statut d'une culture sur la parcelle.
///
/// Variante "warn" (orange) pour "À semer", verte sinon pour les
/// cultures en production.
class ParcelleStatusChip extends StatelessWidget {
  const ParcelleStatusChip({
    required this.label,
    required this.isWarn,
    super.key,
  });

  final String label;
  final bool isWarn;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isWarn ? _kWarnSoft : _kPrimarySoft,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: AppTextStyles.labelSmall.copyWith(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: isWarn ? _kWarn : AppColors.primary,
        ),
      ),
    );
  }
}
