import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../models/transaction.dart';
import 'tuile_transaction.dart';

/// Helpers de transformation `Transaction` du backend vers la représentation
/// visuelle attendue par [TuileTransaction]. Centralisé ici car le mapping
/// était dupliqué dans les 4 pages wallet.
class MappingTransaction {
  MappingTransaction._();

  /// Convertit une transaction backend vers un item visuel.
  static ItemTransaction depuisModel(Transaction t) {
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
    return ItemTransaction(
      icon: entree ? Icons.arrow_downward : Icons.arrow_upward,
      entree: entree,
      titre: titre,
      sousTitre: sousTitre,
      montant: entree ? '+$montant F' : '-$montant F',
    );
  }

  /// Convertit une liste de transactions.
  static List<ItemTransaction> depuisListe(List<Transaction> txs) =>
      txs.map(depuisModel).toList();
}
