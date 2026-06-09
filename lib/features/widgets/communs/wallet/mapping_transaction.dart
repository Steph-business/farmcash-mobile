import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../models/transaction.dart';
import 'tuile_transaction.dart';

/// Helpers de transformation `Transaction` du backend vers la représentation
/// visuelle attendue par [TuileTransaction]. Centralisé ici car le mapping
/// était dupliqué dans les 4 pages wallet.
class MappingTransaction {
  MappingTransaction._();

  /// Détecte si une transaction RELEASE correspond probablement à un
  /// versement issu d'une vente agrégée par la coopérative — heuristique
  /// sur le `description` car la distribution coop crédite le wallet
  /// silencieusement (pas de transaction dédiée côté membre) et seules
  /// les libérations d'escrow directes laissent une trace RELEASE.
  ///
  /// On reste prudent : faux-positifs ≪ faux-négatifs (le badge est un
  /// indice, pas une promesse). Le détail vrai vient de "Mes ventes coop".
  static bool estVenteCoop(Transaction t) {
    if (t.type != 'RELEASE') return false;
    final desc = t.description?.toLowerCase() ?? '';
    return desc.contains('coop')
        || desc.contains('coopérative')
        || desc.contains('cooperative')
        || desc.contains('publication');
  }

  /// Convertit une transaction backend vers un item visuel.
  ///
  /// [onTap] : optionnel, branche un détail de transaction.
  /// [forcerBadgeCoop] : optionnel, force le badge « Vente coop » même si
  /// l'heuristique [estVenteCoop] ne déclenche pas (utile quand l'appelant
  /// dispose d'un signal plus fiable).
  static ItemTransaction depuisModel(
    Transaction t, {
    void Function(Transaction)? onTap,
    bool forcerBadgeCoop = false,
  }) {
    final entree = t.montant >= 0;
    final titre = (t.description?.isNotEmpty == true)
        ? t.description!
        : (t.reference?.isNotEmpty == true ? t.reference! : t.type);
    final montant = NumberFormat('#,##0', 'fr_FR').format(t.montant.abs());
    final dateLabel = t.createdAt == null
        ? '—'
        : DateFormat('dd/MM', 'fr_FR').format(t.createdAt!);
    final providerLabel = t.provider?.apiValue ?? '';
    final sousTitre =
        providerLabel.isEmpty ? dateLabel : '$dateLabel · $providerLabel';
    final estCoop = forcerBadgeCoop || estVenteCoop(t);
    return ItemTransaction(
      icon: entree ? Icons.arrow_downward : Icons.arrow_upward,
      entree: entree,
      titre: titre,
      sousTitre: sousTitre,
      montant: entree ? '+$montant F' : '-$montant F',
      badge: estCoop ? 'Vente coop' : null,
      onTap: onTap == null ? null : () => onTap(t),
    );
  }

  /// Convertit une liste de transactions.
  static List<ItemTransaction> depuisListe(
    List<Transaction> txs, {
    void Function(Transaction)? onTap,
  }) =>
      txs.map((t) => depuisModel(t, onTap: onTap)).toList();
}
