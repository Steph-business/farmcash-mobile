import 'package:intl/intl.dart';

/// Helpers de formatage partagés par les widgets de l'accueil acheteur.
///
/// Centralise le formatage prix et kg en FR (séparateur d'espace fine)
/// pour éviter les duplications entre les widgets extraits.

final NumberFormat _nfFr = NumberFormat('#,##0', 'fr_FR');

/// Formate un prix en F/kg (ex: `1 250 F/kg`).
String formatPrixAccueil(double prix) {
  return '${_nfFr.format(prix.round())} F/kg';
}

/// Formate une quantité en kg (ex: `1 500 kg`).
String formatKgAccueil(double kg) {
  return '${_nfFr.format(kg.round())} kg';
}

/// Formate une date en libellé relatif court « publié il y a … ».
/// Exemple : `Publié il y a 2 h`, `Publié il y a 3 j`, `À l'instant`.
/// Retourne une chaîne vide si la date est null.
String formatPublieIlYa(DateTime? date) {
  if (date == null) return '';
  final now = DateTime.now();
  final diff = now.difference(date);
  if (diff.inMinutes < 1) return 'À l\'instant';
  if (diff.inHours < 1) return 'Il y a ${diff.inMinutes} min';
  if (diff.inDays < 1) return 'Il y a ${diff.inHours} h';
  if (diff.inDays < 7) return 'Il y a ${diff.inDays} j';
  // Au-delà d'une semaine, on bascule sur la date courte (ex. « 12 mai »).
  return DateFormat('d MMM', 'fr_FR').format(date);
}

/// Génère 2 lettres depuis un id/nom — utile pour avatar placeholder.
String initialesAccueil(String input) {
  final trimmed = input.trim();
  if (trimmed.isEmpty) return '?';
  final parts = trimmed.split(RegExp(r'[\s\-_]+'))
    ..removeWhere((p) => p.isEmpty);
  if (parts.length >= 2) {
    return (parts[0].substring(0, 1) + parts[1].substring(0, 1)).toUpperCase();
  }
  if (trimmed.length == 1) return trimmed.toUpperCase();
  return trimmed.substring(0, 2).toUpperCase();
}
