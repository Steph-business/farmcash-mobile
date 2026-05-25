/// Helpers de formatage pour la page Detail entrepot.
library;

import '../../../../models/enums.dart';

/// Formate une quantite en kg vers une string compacte :
/// - moins de 1000 kg : "N kg"
/// - 1000 a 9999 kg : "N.N t"
/// - 10 000 kg et + : "N t" (sans decimale)
String formatTonnage(double kg) {
  if (kg < 1000) return '${kg.round()} kg';
  final t = kg / 1000;
  if (t >= 10) return '${t.toStringAsFixed(0)} t';
  return '${t.toStringAsFixed(1)} t';
}

/// Formate un nombre brut de kg (rounded) avec separateurs d'espaces
/// tous les 3 chiffres.
String formatKgEspaces(double kg) {
  final i = kg.round();
  if (i < 1000) return '$i';
  final s = '$i';
  final buf = StringBuffer();
  for (var k = 0; k < s.length; k++) {
    if (k > 0 && (s.length - k) % 3 == 0) buf.write(' ');
    buf.write(s[k]);
  }
  return buf.toString();
}

/// Libelle long pour la qualite d'un produit (Standard, Premium, etc.).
String qualiteLabelLong(ProductQuality q) {
  switch (q) {
    case ProductQuality.standard:
      return 'Standard';
    case ProductQuality.premium:
      return 'Premium';
    case ProductQuality.bio:
      return 'Bio';
    case ProductQuality.equitable:
      return 'Équitable';
    case ProductQuality.unknown:
      return '—';
  }
}

/// Libelle court (1-3 caracteres) pour la qualite d'un produit.
String qualiteLabelCourt(ProductQuality q) {
  switch (q) {
    case ProductQuality.premium:
      return 'A';
    case ProductQuality.standard:
      return 'B';
    case ProductQuality.bio:
      return 'BIO';
    case ProductQuality.equitable:
      return 'EQ';
    case ProductQuality.unknown:
      return '—';
  }
}
