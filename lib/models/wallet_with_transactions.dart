import 'pagination.dart';
import 'portefeuille.dart';
import 'transaction.dart';

/// Bundle wallet + transactions renvoyé par `/finance/wallet`.
///
/// Pas Freezed à cause du `Paginated<T>` générique imbriqué.
class WalletWithTransactions {
  final Portefeuille wallet;
  final Paginated<Transaction> transactions;

  const WalletWithTransactions({
    required this.wallet,
    required this.transactions,
  });

  factory WalletWithTransactions.fromJson(Map<String, dynamic> json) {
    final walletJson = json['wallet'] is Map
        ? (json['wallet'] as Map).cast<String, dynamic>()
        : <String, dynamic>{};
    final txRaw = json['transactions'];
    return WalletWithTransactions(
      wallet: Portefeuille.fromJson(walletJson),
      transactions: Paginated.fromJsonOrList(txRaw, Transaction.fromJson),
    );
  }
}
