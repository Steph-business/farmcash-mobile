import '../api_client/api_client.dart';
import '../api_client/api_endpoints.dart';
import '../models/models.dart';

/// Finance — wallet, transactions, escrow, payout, moyens de paiement.
class FinanceService {
  final ApiClient _api;
  FinanceService(this._api);

  /// Récupère solde + transactions paginées (l'endpoint renvoie les deux).
  Future<WalletWithTransactions> getWallet({
    int page = 1,
    int limit = 20,
    String? typeFilter,
  }) async {
    final raw = await _api.get<Map<String, dynamic>>(
      ApiEndpoints.wallet,
      query: {
        'page': page,
        'limit': limit,
        if (typeFilter != null) 'type': typeFilter,
      },
    );
    return WalletWithTransactions.fromJson(raw);
  }

  /// Le BUYER confirme la réception → libère l'escrow vers le vendeur.
  Future<void> confirmDelivery({required String commandeId}) async {
    await _api.post<dynamic>(
      ApiEndpoints.confirmDelivery,
      body: {'commande_id': commandeId},
    );
  }

  /// ADMIN uniquement — déblocage manuel d'un escrow bloqué.
  ///
  /// Aligné sur `ReleaseEscrowDto` — attend `reason`, pas `motif`.
  Future<void> releaseEscrowAdmin({
    required String commandeId,
    String? reason,
  }) async {
    await _api.post<dynamic>(
      ApiEndpoints.releaseEscrow,
      body: {
        'commande_id': commandeId,
        if (reason != null) 'reason': reason,
      },
    );
  }

  /// Retrait du wallet vers un moyen Mobile Money.
  ///
  /// Aligné sur `PayoutDto` — attend `amount` et `payment_method_id`.
  Future<Transaction> payout({
    required double amount,
    required String paymentMethodId,
  }) async {
    final json = await _api.post<Map<String, dynamic>>(
      ApiEndpoints.payout,
      body: {
        'amount': amount,
        'payment_method_id': paymentMethodId,
      },
    );
    return Transaction.fromJson(json);
  }

  // ─── Moyens de paiement ──────────────────────────────────────────────

  Future<List<MoyenPayement>> listMoyensPayement() async {
    final raw = await _api.get<dynamic>(ApiEndpoints.moyensPayement);
    if (raw is List) {
      return raw
          .whereType<Map>()
          .map((m) => MoyenPayement.fromJson(m.cast<String, dynamic>()))
          .toList();
    }
    return const [];
  }

  /// Enregistre un moyen de paiement (Mobile Money) pour le user courant.
  ///
  /// Aligné sur `CreateMoyenPayementDto` — attend `phone_display`, pas
  /// `phone`.
  Future<MoyenPayement> addMoyenPayement({
    required MobileProvider provider,
    required String phoneDisplay,
    bool isDefault = false,
  }) async {
    final json = await _api.post<Map<String, dynamic>>(
      ApiEndpoints.moyensPayement,
      body: {
        'provider': provider.apiValue,
        'phone_display': phoneDisplay,
        'is_default': isDefault,
      },
    );
    return MoyenPayement.fromJson(json);
  }

  Future<MoyenPayement> updateMoyenPayement(
    String id, {
    bool? isDefault,
    bool? isActive,
  }) async {
    final json = await _api.put<Map<String, dynamic>>(
      ApiEndpoints.moyenPayementById(id),
      body: {
        if (isDefault != null) 'is_default': isDefault,
        if (isActive != null) 'is_active': isActive,
      },
    );
    return MoyenPayement.fromJson(json);
  }

  Future<void> deleteMoyenPayement(String id) async {
    await _api.delete<dynamic>(ApiEndpoints.moyenPayementById(id));
  }

  // ─── Payout batches (COOP, ADMIN) ────────────────────────────────────

  Future<List<PayoutBatch>> listPayoutBatches() async {
    final raw = await _api.get<dynamic>(ApiEndpoints.payoutBatches);
    if (raw is List) {
      return raw
          .whereType<Map>()
          .map((m) => PayoutBatch.fromJson(m.cast<String, dynamic>()))
          .toList();
    }
    return const [];
  }

  Future<PayoutBatch> createPayoutBatch({
    required List<Map<String, dynamic>> items,
    String? memo,
  }) async {
    final json = await _api.post<Map<String, dynamic>>(
      ApiEndpoints.payoutBatches,
      body: {
        'items': items,
        if (memo != null) 'memo': memo,
      },
    );
    return PayoutBatch.fromJson(json);
  }

  // ─── Wallet topup (chantier 4) ───────────────────────────────────────

  /// Recharge le wallet via Mobile Money (OM / MTN / Moov / Wave).
  /// Idempotent via [idempotencyKey] (UUID v4 généré côté client).
  ///
  /// Si le provider crédite synchroniquement : `status=SUCCESS` +
  /// `newBalance`. Sinon `status=PENDING` → l'app doit poller
  /// [getTopupStatus] jusqu'à transition SUCCESS / FAILED.
  ///
  /// Bornes serveur : 500 XOF ≤ amount ≤ 1 000 000 XOF.
  Future<TopupWalletResponse> topupWallet({
    required double amount,
    required String paymentMethodId,
    required String idempotencyKey,
  }) async {
    final json = await _api.post<Map<String, dynamic>>(
      ApiEndpoints.walletTopup,
      body: {
        'amount': amount,
        'payment_method_id': paymentMethodId,
        'idempotency_key': idempotencyKey,
      },
    );
    return TopupWalletResponse.fromJson(json);
  }

  /// Polling du statut d'une recharge en attente du webhook provider.
  Future<TopupWalletResponse> getTopupStatus(String transactionId) async {
    final json = await _api.get<Map<String, dynamic>>(
      ApiEndpoints.walletTopupStatus(transactionId),
    );
    return TopupWalletResponse.fromJson(json);
  }
}
