import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_text_styles.dart';

/// Petit titre de section utilisé dans la page paiement (« Mode de
/// livraison », « Montants », etc.).
///
/// Style minimal différent de [SectionTitre] commun : pas d'encadré, pas
/// de mise en capitales — un simple texte gras juste au-dessus du bloc
/// suivant.
class TitreSectionPaiement extends StatelessWidget {
  const TitreSectionPaiement(this.texte, {super.key});

  final String texte;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 2, bottom: 4),
      child: Text(
        texte,
        style: AppTextStyles.titleSmall.copyWith(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: AppColors.text,
        ),
      ),
    );
  }
}
