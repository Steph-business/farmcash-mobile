import '../api_client/api_client.dart';
import '../api_client/api_endpoints.dart';
import '../models/models.dart';

/// Logistique — routes transporteur, devis, missions, lifecycle shipment.
class LogisticsService {
  final ApiClient _api;
  LogisticsService(this._api);

  // ─── Routes du transporteur ──────────────────────────────────────────

  Future<List<TransporterRoute>> listMyRoutes() async {
    final raw = await _api.get<dynamic>(ApiEndpoints.routesMy);
    return _asList(raw, TransporterRoute.fromJson);
  }

  Future<TransporterRoute> createRoute({
    required String origineVilleId,
    required String destinationVilleId,
    required double capaciteKg,
    required double prixParKm,
    double? prixForfait,
  }) async {
    final json = await _api.post<Map<String, dynamic>>(
      ApiEndpoints.routes,
      body: {
        'origine_ville_id': origineVilleId,
        'destination_ville_id': destinationVilleId,
        'capacite_kg': capaciteKg,
        'prix_par_km': prixParKm,
        if (prixForfait != null) 'prix_forfait': prixForfait,
      },
    );
    return TransporterRoute.fromJson(json);
  }

  Future<TransporterRoute> updateRoute(
    String id, {
    double? capaciteKg,
    double? prixParKm,
    double? prixForfait,
    bool? isActive,
  }) async {
    final json = await _api.put<Map<String, dynamic>>(
      ApiEndpoints.routeById(id),
      body: {
        if (capaciteKg != null) 'capacite_kg': capaciteKg,
        if (prixParKm != null) 'prix_par_km': prixParKm,
        if (prixForfait != null) 'prix_forfait': prixForfait,
        if (isActive != null) 'is_active': isActive,
      },
    );
    return TransporterRoute.fromJson(json);
  }

  Future<void> deleteRoute(String id) async {
    await _api.delete<dynamic>(ApiEndpoints.routeById(id));
  }

  // ─── Devis (BUYER cherche un transport) ──────────────────────────────

  Future<List<TransporterRoute>> getQuotes({
    required String origineVilleId,
    required String destinationVilleId,
    required double quantiteKg,
  }) async {
    final raw = await _api.get<dynamic>(
      ApiEndpoints.quotes,
      query: {
        'origine_ville_id': origineVilleId,
        'destination_ville_id': destinationVilleId,
        'quantite_kg': quantiteKg,
      },
    );
    return _asList(raw, TransporterRoute.fromJson);
  }

  // ─── Missions disponibles ────────────────────────────────────────────

  Future<List<Livraison>> getAvailableMissions() async {
    final raw = await _api.get<dynamic>(ApiEndpoints.missionsAvailable);
    return _asList(raw, Livraison.fromJson);
  }

  // ─── Lifecycle shipment ──────────────────────────────────────────────

  Future<Livraison> acceptShipment(String id) async {
    final json = await _api.post<Map<String, dynamic>>(
      ApiEndpoints.shipmentAccept(id),
    );
    return Livraison.fromJson(json);
  }

  Future<Livraison> startLoading({
    required String id,
    List<String>? photos,
  }) async {
    final json = await _api.post<Map<String, dynamic>>(
      ApiEndpoints.shipmentStartLoading(id),
      body: {
        if (photos != null) 'photos': photos,
      },
    );
    return Livraison.fromJson(json);
  }

  Future<Livraison> trackPosition({
    required String id,
    required double lat,
    required double lng,
  }) async {
    final json = await _api.post<Map<String, dynamic>>(
      ApiEndpoints.shipmentTrack(id),
      body: {'lat': lat, 'lng': lng},
    );
    return Livraison.fromJson(json);
  }

  Future<Livraison> markDelivered({
    required String id,
    required String photoPreuveUrl,
    String? signatureUrl,
    String? notes,
  }) async {
    final json = await _api.post<Map<String, dynamic>>(
      ApiEndpoints.shipmentDeliver(id),
      body: {
        'photo_preuve_url': photoPreuveUrl,
        if (signatureUrl != null) 'signature_url': signatureUrl,
        if (notes != null) 'notes': notes,
      },
    );
    return Livraison.fromJson(json);
  }

  Future<Livraison> cancelShipment(String id) async {
    final json = await _api.post<Map<String, dynamic>>(
      ApiEndpoints.shipmentCancel(id),
    );
    return Livraison.fromJson(json);
  }

  Future<List<TrackingEvent>> getTracking(String shipmentId) async {
    final raw = await _api.get<dynamic>(
      ApiEndpoints.shipmentTracking(shipmentId),
    );
    return _asList(raw, TrackingEvent.fromJson);
  }

  // ─── Pickup QR (chantier 1) ──────────────────────────────────────────

  /// FARMER (seller) génère un QR signé pour preuve d'enlèvement.
  /// TTL court (15 min serveur). Le transporteur scanne ce token pour
  /// déclencher l'auto-release de l'escrow PRODUCT.
  ///
  /// Pré-requis : le shipment doit être en statut ACCEPTED.
  Future<PickupQrToken> generatePickupQrToken(String shipmentId) async {
    final json = await _api.get<Map<String, dynamic>>(
      ApiEndpoints.shipmentQrToken(shipmentId),
    );
    return PickupQrToken.fromJson(json);
  }

  /// TRANSPORTER scanne le QR du producteur → shipment passe en LOADING
  /// et l'escrow PRODUCT est libéré automatiquement.
  ///
  /// La position GPS (`lat`/`lng`) est obligatoire côté backend : le
  /// serveur vérifie qu'elle est à < 500 m du pickup_location déclaré.
  ///
  /// Réponse brute (Map) : `{ shipment_status, escrow_released, ... }`.
  Future<Map<String, dynamic>> scanPickup({
    required String shipmentId,
    required String token,
    required double lat,
    required double lng,
  }) async {
    return _api.post<Map<String, dynamic>>(
      ApiEndpoints.shipmentScanPickup(shipmentId),
      body: {
        'token': token,
        'scan_position': {'lat': lat, 'lng': lng},
      },
    );
  }

  List<T> _asList<T>(dynamic raw, T Function(Map<String, dynamic>) from) {
    if (raw is List) {
      return raw
          .whereType<Map>()
          .map((m) => from(m.cast<String, dynamic>()))
          .toList();
    }
    if (raw is Map && raw['data'] is List) {
      return (raw['data'] as List)
          .whereType<Map>()
          .map((m) => from(m.cast<String, dynamic>()))
          .toList();
    }
    return const [];
  }
}
