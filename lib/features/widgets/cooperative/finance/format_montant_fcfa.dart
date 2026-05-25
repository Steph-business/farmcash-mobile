/// Helpers de formatage monetaire et libelles pour les widgets finance.
library;

/// Formate un montant `double` en string avec separateurs d'espaces
/// tous les 3 chiffres (ex: 175 000). Ne renvoie pas le suffixe `F`.
String formatMontantFcfa(double v) {
  final i = v.round();
  if (i < 1000) return '$i';
  final s = '$i';
  final buf = StringBuffer();
  for (var k = 0; k < s.length; k++) {
    if (k > 0 && (s.length - k) % 3 == 0) buf.write(' ');
    buf.write(s[k]);
  }
  return buf.toString();
}

/// Libelle francais pour un statut de payout backend.
String statusPayoutLabel(String s) {
  switch (s.toUpperCase()) {
    case 'PENDING':
      return 'En attente';
    case 'PROCESSING':
      return 'En cours';
    case 'COMPLETED':
      return 'Complétée';
    case 'FAILED':
      return 'Échouée';
    default:
      return s;
  }
}

/// Libelle francais pour un provider de paiement backend.
String providerPayoutLabel(String s) {
  switch (s) {
    case 'ORANGE_MONEY':
      return 'Orange Money';
    case 'MTN_MOMO':
      return 'MTN MoMo';
    case 'WAVE':
      return 'Wave';
    case 'MOOV':
      return 'Moov';
    case 'WALLET':
      return 'Wallet';
    case 'VIREMENT':
      return 'Virement';
    default:
      return s;
  }
}

/// Tronque un id en 6 caracteres pour affichage compact.
String shortIdPayout(String id) {
  if (id.length <= 6) return id;
  return id.substring(0, 6);
}
