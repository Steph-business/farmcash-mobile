import 'package:intl/intl.dart';

import '../../../../models/annonce_vente.dart';
import '../../../../models/cooperative.dart';
import '../../../../models/enums.dart';
import '../../../../models/parcelle.dart';
import '../../../../models/produit.dart';

/// Sous-ligne d'identité producteur : "Producteur · — · ★ {note}" (note
/// affichée seulement si rating > 0).
String sousLigneIdentiteProducteur({required double rating}) {
  final ratingTxt = rating > 0 ? rating.toStringAsFixed(1) : '—';
  if (rating > 0) {
    return 'Producteur · — · ★ $ratingTxt';
  }
  return 'Producteur · —';
}

/// Formate un montant XOF avec séparateur de milliers fr_FR : "12 500 F".
String formatMontantProducteur(double value) {
  final f = NumberFormat('#,##0', 'fr_FR');
  return '${f.format(value)} F';
}

/// Mois abrégé fr ("janv. 2026") sans dépendre de `initializeDateFormatting`.
String _formatMoisProducteur(DateTime date) {
  const mois = [
    'janv.',
    'févr.',
    'mars',
    'avr.',
    'mai',
    'juin',
    'juil.',
    'août',
    'sept.',
    'oct.',
    'nov.',
    'déc.',
  ];
  final idx = (date.month - 1).clamp(0, 11);
  return '${mois[idx]} ${date.year}';
}

/// Sous-texte "X parcelles · Y ha" (retourne `null` si liste vide).
String? sousTexteParcellesProducteur(List<Parcelle> parcelles) {
  if (parcelles.isEmpty) return null;
  final nb = parcelles.length;
  final total = parcelles.fold<double>(
    0,
    (acc, p) => acc + (p.superficieHa ?? 0),
  );
  final labelNb = nb > 1 ? 'parcelles' : 'parcelle';
  if (total <= 0) return '$nb $labelNb';
  final ha = (total - total.truncate()).abs() < 0.05
      ? total.toStringAsFixed(0)
      : total.toStringAsFixed(1);
  return '$nb $labelNb · $ha ha';
}

/// Sous-texte cultures principales : noms uniques des produits cultivés
/// dans les parcelles, max 3 — résolus depuis le catalogue.
String? sousTexteCulturesProducteur(
    List<Parcelle> parcelles, List<Produit> produits) {
  if (parcelles.isEmpty) return null;
  final byId = {for (final p in produits) p.id: p.nom};
  final noms = <String>{};
  for (final parc in parcelles) {
    final pid = parc.produitId;
    if (pid == null || pid.isEmpty) continue;
    final nom = byId[pid];
    if (nom != null && nom.isNotEmpty) noms.add(nom);
  }
  if (noms.isEmpty) return 'Aucune renseignée';
  return noms.take(3).join(', ');
}

/// Sous-texte coopérative : "{nom} · membre depuis {mois}" si l'utilisateur
/// est rattaché à une coop ; "Aucune coopérative" sinon.
String sousTexteCoopProducteur(Cooperative? coop) {
  if (coop == null) return 'Aucune coopérative';
  final dateMembre = coop.createdAt;
  if (dateMembre == null) return coop.nom;
  return '${coop.nom} · membre depuis ${_formatMoisProducteur(dateMembre)}';
}

/// Sous-texte annonces producteur : "X actives · Y archivées".
String? sousTexteAnnoncesProducteur(List<AnnonceVente> annonces) {
  if (annonces.isEmpty) return null;
  final actives =
      annonces.where((a) => a.status == ProductStatus.active).length;
  final archives = annonces.where((a) {
    return a.status == ProductStatus.sold ||
        a.status == ProductStatus.expired ||
        a.status == ProductStatus.paused;
  }).length;
  return '$actives actives · $archives archivées';
}
