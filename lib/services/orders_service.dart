import 'package:dio/dio.dart';

import '../api_client/api_client.dart';
import '../api_client/api_endpoints.dart';
import '../models/models.dart';

/// Wrapper de commande enrichi des jointures backend (`annonces_vente`,
/// `users_*`). Évite de recharger 1 GET par commande pour récupérer le
/// nom du buyer/seller et le produit affichés dans la liste UI.
///
/// Le backend retourne ces nested objects via `include:` Prisma — on les
/// dépose ici dans des champs plats lisibles. Si une jointure est null
/// (commande très ancienne, user supprimé…), les champs restent null.
class OrderListItem {
  final Commande commande;
  final String? buyerName;
  final String? buyerPhotoUrl;
  final String? sellerName;
  final String? sellerPhotoUrl;
  final String? produitNom;

  const OrderListItem({
    required this.commande,
    this.buyerName,
    this.buyerPhotoUrl,
    this.sellerName,
    this.sellerPhotoUrl,
    this.produitNom,
  });

  factory OrderListItem.fromJson(Map<String, dynamic> json) {
    final buyer = json['users_commandes_vente_buyer_idTousers'];
    final seller = json['users_commandes_vente_seller_idTousers'];
    final annonce = json['annonces_vente'];
    final produit = annonce is Map ? annonce['produits_agricoles'] : null;
    return OrderListItem(
      commande: Commande.fromJson(json),
      buyerName: buyer is Map ? buyer['full_name'] as String? : null,
      buyerPhotoUrl: buyer is Map ? buyer['photo_url'] as String? : null,
      sellerName: seller is Map ? seller['full_name'] as String? : null,
      sellerPhotoUrl: seller is Map ? seller['photo_url'] as String? : null,
      produitNom: produit is Map ? produit['nom'] as String? : null,
    );
  }
}

/// Source d'origine d'une commande, alignée sur l'enum backend
/// `OrderSourceType`. À chaque source correspond une référence métier
/// (annonce vente directe, candidature acceptée, etc.).
enum OrderSourceType {
  directAnnonceVente('DIRECT_ANNONCE_VENTE'),
  candidatureAccepted('CANDIDATURE_ACCEPTED'),
  propositionAccepted('PROPOSITION_ACCEPTED'),
  reservationConfirmed('RESERVATION_CONFIRMED'),
  contreOffreAccepted('CONTRE_OFFRE_ACCEPTED');

  const OrderSourceType(this.apiValue);
  final String apiValue;
}

/// Orders — commandes + litiges.
class OrdersService {
  final ApiClient _api;
  OrdersService(this._api);

  /// Crée une commande conforme au DTO backend `CreateOrderDto`.
  ///
  /// Le backend exige :
  ///   - `source_type` : origine de la commande (DIRECT_ANNONCE_VENTE pour
  ///     un achat marketplace classique, CANDIDATURE_ACCEPTED si la
  ///     commande nait d'une négociation déjà acceptée, etc.)
  ///   - **Une seule** des références ci-dessous selon `source_type` :
  ///     `annonceVenteId`, `candidatureId`, `propositionId`,
  ///     `reservationId`, `contreOffreId`.
  ///   - `quantiteKg` : la quantité en kg (entier ≥ 1).
  ///   - `paymentMethodId` (optionnel) : UUID du moyen de paiement
  ///     enregistré du buyer. Si omis, le backend utilise le moyen marqué
  ///     `is_default`. **Le wallet est résolu côté serveur** — le mobile
  ///     ne doit plus envoyer `payment_provider`.
  ///   - `transporterRouteId` (optionnel) : si fourni, un shipment est
  ///     créé automatiquement avec le tarif de la route choisie.
  ///
  /// [idempotencyKey] est obligatoire pour empêcher les doublons réseau —
  /// passer un UUID unique par tentative.
  Future<Commande> createOrder({
    required double quantiteKg,
    required String idempotencyKey,
    OrderSourceType sourceType = OrderSourceType.directAnnonceVente,
    String? annonceVenteId,
    String? candidatureId,
    String? propositionId,
    String? reservationId,
    String? contreOffreId,
    String? paymentMethodId,
    String? transporterRouteId,
    String? pickupAddress,
    String? deliveryAddress,
    String? notes,
  }) async {
    final json = await _api.post<Map<String, dynamic>>(
      ApiEndpoints.orders,
      body: {
        'source_type': sourceType.apiValue,
        if (annonceVenteId != null) 'annonce_vente_id': annonceVenteId,
        if (candidatureId != null) 'candidature_id': candidatureId,
        if (propositionId != null) 'proposition_id': propositionId,
        if (reservationId != null) 'reservation_id': reservationId,
        if (contreOffreId != null) 'contre_offre_id': contreOffreId,
        'quantite_kg': quantiteKg,
        if (paymentMethodId != null) 'payment_method_id': paymentMethodId,
        if (transporterRouteId != null)
          'transporter_route_id': transporterRouteId,
        if (pickupAddress != null) 'pickup_address': pickupAddress,
        if (deliveryAddress != null) 'delivery_address': deliveryAddress,
        if (notes != null) 'notes': notes,
      },
      options: Options(headers: {'Idempotency-Key': idempotencyKey}),
    );
    return Commande.fromJson(json);
  }

  /// Liste mes commandes paginées.
  ///
  /// [side] (optionnel) :
  ///   - `'buyer'` : seulement mes achats (je suis acheteur)
  ///   - `'seller'` : seulement mes ventes (je suis vendeur — typiquement
  ///     pour les FARMER qui consultent les commandes reçues)
  ///   - omis : les deux côtés mélangés
  ///
  /// Aligné sur `ListerOrdersQueryDto` côté backend qui exige `side` (et
  /// PAS `role`, qui était l'ancien nom du paramètre — provoquait un 400
  /// silencieux à cause de `forbidNonWhitelisted`).
  Future<Paginated<Commande>> listMyOrders({
    OrderStatus? status,
    String? side,
    int page = 1,
    int limit = 20,
  }) async {
    final raw = await _api.get<dynamic>(
      ApiEndpoints.ordersMy,
      query: {
        if (status != null) 'status': status.apiValue,
        if (side != null) 'side': side,
        'page': page,
        'limit': limit,
      },
    );
    return Paginated.fromJsonOrList(raw, Commande.fromJson);
  }

  /// Variante de [listMyOrders] qui renvoie les commandes ENRICHIES des
  /// jointures backend (nom buyer/seller, photo, nom du produit). Utile
  /// pour les listes UI qui affichent un titre lisible sans avoir à
  /// charger chaque commande individuellement.
  Future<Paginated<OrderListItem>> listMyOrdersWithJoins({
    OrderStatus? status,
    String? side,
    int page = 1,
    int limit = 20,
  }) async {
    final raw = await _api.get<dynamic>(
      ApiEndpoints.ordersMy,
      query: {
        if (status != null) 'status': status.apiValue,
        if (side != null) 'side': side,
        'page': page,
        'limit': limit,
      },
    );
    return Paginated.fromJsonOrList(raw, OrderListItem.fromJson);
  }

  Future<Commande> getOrder(String id) async {
    final json = await _api.get<Map<String, dynamic>>(
      ApiEndpoints.orderById(id),
    );
    return Commande.fromJson(json);
  }

  /// Paie une commande **déjà créée** (status SENT). Typiquement utilisée
  /// pour une commande issue de l'acceptation d'une candidature ou
  /// proposition côté négociation — le backend a alors créé la commande
  /// sans déclencher le payin, l'acheteur doit donc payer explicitement.
  ///
  /// L'[idempotencyKey] (UUID v4) est obligatoire pour empêcher les
  /// doubles paiements en cas de retry réseau.
  ///
  /// Aligné sur `PayOrderDto` — accepte uniquement `payment_method_id`
  /// (UUID du moyen de paiement enregistré). Si omis, le backend prend
  /// le moyen marqué `is_default` du buyer.
  Future<Commande> payOrder({
    required String id,
    required String idempotencyKey,
    String? paymentMethodId,
  }) async {
    final json = await _api.post<Map<String, dynamic>>(
      ApiEndpoints.orderPay(id),
      body: {
        if (paymentMethodId != null) 'payment_method_id': paymentMethodId,
      },
      options: Options(headers: {'Idempotency-Key': idempotencyKey}),
    );
    return Commande.fromJson(json);
  }

  /// Met à jour le statut d'une commande (typiquement SELLER : ACCEPTED →
  /// IN_PROGRESS → DELIVERED ; ou COOP : ACCEPTED).
  ///
  /// Aligné sur `UpdateOrderStatusDto` — le DTO attend `notes`, pas
  /// `motif`. La signature mobile expose `motif` pour rester cohérente
  /// avec le vocabulaire UI, mappé vers `notes` dans le body.
  Future<Commande> updateOrderStatus({
    required String id,
    required OrderStatus newStatus,
    String? motif,
  }) async {
    final json = await _api.put<Map<String, dynamic>>(
      ApiEndpoints.orderStatus(id),
      body: {
        'status': newStatus.apiValue,
        if (motif != null) 'notes': motif,
      },
    );
    return Commande.fromJson(json);
  }

  // ─── Litiges ─────────────────────────────────────────────────────────

  /// Ouvre un litige sur une commande livrée.
  ///
  /// Aligné sur `OpenDisputeDto` — attend `{commande_id, raison,
  /// preuves_urls?}`. La `raison` doit faire 10..2000 caractères.
  Future<Dispute> openDispute({
    required String commandeId,
    required String raison,
    List<String>? preuvesUrls,
  }) async {
    final json = await _api.post<Map<String, dynamic>>(
      ApiEndpoints.disputes,
      body: {
        'commande_id': commandeId,
        'raison': raison,
        if (preuvesUrls != null) 'preuves_urls': preuvesUrls,
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

  /// Résout un litige (ADMIN).
  ///
  /// Aligné sur `ResolveDisputeDto` — attend
  /// `{resolution: 'REFUND_BUYER'|'PAY_SELLER'|'PARTIAL_REFUND',
  /// buyer_pct?, note?}`. `buyer_pct` (0..1) n'est utile que pour
  /// PARTIAL_REFUND.
  Future<Dispute> resolveDispute({
    required String id,
    required DisputeResolution resolution,
    double? buyerPct,
    String? note,
  }) async {
    final json = await _api.put<Map<String, dynamic>>(
      ApiEndpoints.disputeResolve(id),
      body: {
        'resolution': resolution.apiValue,
        if (buyerPct != null) 'buyer_pct': buyerPct,
        if (note != null) 'note': note,
      },
    );
    return Dispute.fromJson(json);
  }
}

/// Décisions possibles sur un litige (aligné sur `ResolveDisputeDto`).
enum DisputeResolution {
  refundBuyer('REFUND_BUYER'),
  paySeller('PAY_SELLER'),
  partialRefund('PARTIAL_REFUND');

  const DisputeResolution(this.apiValue);
  final String apiValue;
}
