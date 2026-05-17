import 'package:dio/dio.dart';

import '../api_client/api_client.dart';
import '../api_client/api_endpoints.dart';
import '../models/models.dart';

/// Orders — commandes + litiges.
class OrdersService {
  final ApiClient _api;
  OrdersService(this._api);

  /// Crée une commande. [idempotencyKey] est OBLIGATOIRE côté backend pour
  /// éviter les doublons réseau — passer un UUID unique par tentative.
  Future<Commande> createOrder({
    required String annonceId,
    required double quantiteKg,
    required MobileProvider paymentProvider,
    required String idempotencyKey,
    String? livraisonAdresse,
    DateTime? livraisonDate,
    String? moyenPayementId,
  }) async {
    final json = await _api.post<Map<String, dynamic>>(
      ApiEndpoints.orders,
      body: {
        'annonce_id': annonceId,
        'quantite_kg': quantiteKg,
        'payment_provider': paymentProvider.apiValue,
        if (livraisonAdresse != null) 'livraison_adresse': livraisonAdresse,
        if (livraisonDate != null)
          'livraison_date': livraisonDate.toIso8601String(),
        if (moyenPayementId != null) 'moyen_payement_id': moyenPayementId,
      },
      options: Options(headers: {'Idempotency-Key': idempotencyKey}),
    );
    return Commande.fromJson(json);
  }

  Future<Paginated<Commande>> listMyOrders({
    OrderStatus? status,
    String? role,
    int page = 1,
    int limit = 20,
  }) async {
    final raw = await _api.get<dynamic>(
      ApiEndpoints.ordersMy,
      query: {
        if (status != null) 'status': status.apiValue,
        if (role != null) 'role': role,
        'page': page,
        'limit': limit,
      },
    );
    return Paginated.fromJsonOrList(raw, Commande.fromJson);
  }

  Future<Commande> getOrder(String id) async {
    final json = await _api.get<Map<String, dynamic>>(
      ApiEndpoints.orderById(id),
    );
    return Commande.fromJson(json);
  }

  Future<Commande> updateOrderStatus({
    required String id,
    required OrderStatus newStatus,
    String? motif,
  }) async {
    final json = await _api.put<Map<String, dynamic>>(
      ApiEndpoints.orderStatus(id),
      body: {
        'status': newStatus.apiValue,
        if (motif != null) 'motif': motif,
      },
    );
    return Commande.fromJson(json);
  }

  // ─── Litiges ─────────────────────────────────────────────────────────

  Future<Dispute> openDispute({
    required String commandeId,
    required String motif,
    String? description,
    List<String>? photos,
  }) async {
    final json = await _api.post<Map<String, dynamic>>(
      ApiEndpoints.disputes,
      body: {
        'commande_id': commandeId,
        'motif': motif,
        if (description != null) 'description': description,
        if (photos != null) 'photos': photos,
      },
    );
    return Dispute.fromJson(json);
  }

  Future<List<Dispute>> listMyDisputes() async {
    final raw = await _api.get<dynamic>(ApiEndpoints.disputesMy);
    if (raw is List) {
      return raw
          .whereType<Map>()
          .map((m) => Dispute.fromJson(m.cast<String, dynamic>()))
          .toList();
    }
    return const [];
  }

  Future<Dispute> resolveDispute({
    required String id,
    required String resolution,
    double? remboursement,
  }) async {
    final json = await _api.put<Map<String, dynamic>>(
      ApiEndpoints.disputeResolve(id),
      body: {
        'resolution': resolution,
        if (remboursement != null) 'remboursement': remboursement,
      },
    );
    return Dispute.fromJson(json);
  }
}
