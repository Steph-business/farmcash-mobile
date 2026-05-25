import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_text_styles.dart';

const Color _kPrimarySoft = Color(0xFFE8F5E9);

/// Chip indiquant si un véhicule est actif ou inactif (libellé en
/// majuscules, fond pastel selon l'état).
class ChipStatutVehicule extends StatelessWidget {
  const ChipStatutVehicule({required this.actif, super.key});

  final bool actif;

  @override
  Widget build(BuildContext context) {
    final bg = actif ? _kPrimarySoft : AppColors.surfaceSoft;
    final fg = actif ? AppColors.primary : AppColors.textSecondary;
    final label = actif ? 'Actif' : 'Inactif';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label.toUpperCase(),
        style: AppTextStyles.labelSmall.copyWith(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: fg,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}
