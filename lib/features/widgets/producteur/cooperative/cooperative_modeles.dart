import 'package:flutter/material.dart';

/// Couleurs locales partagées entre les widgets "Ma coopérative".
const Color kPrimarySoftCoop = Color(0xFFE8F5E9);
const Color kWarnSoftCoop = Color(0xFFFFF8E1);
const Color kWarnCoop = Color(0xFFB26A00);
const BorderRadius kBrCardCoop = BorderRadius.all(Radius.circular(12));

/// Logo mock pour la coop par défaut (en attendant le vrai endpoint).
const String kLogoMockCoop =
    'https://images.unsplash.com/photo-1530507629858-e3759c3b9d4f'
    '?w=200&h=200&fit=crop&auto=format';

/// Publication mock pour la liste "Publications en cours".
class PubMock {
  final String id;
  final String titre;
  final String quantite;
  final String prix;
  const PubMock({
    required this.id,
    required this.titre,
    required this.quantite,
    required this.prix,
  });
}

/// Sollicitation mock pour la liste "Sollicitations" coop.
class SollicitationMock {
  final String id;
  final String titre;
  final String date;
  const SollicitationMock({
    required this.id,
    required this.titre,
    required this.date,
  });
}

// NB : les listes mock `kPubsMockCoop` / `kSollicitationsMockCoop` ont
// été supprimées le 2026-06-02. La page « Ma coopérative » fetche
// désormais les vraies données via `CooperativesService` (cf.
// `cooperative_page.dart` → `_coopBundleProvider`). Les classes
// `PubMock` / `SollicitationMock` ci-dessus restent comme DTOs
// d'affichage légers consommés par les widgets de liste.

/// Renvoie les initiales d'une chaîne (1 ou 2 caractères majuscules).
String initialesCoop(String s) {
  final t = s.trim();
  if (t.isEmpty) return '?';
  final parts = t.split(RegExp(r'[\s\-_]+'))..removeWhere((p) => p.isEmpty);
  if (parts.length >= 2) {
    return (parts[0].substring(0, 1) + parts[1].substring(0, 1)).toUpperCase();
  }
  if (t.length == 1) return t.toUpperCase();
  return t.substring(0, 2).toUpperCase();
}
