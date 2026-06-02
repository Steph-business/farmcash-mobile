import 'package:flutter/material.dart';

import '../../communs/barre_recherche_commune.dart';

/// Barre de recherche du header marché — réutilise le widget commun pour
/// garder un style strictement identique aux autres barres de l'app.
/// Tap → navigue vers la page recherche dédiée (à brancher).
class BarreRechercheMarche extends StatelessWidget {
  const BarreRechercheMarche({super.key, this.onTap});

  /// Callback au tap. `null` → la barre devient un visuel statique
  /// (utile en attendant le câblage de la page recherche).
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return BarreRechercheCommune(
      placeholder: 'Rechercher un produit, un vendeur…',
      // Si pas de onTap, on en met un vide pour rester tappable visuel
      // (sinon l'assert du widget commun lèverait).
      onTap: onTap ?? () {},
    );
  }
}
