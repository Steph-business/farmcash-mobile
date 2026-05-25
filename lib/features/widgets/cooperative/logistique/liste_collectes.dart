import 'package:flutter/material.dart';

import '../../../../models/coop_collection.dart';
import 'etat_vide_logistique.dart';
import 'ligne_collecte.dart';

/// Liste des collectes planifiees et en cours. Affiche un etat vide si
/// rien n'est planifie, sinon une colonne de `LigneCollecte` qui declenche
/// `onAction(collecte)` au tap.
class ListeCollectes extends StatelessWidget {
  const ListeCollectes({
    required this.collections,
    required this.onAction,
    super.key,
  });

  final List<CoopCollection> collections;
  final void Function(CoopCollection collection) onAction;

  @override
  Widget build(BuildContext context) {
    if (collections.isEmpty) {
      return const EtatVideLogistique(
        icon: Icons.calendar_today_outlined,
        message: 'Aucune collecte planifiée',
        hint: 'Créez une collecte pour aller chercher la marchandise '
            'chez un membre.',
      );
    }
    return Column(
      children: [
        for (final c in collections) ...[
          LigneCollecte(
            collection: c,
            onAction: () => onAction(c),
          ),
          const SizedBox(height: 10),
        ],
      ],
    );
  }
}
