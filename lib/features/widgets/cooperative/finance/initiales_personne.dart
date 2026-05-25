/// Helpers pour generer des initiales d'une personne a partir de son nom.
library;

/// Retourne les initiales (2 caracteres) d'une chaine representant un nom.
/// Exemples : "Yao Konan" -> "YK", "kouassi" -> "KO", "" -> "?".
String initialesPersonne(String s) {
  final t = s.trim();
  if (t.isEmpty) return '?';
  final parts = t.split(RegExp(r'[\s\-_]+'))..removeWhere((p) => p.isEmpty);
  if (parts.length >= 2) {
    return (parts[0].substring(0, 1) + parts[1].substring(0, 1)).toUpperCase();
  }
  if (t.length == 1) return t.toUpperCase();
  return t.substring(0, 2).toUpperCase();
}
