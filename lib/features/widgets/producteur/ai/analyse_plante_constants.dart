import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Vert pâle pour les pastilles d'icône / fonds positifs ("BIO", risque
/// faible) sur la page de diagnostic plante.
const Color kAnalysePlantePrimarySoft = Color(0xFFE8F5E9);

/// Jaune doux pour le fond de la chip "risque moyen".
const Color kAnalysePlanteWarnSoft = Color(0xFFFFF8E1);

/// Brun chaud pour le texte de la chip "risque moyen" (lisible sur
/// `kAnalysePlanteWarnSoft`).
const Color kAnalysePlanteWarn = Color(0xFFB26A00);

/// Rouge pâle pour le fond de la chip "risque élevé".
const Color kAnalysePlanteRedSoft = Color(0xFFFDECEA);

/// Format de date court partagé : "15 mars 2026 · 09:42".
String formatAnalyseDate(DateTime? d) {
  if (d == null) return '';
  return DateFormat('d MMM yyyy · HH:mm', 'fr_FR').format(d);
}
