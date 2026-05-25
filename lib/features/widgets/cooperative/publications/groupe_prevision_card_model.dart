import 'package:flutter/material.dart';

/// Statut affiche dans la chip du bas d'une carte groupe de prevision :
/// `agregeable` (vert) = pret a etre publie sur le marche,
/// `delaiCourt` (orange) = livraison sous 7 jours,
/// `minFournisseurs` (gris) = manque de fournisseurs (< 2).
enum StatutChipPrevision { agregeable, delaiCourt, minFournisseurs }

/// Carte de prevision agregee par produit cote UI. Construite a partir
/// des `Prevision` membres + catalogue `Produit` dans la page
/// `PrevisionsMembresPage`.
class GroupePrevisionCardModel {
  const GroupePrevisionCardModel({
    required this.produit,
    required this.icon,
    required this.nbPrev,
    required this.cumulKg,
    required this.fenetreLivraison,
    required this.chipStatus,
  });

  final String produit;
  final IconData icon;
  final int nbPrev;
  final int cumulKg;
  final String fenetreLivraison;
  final StatutChipPrevision chipStatus;
}
