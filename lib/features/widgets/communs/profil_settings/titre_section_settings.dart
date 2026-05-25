import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';

/// Titre d'une section "Profil & paramètres".
///
/// Petit label gras affiché au-dessus d'un [GroupeSettings]. Style iOS
/// Settings : libellé tel quel (capitalisation décidée par l'appelant)
/// avec petit padding latéral pour s'aligner sur l'intérieur des cartes.
class TitreSectionSettings extends StatelessWidget {
  /// Construit le titre avec son libellé.
  const TitreSectionSettings(this.label, {super.key});

  /// Libellé affiché.
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 2,
        right: 4,
        bottom: 6,
        top: AppDimens.space12,
      ),
      child: Text(
        label,
        style: AppTextStyles.titleSmall.copyWith(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: AppColors.text,
        ),
      ),
    );
  }
}
