import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_text_styles.dart';

/// Ligne label / valeur de la section "Informations" du détail annonce.
/// Label en gris à gauche, valeur en noir aligné à droite — design clé/val.
///
/// Le paramètre [highlight] permet de mettre la valeur en couleur primaire
/// + bold (utile pour le « Montant total » qu'on veut faire ressortir).
class InfoRowAnnonce extends StatelessWidget {
  const InfoRowAnnonce({
    required this.label,
    required this.value,
    this.highlight = false,
    super.key,
  });

  final String label;
  final String value;

  /// Si vrai → valeur en vert primary + bold (mise en valeur).
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            value,
            style: AppTextStyles.bodyMedium.copyWith(
              fontFamily: highlight ? 'Poppins' : null,
              fontSize: highlight ? 14 : 13,
              fontWeight: highlight ? FontWeight.w700 : FontWeight.w600,
              color: highlight ? AppColors.primary : AppColors.text,
            ),
          ),
        ],
      ),
    );
  }
}
