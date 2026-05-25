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

const List<PubMock> kPubsMockCoop = [
  PubMock(
    id: 'PUB-001',
    titre: 'Maïs grain blanc',
    quantite: '4 500 kg agrégés',
    prix: '350 F/kg',
  ),
  PubMock(
    id: 'PUB-002',
    titre: 'Manioc frais',
    quantite: '6 200 kg agrégés',
    prix: '200 F/kg',
  ),
  PubMock(
    id: 'PUB-003',
    titre: 'Cacao fèves',
    quantite: '1 800 kg agrégés',
    prix: '1 250 F/kg',
  ),
];

const List<SollicitationMock> kSollicitationsMockCoop = [
  SollicitationMock(
    id: 'SOL-001',
    titre: 'Cacao fèves · 500 kg demandés',
    date: 'il y a 2 j',
  ),
  SollicitationMock(
    id: 'SOL-002',
    titre: 'Maïs blanc · 300 kg demandés',
    date: 'il y a 5 j',
  ),
  SollicitationMock(
    id: 'SOL-003',
    titre: 'Manioc · 800 kg demandés',
    date: 'il y a 1 sem',
  ),
];

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
