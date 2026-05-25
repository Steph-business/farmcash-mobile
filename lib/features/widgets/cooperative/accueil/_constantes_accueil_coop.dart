import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';

// ─── COULEURS LOCALES (palette UNIFIÉE brand vert) ────────────────────
//
// Avant : 3 palettes accent (bleu / orange / jaune) pour différencier
// visuellement les KPI / raccourcis / activité. Trop multicolore par
// rapport à l'identité brand vert de FarmCash. Sur instruction
// utilisateur, on unifie tout à la **palette vert primary** + pastel
// vert pour les fonds doux. Les couleurs sémantiques d'alerte (warn /
// error) restent disponibles via `AppColors` quand un état nécessite
// vraiment de l'attention (litige, erreur), pas pour de la déco.

const Color kPrimarySoftCoop = Color(0xFFE8F5E9);

/// Anciens accents bleu / orange / jaune → tous remplacés par le vert
/// brand pour respecter l'identité visuelle FarmCash. Les widgets qui
/// utilisent ces constantes voient donc le même vert partout.
const Color kInfoSoftCoop = kPrimarySoftCoop;
final Color kInfoAccentCoop = AppColors.primary;
const Color kWarnSoftCoop = kPrimarySoftCoop;
final Color kWarnAccentCoop = AppColors.primary;
const Color kHighlightSoftCoop = kPrimarySoftCoop;
final Color kHighlightAccentCoop = AppColors.primary;

// Radius des cards et du hero — conformes au pattern producteur :
// 14 pour les cards photo / liste, 16 pour le CTA hero unique.
const BorderRadius kBrCardCoop = BorderRadius.all(Radius.circular(14));
const BorderRadius kBrHeroCoop = BorderRadius.all(Radius.circular(16));

// Photos statiques "Outils intelligents" (Unsplash — illustration neutre).
const String kPhotoAssistantGestionCoop =
    'https://images.unsplash.com/photo-1625246333195-78d9c38ad449?w=400&h=300&fit=crop&auto=format';
const String kPhotoConseilsSaisonCoop =
    'https://images.unsplash.com/photo-1464226184884-fa280b87c399?w=400&h=300&fit=crop&auto=format';

/// Génère 2 lettres depuis un id/nom — utile pour avatar placeholder.
String initialesAccueilCoop(String input) {
  final trimmed = input.trim();
  if (trimmed.isEmpty) return '?';
  // Si plusieurs mots → première lettre de chaque (max 2).
  final parts = trimmed.split(RegExp(r'[\s\-_]+'))
    ..removeWhere((p) => p.isEmpty);
  if (parts.length >= 2) {
    return (parts[0].substring(0, 1) + parts[1].substring(0, 1)).toUpperCase();
  }
  // Sinon : 2 premiers caractères du mot.
  if (trimmed.length == 1) return trimmed.toUpperCase();
  return trimmed.substring(0, 2).toUpperCase();
}
