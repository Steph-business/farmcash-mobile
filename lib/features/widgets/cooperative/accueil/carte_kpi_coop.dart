import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';
import '_constantes_accueil_coop.dart';

/// Card KPI individuelle de l'accueil coopérative : icône colorée en haut,
/// valeur en gras puis label. Background pastel + accent assorti pour
/// distinguer visuellement chaque indicateur (membres, stock, solde…).
class CarteKpiCoop extends StatelessWidget {
  const CarteKpiCoop({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
    required this.background,
    required this.accent,
  });

  final IconData icon;
  final String value;
  final String label;

  /// Background pastel doux de la card (ex: kPrimarySoftCoop, kInfoSoftCoop…).
  final Color background;

  /// Couleur d'accent assortie utilisée pour le cercle de l'icône.
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      decoration: BoxDecoration(
        color: background,
        borderRadius: kBrCardCoop,
        border: Border.all(color: AppColors.border, width: AppDimens.borderThin),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: accent,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Icon(
              icon,
              size: 18,
              color: AppColors.onPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.titleSmall.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.2,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 10,
              color: AppColors.textSecondary,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}
