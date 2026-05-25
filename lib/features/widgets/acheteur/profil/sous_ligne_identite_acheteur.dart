/// Construit la sous-ligne d'identité acheteur : "Acheteur · — · ★ {note}".
///
/// L'API utilisateur n'expose pas encore de champ ville/région — on affiche
/// "—" tant que ce champ n'est pas dispo (pas de mock data). Le rating est
/// formaté à 1 décimale ou "—" si nul.
String sousLigneIdentiteAcheteur({required double rating}) {
  final ratingTxt = rating > 0 ? rating.toStringAsFixed(1) : '—';
  // L'API utilisateur n'expose pas encore ville/région.
  const villeTxt = '—';
  return 'Acheteur · $villeTxt · ★ $ratingTxt';
}
