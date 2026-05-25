import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../models/enums.dart';
import '../../../../services/orders_service.dart';

/// Couleurs locales (alignées sur la maquette commandes producteur).
const Color kPrimarySoft = Color(0xFFE8F5E9);
const Color kWarnSoft = Color(0xFFFFF8E1);
const Color kWarn = Color(0xFFB26A00);

/// Type sémantique de chip statut commande producteur.
enum ChipKind { warn, green }

/// Action contextuelle sur une commande dans la liste.
enum OrderAction { preparer, livrer, voir }

/// Onglet en haut de la page Commandes producteur.
enum OrderTab { enCours, livrees, annulees }

/// Mapping `OrderStatus` → onglet UI. `unknown` retombe sur `enCours`
/// pour ne pas être invisible si le backend ajoute un nouveau statut
/// non encore connu côté mobile.
OrderTab tabForStatus(OrderStatus s) {
  switch (s) {
    case OrderStatus.delivered:
    case OrderStatus.completed:
      return OrderTab.livrees;
    case OrderStatus.rejected:
    case OrderStatus.cancelled:
    case OrderStatus.disputed:
      return OrderTab.annulees;
    case OrderStatus.sent:
    case OrderStatus.accepted:
    case OrderStatus.inProgress:
    case OrderStatus.unknown:
      return OrderTab.enCours;
  }
}

/// Visualisation (label + chip kind + action) pour un statut de commande.
({String label, ChipKind kind, OrderAction action}) visualForStatus(
  OrderStatus s,
) {
  switch (s) {
    case OrderStatus.sent:
      return (
        label: 'À préparer',
        kind: ChipKind.warn,
        action: OrderAction.preparer,
      );
    case OrderStatus.accepted:
      return (
        label: 'Paiement reçu',
        kind: ChipKind.green,
        action: OrderAction.preparer,
      );
    case OrderStatus.inProgress:
      return (
        label: 'En transit',
        kind: ChipKind.green,
        action: OrderAction.voir,
      );
    case OrderStatus.delivered:
      return (
        label: 'Livrée',
        kind: ChipKind.green,
        action: OrderAction.voir,
      );
    case OrderStatus.completed:
      return (
        label: 'Terminée',
        kind: ChipKind.green,
        action: OrderAction.voir,
      );
    case OrderStatus.rejected:
      return (
        label: 'Rejetée',
        kind: ChipKind.warn,
        action: OrderAction.voir,
      );
    case OrderStatus.cancelled:
      return (
        label: 'Annulée',
        kind: ChipKind.warn,
        action: OrderAction.voir,
      );
    case OrderStatus.disputed:
      return (
        label: 'Litige',
        kind: ChipKind.warn,
        action: OrderAction.voir,
      );
    case OrderStatus.unknown:
      return (
        label: 'Statut inconnu',
        kind: ChipKind.warn,
        action: OrderAction.voir,
      );
  }
}

/// Format "500 kg maïs blanc · 175 000 F" — quantité + produit + montant.
String formatInfoCommande(OrderListItem item) {
  final c = item.commande;
  final qte = c.quantiteKg;
  final qteStr = qte == qte.roundToDouble()
      ? '${qte.toStringAsFixed(0)} kg'
      : '${qte.toStringAsFixed(1)} kg';
  final produit = item.produitNom?.trim();
  final montantFmt = NumberFormat.decimalPattern('fr_FR').format(c.montantTotal);
  if (produit != null && produit.isNotEmpty) {
    return '$qteStr $produit · $montantFmt F';
  }
  return '$qteStr · $montantFmt F';
}

/// Renvoie les initiales d'une chaîne (1 ou 2 caractères majuscules).
String initialesDe(String s) {
  final t = s.trim();
  if (t.isEmpty) return '?';
  final parts = t.split(RegExp(r'[\s\-_]+'))..removeWhere((p) => p.isEmpty);
  if (parts.length >= 2) {
    return (parts[0].substring(0, 1) + parts[1].substring(0, 1)).toUpperCase();
  }
  if (t.length == 1) return t.toUpperCase();
  return t.substring(0, 2).toUpperCase();
}
