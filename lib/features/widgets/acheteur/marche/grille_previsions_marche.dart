import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../models/prevision.dart';
import '../../../../models/produit.dart';
import '../../../../routing/route_names.dart';
import 'carte_prevision_marche.dart';
import 'etat_vide_marche.dart';

/// Grille 2 colonnes des prévisions de récolte du marché. Affiche
/// l'état vide quand la liste est vide. Chaque carte route vers la
/// page de détail prévision.
class GrillePrevisionsMarche extends StatelessWidget {
  const GrillePrevisionsMarche({
    required this.previsions,
    required this.produitsParId,
    super.key,
  });

  final List<Prevision> previsions;
  final Map<String, Produit> produitsParId;

  @override
  Widget build(BuildContext context) {
    if (previsions.isEmpty) {
      return const EtatVideMarche(
        message:
            'Aucune prévision pour le moment — reviens dans quelques jours.',
      );
    }
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        mainAxisExtent: 230,
      ),
      itemCount: previsions.length,
      itemBuilder: (context, i) {
        final p = previsions[i];
        final nomProduit = produitsParId[p.produitId]?.nom ?? 'Prévision';
        return CartePrevisionMarche(
          prevision: p,
          nomProduit: nomProduit,
          onTap: () =>
              context.push(RouteNames.acheteurPrevisionDetailPathFor(p.id)),
        );
      },
    );
  }
}
