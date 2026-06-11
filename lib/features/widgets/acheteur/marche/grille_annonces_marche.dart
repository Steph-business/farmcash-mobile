import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../models/annonce_vente.dart';
import '../../../../models/produit.dart';
import '../../../../routing/route_names.dart';
import 'carte_annonce_marche.dart';
import 'etat_vide_marche.dart';
import 'offre_marche.dart';

/// Grille 2 colonnes des offres marché (annonces solo producteurs +
/// publications coop unifiées via `OffreMarche`). Tap → route vers la
/// bonne page détail selon `isPublicationCoop`.
///
/// Refonte 2026-06-06 : consomme `OffreMarche` au lieu de `AnnonceVente`
/// pour intégrer les publications coop (auparavant invisibles côté
/// acheteur — bug majeur de découverte des lots agrégés).
class GrilleAnnoncesMarche extends StatelessWidget {
  const GrilleAnnoncesMarche({
    required this.offres,
    required this.produitsParId,
    super.key,
  });

  final List<OffreMarche> offres;
  final Map<String, Produit> produitsParId;

  @override
  Widget build(BuildContext context) {
    if (offres.isEmpty) {
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
      itemCount: offres.length,
      itemBuilder: (context, i) {
        final o = offres[i];
        final nomProduit = produitsParId[o.produitId]?.nom;
        // Cas 1 : annonce solo → carte + tap direct vers détail annonce.
        if (o.annonceSource != null) {
          return CarteAnnonceMarche(
            annonce: o.annonceSource!,
            nomProduit: nomProduit,
            onTap: () => context.push(
              RouteNames.acheteurAnnonceDetailPathFor(o.id),
            ),
          );
        }
        // Cas 2 : publication coop → synthèse pseudo-AnnonceVente pour
        // réutiliser la carte (qui attend AnnonceVente) + tap vers la
        // page détail publication coop dédiée acheteur.
        final pseudo = _pseudoAnnonceDepuisOffre(o);
        return CarteAnnonceMarche(
          annonce: pseudo,
          nomProduit: nomProduit,
          onTap: () => context.push(
            RouteNames.acheteurPublicationCoopDetailPathFor(o.id),
          ),
        );
      },
    );
  }
}

/// Construit une `AnnonceVente` synthétique à partir d'une `OffreMarche`
/// pour utiliser la carte existante `CarteAnnonceMarche` (qui attend
/// `AnnonceVente`). Champs non disponibles côté publication coop publique
/// (description, vendeur, traitements) restent null/vides — la carte
/// tolère déjà l'absence.
AnnonceVente _pseudoAnnonceDepuisOffre(OffreMarche o) {
  final pub = o.publicationCoopSource!;
  return AnnonceVente(
    id: pub.id,
    // farmerId est requis : on utilise cooperativeId comme placeholder
    // (la carte ne route pas vers vendeur via farmerId).
    farmerId: pub.cooperativeId,
    produitId: pub.produitId,
    titre: pub.titre,
    quantiteKg: pub.quantiteKg,
    prixParKg: pub.prixParKg,
    qualite: pub.qualite,
    photos: pub.photos,
    status: pub.status,
    createdAt: pub.createdAt,
    updatedAt: pub.updatedAt,
    description: pub.description,
    // Date de récolte = min des annonces sources (fraîcheur).
    dateRecolte: o.dateRecolte,
    // Marque comme « lot coop » via assignedToCooperativeId — la carte
    // affiche déjà un badge selon ce champ.
    assignedToCooperativeId: pub.cooperativeId,
  );
}
