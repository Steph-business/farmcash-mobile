import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';

/// Couleur de fond verte douce utilisée par les icônes "accent" des tuiles
/// de profil (sections principales : identité, finance, exploitation…).
const Color kVertProfilDoux = Color(0xFFE8F5E9);

/// Carré arrondi de 34px contenant une icône — réutilisable par toutes
/// les tuiles des pages profil des 4 rôles.
///
/// Si [accent] est vrai, fond vert pâle + icône `AppColors.primary`. Sinon
/// fond `AppColors.surfaceSoft` + icône `AppColors.textSecondary` (sections
/// applicatives : paramètres, aide).
class IconeTuileProfil extends StatelessWidget {
  /// Construit l'icône carrée.
  const IconeTuileProfil({
    super.key,
    required this.icone,
    this.accent = false,
  });

  /// Icône Material affichée.
  final IconData icone;

  /// Mode "accent" (vert primaire) si vrai.
  final bool accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        color: accent ? kVertProfilDoux : AppColors.surfaceSoft,
        borderRadius: BorderRadius.circular(AppDimens.radius),
      ),
      alignment: Alignment.center,
      child: Icon(
        icone,
        size: 18,
        color: accent ? AppColors.primary : AppColors.textSecondary,
      ),
    );
  }
}
