import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../models/annonce_vente.dart';
import '../../../../models/produit.dart';
import '../../../../routing/route_names.dart';
import 'carte_annonce_marche.dart';
import 'etat_vide_marche.dart';

/// Grille 2 colonnes des annonces de vente du marché. Affiche l'état
/// vide quand la liste est vide. Chaque carte route vers la page de
/// détail annonce.
class GrilleAnnoncesMarche extends StatelessWidget {
  const GrilleAnnoncesMarche({
    required this.annonces,
    required this.produitsParId,
    super.key,
  });

  final List<AnnonceVente> annonces;
  final Map<String, Produit> produitsParId;

  @override
  Widget build(BuildContext context) {
    if (annonces.isEmpty) {
      return const EtatVideMarche(
        message: 'Aucune annonce disponible pour le moment.',
      );
    }
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        mainAxisExtent: 270,
      ),
      itemCount: annonces.length,
      itemBuilder: (context, i) {
        final a = annonces[i];
        final nomProduit = a.produitNom ?? produitsParId[a.produitId]?.nom;
        return CarteAnnonceMarche(
          annonce: a,
          nomProduit: nomProduit,
          onTap: () =>
              context.push(RouteNames.acheteurAnnonceDetailPathFor(a.id)),
        );
      },
    );
  }
}
