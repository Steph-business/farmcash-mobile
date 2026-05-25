import 'package:flutter/material.dart';

import 'tuile_transaction.dart';

/// Mock fidèle à la maquette HTML du wallet producteur — affiché en
/// fallback quand l'endpoint `/finance/wallet` n'est pas joignable ou
/// retourne une liste vide. Centralisé ici pour ne pas alourdir la page.
const List<ItemTransaction> kMockTransactionsProducteur = [
  ItemTransaction(
    icon: Icons.arrow_downward,
    entree: true,
    titre: 'Vente Manioc 1 t',
    sousTitre: 'hier · Industries Agricoles SA',
    montant: '+95 000 F',
  ),
  ItemTransaction(
    icon: Icons.arrow_downward,
    entree: true,
    titre: 'Acompte prévision Yao K.',
    sousTitre: '14/05 · Prévision Maïs',
    montant: '+7 000 F',
  ),
  ItemTransaction(
    icon: Icons.arrow_upward,
    entree: false,
    titre: 'Retrait MoMo',
    sousTitre: '12/05 · Orange Money',
    montant: '-50 000 F',
  ),
  ItemTransaction(
    icon: Icons.arrow_downward,
    entree: true,
    titre: 'Vente Maïs 500 kg',
    sousTitre: '10/05 · Restaurant Le Baoulé',
    montant: '+169 750 F',
  ),
  ItemTransaction(
    icon: Icons.arrow_upward,
    entree: false,
    titre: 'Frais plateforme',
    sousTitre: '10/05 · 3% vente Maïs',
    montant: '-5 250 F',
  ),
  ItemTransaction(
    icon: Icons.arrow_downward,
    entree: true,
    titre: 'Avance coopérative',
    sousTitre: '08/05 · COOP-AGRI Lagunes',
    montant: '+5 000 F',
  ),
  ItemTransaction(
    icon: Icons.arrow_upward,
    entree: false,
    titre: 'Retrait MoMo',
    sousTitre: '05/05 · Orange Money',
    montant: '-30 000 F',
  ),
  ItemTransaction(
    icon: Icons.arrow_downward,
    entree: true,
    titre: 'Vente Tomate 35 kg',
    sousTitre: '03/05 · Marie Yao',
    montant: '+42 000 F',
  ),
];
