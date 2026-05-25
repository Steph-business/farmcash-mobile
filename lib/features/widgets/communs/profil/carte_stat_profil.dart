import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';
import 'groupe_profil.dart' show kRayonGroupeProfil;

/// Carte statistique compacte affichée en ligne (3 par ligne) sur les
/// pages profil transporteur et coopérative.
///
/// Affiche une [valeur] en gros vert primaire (16px, gras) et un [libelle]
/// en petit gris secondaire (11px) sous-jacent, le tout centré dans une
/// carte fond blanc + bordure 1px + radius 14.
class CarteStatProfil extends StatelessWidget {
  /// Construit la carte stat.
  const CarteStatProfil({
    super.key,
    required this.valeur,
    required this.libelle,
  });

  /// Valeur principale (formatée par l'appelant).
  final String valeur;

  /// Libellé descriptif (ex : "Livraisons", "Distributions"…).
  final String libelle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: kRayonGroupeProfil,
        border: Border.all(
          color: AppColors.border,
          width: AppDimens.borderThin,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            valeur,
            textAlign: TextAlign.center,
            style: AppTextStyles.titleLarge.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
              letterSpacing: -0.3,
              height: 1.2,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            libelle,
            textAlign: TextAlign.center,
            style: AppTextStyles.labelSmall.copyWith(
              fontSize: 11,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w400,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
