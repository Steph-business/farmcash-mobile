import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_text_styles.dart';

const Color _kPrimarySoft = Color(0xFFE8F5E9);
const Color _kOrangeSoft = Color(0xFFFFF3E0);
const Color _kOrange = Color(0xFFE65100);

/// Chip affiché en haut à droite de la carte d'une offre reçue par la
/// coopérative : indique « Public » (vert) ou « Coop ciblée » (orange).
class ChipBadgeOffre extends StatelessWidget {
  const ChipBadgeOffre({
    super.key,
    required this.label,
    required this.isPublic,
  });

  final String label;
  final bool isPublic;

  @override
  Widget build(BuildContext context) {
    final bg = isPublic ? _kPrimarySoft : _kOrangeSoft;
    final fg = isPublic ? AppColors.primary : _kOrange;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: AppTextStyles.labelSmall.copyWith(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: fg,
        ),
      ),
    );
  }
}
