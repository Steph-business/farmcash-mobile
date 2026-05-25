import 'package:intl/intl.dart';

/// Formate `12500` → `12 500 F` (devise XOF uniquement, sinon le code).
String formatMontantAccueil(double montant, String devise) {
  final formatted = NumberFormat('#,##0', 'fr_FR').format(montant);
  if (devise == 'XOF' || devise.isEmpty) {
    return '$formatted F';
  }
  return '$formatted $devise';
}

/// "Membre depuis [mois] [année]" — ou "Nouveau membre" si null.
String formatMembreDepuis(DateTime? d) {
  if (d == null) return 'Nouveau membre';
  final formatted = DateFormat('MMMM yyyy', 'fr_FR').format(d);
  return 'Membre depuis $formatted';
}

/// "il y a 2 j" / "il y a 3 h" — pour annotations courtes.
String ageRelatifCourt(DateTime? d) {
  if (d == null) return '';
  final diff = DateTime.now().difference(d);
  if (diff.inMinutes < 60) {
    final m = diff.inMinutes.clamp(1, 59);
    return 'il y a $m min';
  }
  if (diff.inHours < 24) return 'il y a ${diff.inHours} h';
  if (diff.inDays < 7) return 'il y a ${diff.inDays} j';
  return DateFormat('d MMM', 'fr_FR').format(d);
}

/// Variante "longue" utilisée par la section À traiter : pour les minutes,
/// pas de clamp visuel ("il y a 12 min").
String ageRelatif(DateTime? d) {
  if (d == null) return 'récemment';
  final diff = DateTime.now().difference(d);
  if (diff.inMinutes < 60) {
    final m = diff.inMinutes.clamp(1, 59);
    return 'il y a $m min';
  }
  if (diff.inHours < 24) {
    return 'il y a ${diff.inHours} h';
  }
  if (diff.inDays < 7) {
    return 'il y a ${diff.inDays} j';
  }
  return DateFormat('d MMM', 'fr_FR').format(d);
}

/// Génère 2 lettres depuis un id/nom — utile pour avatar placeholder.
String initialesAccueil(String input) {
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
