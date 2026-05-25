import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Vert pâle pour fonds des chips/labels positifs (qualité, info acompte…)
/// sur la page détail prévision côté acheteur.
const Color kPrevisionDetailPrimarySoft = Color(0xFFE8F5E9);

/// Jaune doré pour l'étoile de rating dans la section vendeur.
const Color kPrevisionDetailWarn = Color(0xFFF9A825);

/// Orange du badge "Prévision · disponible le …" sur le hero de la page.
const Color kPrevisionDetailBadgeOrange = Color(0xFFFB923C);

/// Photo de repli (maïs) utilisée comme hero si le backend n'expose pas
/// d'image dédiée pour la prévision affichée.
const String kPrevisionDetailHeroFallback =
    'https://images.unsplash.com/photo-1601493700631-2b16ec4b4716?w=800&h=450&fit=crop&auto=format';

/// Formatter numérique partagé par la page et ses widgets (séparateur fr).
final NumberFormat kPrevisionDetailNumFmt = NumberFormat('#,##0', 'fr_FR');

/// Données de repli utilisées quand le backend ne renvoie rien — fidèle à
/// la maquette `mockups/acheteur/prevision_detail.html`.
class PrevisionDetailMock {
  const PrevisionDetailMock({
    required this.nom,
    required this.qualite,
    required this.prixPrev,
    required this.qteTotalePrev,
    required this.qteReservee,
    required this.disponibleLe,
    required this.acompte10pct,
    required this.vendeurAnonymise,
  });

  final String nom;
  final String qualite;
  final int prixPrev;
  final int qteTotalePrev;
  final int qteReservee;
  final String disponibleLe;
  final int acompte10pct;
  final String vendeurAnonymise;
}

/// Valeurs par défaut affichées si la prévision n'est pas trouvée backend.
const PrevisionDetailMock kPrevisionDetailMock = PrevisionDetailMock(
  nom: 'Maïs blanc',
  qualite: 'Standard',
  prixPrev: 350,
  qteTotalePrev: 1000,
  qteReservee: 600,
  disponibleLe: 'Disponible le 15 juin',
  acompte10pct: 17500,
  vendeurAnonymise: 'Yao K.',
);
