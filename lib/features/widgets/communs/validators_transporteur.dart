// =====================================================================
//  Validateurs format transporteur (chantier polish UX)
//  ---------------------------------------------------------------------
//  Permis de conduire CI : format CI-PERM-AAAA-NNNNNN
//    (ex : CI-PERM-2020-456789)
//
//  Plaque d'immatriculation CI : 4 chiffres + 2 lettres + 2 chiffres
//    (ex : 4567 AB 01) — séparateurs espaces ou tirets tolérés en entrée
//    mais on normalise sur l'espace simple côté stockage.
// =====================================================================

/// Regex permis CI strict — appliquer après `.trim().toUpperCase()`.
final RegExp _kPermisCiRegex =
    RegExp(r'^CI-PERM-\d{4}-\d{4,8}$');

/// Regex plaque CI — accepte espaces ou tirets entre les blocs.
final RegExp _kPlaqueCiRegex =
    RegExp(r'^\d{4}[\s-]?[A-Z]{2}[\s-]?\d{1,2}$');

/// Retourne `null` si le permis est valide, sinon le message à afficher.
String? validatePermisCI(String? input) {
  final v = input?.trim().toUpperCase() ?? '';
  if (v.isEmpty) return 'Obligatoire';
  if (!_kPermisCiRegex.hasMatch(v)) {
    return 'Format attendu : CI-PERM-AAAA-NNNNNN';
  }
  return null;
}

/// Retourne `null` si la plaque est valide, sinon le message à afficher.
String? validatePlaqueCI(String? input) {
  final v = input?.trim().toUpperCase() ?? '';
  if (v.isEmpty) return 'Obligatoire';
  if (!_kPlaqueCiRegex.hasMatch(v)) {
    return 'Format attendu : 4567 AB 01';
  }
  return null;
}

/// Normalise une plaque pour stockage (espaces simples, majuscules).
/// Si invalide, retourne la valeur trimée telle quelle.
String normalizePlaqueCI(String input) {
  final v = input.trim().toUpperCase();
  if (!_kPlaqueCiRegex.hasMatch(v)) return v;
  final match = _kPlaqueCiRegex.firstMatch(v)!;
  // Re-capture les groupes en re-matchant un format normalisé.
  final groups = RegExp(r'^(\d{4})[\s-]?([A-Z]{2})[\s-]?(\d{1,2})$')
      .firstMatch(v)!;
  return '${groups.group(1)} ${groups.group(2)} ${groups.group(3)}';
}
