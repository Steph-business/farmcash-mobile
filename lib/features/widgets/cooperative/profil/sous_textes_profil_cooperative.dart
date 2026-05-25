import 'package:intl/intl.dart';

/// Sous-ligne d'identité coop : "Coopérative · {nb} membre(s) · ★ {note}".
/// Note formatée à 1 décimale (virgule fr) ou "—" si rating ≤ 0.
String sousLigneIdentiteCooperative(int nbMembres, double rating) {
  final ratingTxt = rating > 0
      ? rating.toStringAsFixed(1).replaceAll('.', ',')
      : '—';
  final membresTxt = nbMembres > 1
      ? '$nbMembres membres'
      : '$nbMembres membre';
  return 'Coopérative · $membresTxt · ★ $ratingTxt';
}

/// Sous-titre dynamique "Mes membres" : "{actifs} actifs · {m} demandes en
/// attente" (la clause "en attente" est omise si 0).
String sousTitreMembresCooperative({
  required int actifs,
  required int enAttente,
}) {
  final actifTxt = actifs > 1 ? '$actifs actifs' : '$actifs actif';
  if (enAttente <= 0) return actifTxt;
  final dem = enAttente > 1
      ? '$enAttente demandes en attente'
      : '$enAttente demande en attente';
  return '$actifTxt · $dem';
}

/// Formate un montant XOF "fr_FR" + " F" — utilisé pour le wallet coop.
String formatMontantCooperative(double v) {
  final fmt = NumberFormat('#,##0', 'fr_FR');
  return '${fmt.format(v)} F';
}
