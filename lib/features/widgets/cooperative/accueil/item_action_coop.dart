import 'package:flutter/material.dart';

/// Données d'un item de la liste "Actions à traiter" : icône, libellés,
/// couleurs d'accent (info / warning / primary), compteur affiché dans le
/// badge, et callback d'ouverture.
class DonneesItemActionCoop {
  DonneesItemActionCoop({
    required this.icon,
    required this.titre,
    required this.sousTitre,
    required this.accent,
    required this.accentSoft,
    required this.count,
    required this.onTap,
  });

  final IconData icon;
  final String titre;
  final String sousTitre;

  /// Couleur d'accent sémantique (info / warning / primary). Utilisée pour
  /// le fond de l'icône et le badge compteur.
  final Color accent;

  /// Variante "soft" de la couleur d'accent — gardée pour usages futurs
  /// (background ligne, surlignage…). Non utilisée pour rester sobre.
  final Color accentSoft;

  /// Compteur affiché dans le badge de bout de ligne.
  final int count;

  final VoidCallback onTap;
}
