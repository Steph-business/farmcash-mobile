import '../api_client/api_client.dart';
import '../api_client/api_endpoints.dart';
import '../models/models.dart';

/// Logistique — routes transporteur, devis, missions, lifecycle shipment.
///
/// **Conventions backend importantes :**
/// - Les routes/shipments utilisent des **noms de zones** (`origin_zone`,
///   `destination_zone`) sous forme de strings (« Bouaké », « Abidjan »),
///   pas des UUID de villes.
/// - Le tarif est par kg (`tarif_kg`) + tarif plancher (`tarif_minimum`).
class LogisticsService {
  final ApiClient _api;
  LogisticsService(this._api);

  // ─── Routes du transporteur ──────────────────────────────────────────

  Future<List<TransporterRoute>> listMyRoutes() async {
    final raw = await _api.get<dynamic>(ApiEndpoints.routesMy);
    return _asList(raw, TransporterRoute.fromJson);
  }

  /// Déclare une nouvelle route. Le couple `(origin_zone, destination_zone)`
  /// est unique par transporteur côté backend.
  Future<TransporterRoute> createRoute({
    required String origineZone,
    required String destinationZone,
    required double capaciteMaxKg,
    required double tarifKg,
    double? tarifMinimum,
    String? delaiTypique,
  }) async {
    final json = await _api.post<Map<String, dynamic>>(
      ApiEndpoints.routes,
      body: {
        'origin_zone': origineZone,
        'destination_zone': destinationZone,
        'capacite_max_kg': capaciteMaxKg,
        'tarif_kg': tarifKg,
        if (tarifMinimum != null) 'tarif_minimum': tarifMinimum,
        if (delaiTypique != null) 'delai_typique': delaiTypique,
      },
    );
    return TransporterRoute.fromJson(json);
  }

  Future<TransporterRoute> updateRoute(
    String id, {
    double? capaciteMaxKg,
    double? tarifKg,
    double? tarifMinimum,
    String? delaiTypique,
    bool? isActive,
  }) async {
    final json = await _api.put<Map<String, dynamic>>(
      ApiEndpoints.routeById(id),
      body: {
        if (capaciteMaxKg != null) 'capacite_max_kg': capaciteMaxKg,
        if (tarifKg != null) 'tarif_kg': tarifKg,
        if (tarifMinimum != null) 'tarif_minimum': tarifMinimum,
        if (delaiTypique != null) 'delai_typique': delaiTypique,
        if (isActive != null) 'is_active': isActive,
      },
    );
    return TransporterRoute.fromJson(json);
  }

  Future<void> deleteRoute(String id) async {
    await _api.delete<dynamic>(ApiEndpoints.routeById(id));
  }

  // ─── Devis (BUYER cherche un transport) ──────────────────────────────

  /// Retourne les offres de transport triées par tarif total croissant.
  /// Le backend calcule `tarif_total = MAX(tarif_minimum, tarif_kg * qte)`.
  Future<List<TransportQuote>> getQuotes({
    required String origineZone,
    required String destinationZone,
    required double quantiteKg,
  }) async {
    final raw = await _api.get<dynamic>(
      ApiEndpoints.quotes,
      query: {
        'origin_zone': origineZone,
        'destination_zone': destinationZone,
        'quantite_kg': quantiteKg,
      },
    );
    return _asList(raw, TransportQuote.fromJson);
  }

  // ─── Missions disponibles ────────────────────────────────────────────

  /// Missions REQUESTED qui matchent au moins une route active du
  /// transporteur connecté. Le payload inclut la jointure
  /// `commandes_vente: { reference, montant_total, buyer_id }`.
  Future<List<Livraison>> getAvailableMissions() async {
    final raw = await _api.get<dynamic>(ApiEndpoints.missionsAvailable);
    return _asList(raw, Livraison.fromJson);
  }

  /// Missions **acceptées** par le TRANSPORTER connecté (statuts en cours
  /// ET terminées). Le filtre `status` permet de cibler un statut précis.
  Future<List<Livraison>> getMyMissions({ShipmentStatus? status}) async {
    final raw = await _api.get<dynamic>(
      ApiEndpoints.shipmentsMy,
      query: {if (status != null) 'status': status.apiValue},
    );
    return _asList(raw, Livraison.fromJson);
  }

  // ─── Véhicules du transporteur ───────────────────────────────────────

  Future<List<Vehicle>> listMyVehicles() async {
    final raw = await _api.get<dynamic>(ApiEndpoints.vehiclesMy);
    return _asList(raw, Vehicle.fromJson);
  }

  Future<Vehicle> createVehicle({
    required String type,
    required double chargeMaxKg,
    String? immatriculation,
    String? marque,
    double? volumeM3,
    String? photoUrl,
  }) async {
    final json = await _api.post<Map<String, dynamic>>(
      ApiEndpoints.vehicles,
      body: {
        'type': type,
        'charge_max_kg': chargeMaxKg,
        if (immatriculation != null) 'immatriculation': immatriculation,
        if (marque != null) 'marque': marque,
        if (volumeM3 != null) 'volume_m3': volumeM3,
        if (photoUrl != null) 'photo_url': photoUrl,
      },
    );
    return Vehicle.fromJson(json);
  }

  Future<Vehicle> updateVehicle(
    String id, {
    String? type,
    double? chargeMaxKg,
    String? immatriculation,
    String? marque,
    double? volumeM3,
    String? photoUrl,
    bool? isActive,
  }) async {
    final json = await _api.put<Map<String, dynamic>>(
      ApiEndpoints.vehicleById(id),
      body: {
        if (type != null) 'type': type,
        if (chargeMaxKg != null) 'charge_max_kg': chargeMaxKg,
        if (immatriculation != null) 'immatriculation': immatriculation,
        if (marque != null) 'marque': marque,
        if (volumeM3 != null) 'volume_m3': volumeM3,
        if (photoUrl != null) 'photo_url': photoUrl,
        if (isActive != null) 'is_active': isActive,
      },
    );
    return Vehicle.fromJson(json);
  }

  Future<void> deleteVehicle(String id) async {
    await _api.delete<dynamic>(ApiEndpoints.vehicleById(id));
  }

  // ─── Lifecycle shipment ──────────────────────────────────────────────

  Future<Livraison> acceptShipment(String id) async {
    final json = await _api.post<Map<String, dynamic>>(
      ApiEndpoints.shipmentAccept(id),
    );
    return Livraison.fromJson(json);
  }

  /// LOADING : le transporteur a démarré le chargement chez le vendeur.
  /// `pickup_position` (GPS) est optionnel — sert d'audit.
  Future<Livraison> startLoading({
    required String id,
    double? lat,
    double? lng,
  }) async {
    final json = await _api.post<Map<String, dynamic>>(
      ApiEndpoints.shipmentStartLoading(id),
      body: {
        if (lat != null && lng != null)
          'pickup_position': {'lat': lat, 'lng': lng},
      },
    );
    return Livraison.fromJson(json);
  }

  /// Point GPS périodique pendant le transit. Status optionnel — si fourni,
  /// transitionne (ex. `IN_TRANSIT`).
  Future<Livraison> trackPosition({
    required String id,
    required double lat,
    required double lng,
    ShipmentStatus? status,
    String? note,
  }) async {
    final json = await _api.post<Map<String, dynamic>>(
      ApiEndpoints.shipmentTrack(id),
      body: {
        'position': {'lat': lat, 'lng': lng},
        if (status != null) 'status': status.apiValue,
        if (note != null) 'note': note,
      },
    );
    return Livraison.fromJson(json);
  }

  /// DELIVERED : preuve photo obligatoire (`photo_preuve_url`). La position
  /// GPS et la note sont des optionnels d'audit/UX.
  Future<Livraison> markDelivered({
    required String id,
    required String photoPreuveUrl,
    double? lat,
    double? lng,
    String? note,
  }) async {
    final json = await _api.post<Map<String, dynamic>>(
      ApiEndpoints.shipmentDeliver(id),
      body: {
        'photo_preuve_url': photoPreuveUrl,
        if (lat != null && lng != null)
          'delivery_position': {'lat': lat, 'lng': lng},
        if (note != null) 'note': note,
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

  // ─── Évaluation post-livraison (BUYER → TRANSPORTER) ───────────────

  /// Récupère l'évaluation existante (ou null si non encore évalué).
  Future<ShipmentEvaluation?> getShipmentEvaluation(String shipmentId) async {
    try {
      final json = await _api.get<Map<String, dynamic>>(
        ApiEndpoints.shipmentEvaluation(shipmentId),
      );
      return ShipmentEvaluation.fromJson(json);
    } catch (_) {
      return null;
    }
  }

  /// Soumet une évaluation de la livraison (note 1-5 + commentaire).
  /// Recalcule la moyenne du transporteur côté backend.
  Future<ShipmentEvaluation> evaluateShipment({
    required String shipmentId,
    required int note,
    String? commentaire,
  }) async {
    final json = await _api.post<Map<String, dynamic>>(
      ApiEndpoints.shipmentEvaluation(shipmentId),
      body: {
        'note': note,
        if (commentaire != null && commentaire.isNotEmpty)
          'commentaire': commentaire,
      },
    );
    return ShipmentEvaluation.fromJson(json);
  }

  // ─── Pickup QR (chantier 1) ──────────────────────────────────────────

  /// FARMER (seller) génère un QR signé pour preuve d'enlèvement.
  /// TTL court (15 min serveur).
  Future<PickupQrToken> generatePickupQrToken(String shipmentId) async {
    final json = await _api.get<Map<String, dynamic>>(
      ApiEndpoints.shipmentQrToken(shipmentId),
    );
    return PickupQrToken.fromJson(json);
  }

  /// TRANSPORTER scanne le QR du producteur → shipment passe en LOADING
  /// et l'escrow PRODUCT est libéré automatiquement.
  ///
  /// La position GPS (`lat`/`lng`) est obligatoire côté backend (anti-fraude
  /// : distance < 500 m du pickup_location attendu).
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

  // ─── Delivery QR (symétrique pickup) ────────────────────────────────

  /// Récupère le shipment d'une commande. Accessible aux 3 parties
  /// (buyer, seller, transporter). Le buyer s'en sert pour connaître
  /// le shipment_id et générer son delivery QR.
  ///
  /// Retourne `null` quand la commande n'a pas encore de shipment
  /// (statut SENT/ACCEPTED, ou état incohérent en dev). C'est un cas
  /// normal — pas une erreur. Avant 2026-05-27 le backend throwait
  /// 404 ici, ce qui polluait le log mobile en rouge sur un cas pourtant
  /// attendu. Maintenant il retourne `null` proprement.
  Future<Livraison?> getShipmentByCommande(String commandeId) async {
    final json = await _api.get<Map<String, dynamic>?>(
      ApiEndpoints.shipmentByCommande(commandeId),
    );
    if (json == null) return null;
    return Livraison.fromJson(json);
  }

  /// BUYER (acheteur) génère un QR signé pour confirmation de livraison.
  /// TTL 15 min — l'acheteur le montre au transporteur à l'arrivée.
  Future<PickupQrToken> generateDeliveryQrToken(String shipmentId) async {
    final json = await _api.get<Map<String, dynamic>>(
      ApiEndpoints.shipmentDeliveryQrToken(shipmentId),
    );
    return PickupQrToken.fromJson(json);
  }

  /// TRANSPORTER scanne le QR de l'acheteur → shipment DELIVERED, escrow
  /// TRANSPORT libéré, commande passe en COMPLETED. Évite à l'acheteur
  /// d'avoir à cliquer "Confirmer la réception" manuellement.
  ///
  /// La position GPS est obligatoire (anti-fraude < 500 m du
  /// delivery_location attendu). La photo de preuve aussi (garde-fou
  /// en cas de litige post-livraison).
  Future<Map<String, dynamic>> scanDelivery({
    required String shipmentId,
    required String token,
    required double lat,
    required double lng,
    required String photoPreuveUrl,
    String? note,
  }) async {
    return _api.post<Map<String, dynamic>>(
      ApiEndpoints.shipmentScanDelivery(shipmentId),
      body: {
        'token': token,
        'scan_position': {'lat': lat, 'lng': lng},
        'photo_preuve_url': photoPreuveUrl,
        if (note != null && note.isNotEmpty) 'note': note,
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
