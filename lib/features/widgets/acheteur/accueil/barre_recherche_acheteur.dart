import 'package:flutter/material.dart';

import '../../communs/barre_recherche_commune.dart';

/// Barre de recherche compacte affichée sous le header de l'accueil
/// acheteur. Délègue au widget commun pour rester identique aux autres
/// barres (Marché, Messages, etc.). Tap → page recherche dédiée.
class BarreRechercheAcheteur extends StatelessWidget {
  const BarreRechercheAcheteur({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return BarreRechercheCommune(
      placeholder: 'Rechercher un produit, une région…',
      onTap: onTap,
    );
  }
}
