import 'package:flutter/material.dart';

/// Vert pâle pour fonds des chips et tuiles sélectionnées sur la page
/// "Publier une demande" côté acheteur.
const Color kPublierDemandePrimarySoft = Color(0xFFE8F5E9);

/// Photo de repli (maïs) utilisée quand un produit du catalogue n'a pas
/// d'image associée côté backend.
const String kPublierDemandeMaisPhoto =
    'https://images.unsplash.com/photo-1601493700631-2b16ec4b4716?w=600&h=300&fit=crop&auto=format';

/// Photo dédiée pour le manioc — choisie via heuristique sur le nom du
/// produit dans la liste catalogue.
const String kPublierDemandeManiocPhoto =
    'https://images.unsplash.com/photo-1574484284002-952d92456975?w=600&h=300&fit=crop&auto=format';

/// Photo dédiée pour la tomate — choisie via heuristique sur le nom du
/// produit dans la liste catalogue.
const String kPublierDemandeTomatePhoto =
    'https://images.unsplash.com/photo-1518977956812-cd3dbadaaf31?w=600&h=300&fit=crop&auto=format';

/// Liste des qualités sélectionnables via les chips.
const List<String> kPublierDemandeQualites = [
  'Standard',
  'Premium',
  'Bio',
  'Équitable',
];

/// Option produit affichable dans le bottom-sheet de sélection. Construit
/// à partir d'un `Produit` du backend + heuristique photo.
class PublierDemandeProduitOption {
  const PublierDemandeProduitOption({
    required this.id,
    required this.nom,
    required this.photoUrl,
  });

  final String id;
  final String nom;
  final String photoUrl;
}

/// Option coopérative affichable dans le dropdown "cible spécifique".
class PublierDemandeCoopOption {
  const PublierDemandeCoopOption({required this.id, required this.nom});

  final String id;
  final String nom;
}

/// Catalogue local des coopératives proposables. À remplacer par un
/// provider backend quand la sélection coop côté acheteur sera branchée.
const List<PublierDemandeCoopOption> kPublierDemandeCoops = [
  PublierDemandeCoopOption(id: 'coop-agri', nom: 'COOP-AGRI Lagunes'),
  PublierDemandeCoopOption(id: 'coop-saveurs', nom: 'COOP Saveurs Sud'),
  PublierDemandeCoopOption(id: 'coop-bouake', nom: 'COOP Bouaké Centre'),
];

/// Cible d'une demande d'achat — public, toutes les coops ou une coop précise.
enum PublierDemandeCible { public, allCoops, specificCoop }
