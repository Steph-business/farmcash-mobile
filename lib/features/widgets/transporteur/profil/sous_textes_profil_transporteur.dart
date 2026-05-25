import 'package:intl/intl.dart';

/// V1 : libellé statique pour le type de véhicule (aucun endpoint dédié).
const String kVehiculeStatiqueTransporteur = 'Camion 3 t';

/// V1 : taux de succès statique (non calculable côté API actuelle).
const String kTauxSuccesStatiqueTransporteur = '98 %';

/// Sous-ligne d'identité transporteur :
/// "Transporteur · {véhicule} · ★ {note}" avec note formatée à 1 décimale
/// (virgule fr) ou "—" si rating ≤ 0.
String sousLigneIdentiteTransporteur({required double rating}) {
  final note = rating > 0
      ? rating.toStringAsFixed(1).replaceAll('.', ',')
      : '—';
  return 'Transporteur · $kVehiculeStatiqueTransporteur · ★ $note';
}

/// Formate un montant en F XOF avec séparateur de milliers fr_FR.
/// Si la devise n'est pas "XOF" ni vide, le suffixe est le code devise.
String formatMontantTransporteur(double montant, String devise) {
  final formatted = NumberFormat('#,##0', 'fr_FR').format(montant);
  if (devise == 'XOF' || devise.isEmpty) {
    return '$formatted F';
  }
  return '$formatted $devise';
}

/// Format compact pour les KPI : `456000` → `456 K`. Pour les valeurs
/// inférieures à 1000, on garde la valeur entière sans suffixe.
String formatCompactTransporteur(double v) {
  if (v >= 1000) {
    return '${(v / 1000).toStringAsFixed(0)} K';
  }
  return v.toStringAsFixed(0);
}
