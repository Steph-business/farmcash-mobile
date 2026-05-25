import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_text_styles.dart';
import 'accueil_constants.dart';
import 'accueil_helpers.dart';

/// Placeholder du logo de coopérative quand l'URL est manquante ou en cours
/// de chargement : bulle vert pâle + initiales du nom de la coop.
class CoopLogoPlaceholder extends StatelessWidget {
  const CoopLogoPlaceholder({super.key, required this.nom});

  final String nom;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: kAccueilPrimarySoft,
      alignment: Alignment.center,
      child: Text(
        initialesAccueil(nom),
        style: AppTextStyles.labelSmall.copyWith(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: AppColors.primary,
        ),
      ),
    );
  }
}
