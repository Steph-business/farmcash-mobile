import '../api_client/api_client.dart';
import '../api_client/api_endpoints.dart';
import '../models/models.dart';

/// Logistique côté COOPÉRATIVE : parc véhicules + collectes internes
/// planifiées (membre → coop).
class CoopLogisticsService {
  final ApiClient _api;
  CoopLogisticsService(this._api);

  // ─── Véhicules du parc coop ─────────────────────────────────────────

  Future<List<CoopVehicle>> listVehicles() async {
    final raw = await _api.get<dynamic>(ApiEndpoints.coopVehicles);
    return _asList(raw, CoopVehicle.fromJson);
  }

  Future<CoopVehicle> createVehicle({
    required String type,
    required double chargeMaxKg,
    String? immatriculation,
    String? marque,
    String? chauffeurNom,
    String? chauffeurPhone,
  }) async {
    final json = await _api.post<Map<String, dynamic>>(
      ApiEndpoints.coopVehicles,
      body: {
        'type': type,
        'charge_max_kg': chargeMaxKg,
        if (immatriculation != null) 'immatriculation': immatriculation,
        if (marque != null) 'marque': marque,
        if (chauffeurNom != null) 'chauffeur_nom': chauffeurNom,
        if (chauffeurPhone != null) 'chauffeur_phone': chauffeurPhone,
      },
    );
    return CoopVehicle.fromJson(json);
  }

  Future<CoopVehicle> updateVehicle(
    String id, {
    String? type,
    double? chargeMaxKg,
    String? immatriculation,
    String? marque,
    String? chauffeurNom,
    String? chauffeurPhone,
    bool? isActive,
  }) async {
    final json = await _api.put<Map<String, dynamic>>(
      ApiEndpoints.coopVehicleById(id),
      body: {
        if (type != null) 'type': type,
        if (chargeMaxKg != null) 'charge_max_kg': chargeMaxKg,
        if (immatriculation != null) 'immatriculation': immatriculation,
        if (marque != null) 'marque': marque,
        if (chauffeurNom != null) 'chauffeur_nom': chauffeurNom,
        if (chauffeurPhone != null) 'chauffeur_phone': chauffeurPhone,
        if (isActive != null) 'is_active': isActive,
      },
    );
    return CoopVehicle.fromJson(json);
  }

  Future<void> deleteVehicle(String id) async {
    await _api.delete<dynamic>(ApiEndpoints.coopVehicleById(id));
  }

  // ─── Collectes internes (membre → coop) ─────────────────────────────

  Future<List<CoopCollection>> listCollections({String? status}) async {
    final raw = await _api.get<dynamic>(
      ApiEndpoints.coopCollections,
      query: {if (status != null) 'status': status},
    );
    return _asList(raw, CoopCollection.fromJson);
  }

  Future<CoopCollection> createCollection({
    required String farmerId,
    required DateTime scheduledAt,
    required String pickupAddress,
    required double quantitePrevueKg,
    String? vehicleId,
    String? annonceVenteId,
    String? notes,
  }) async {
    final json = await _api.post<Map<String, dynamic>>(
      ApiEndpoints.coopCollections,
      body: {
        'farmer_id': farmerId,
        'scheduled_at': scheduledAt.toIso8601String(),
        'pickup_address': pickupAddress,
        'quantite_prevue_kg': quantitePrevueKg,
        if (vehicleId != null) 'vehicle_id': vehicleId,
        if (annonceVenteId != null) 'annonce_vente_id': annonceVenteId,
        if (notes != null) 'notes': notes,
      },
    );
    return CoopCollection.fromJson(json);
  }

  Future<CoopCollection> updateCollection(
    String id, {
    DateTime? scheduledAt,
    String? status,
    String? vehicleId,
    String? notes,
  }) async {
    final json = await _api.put<Map<String, dynamic>>(
      ApiEndpoints.coopCollectionById(id),
      body: {
        if (scheduledAt != null) 'scheduled_at': scheduledAt.toIso8601String(),
        if (status != null) 'status': status,
        if (vehicleId != null) 'vehicle_id': vehicleId,
        if (notes != null) 'notes': notes,
      },
    );
    return CoopCollection.fromJson(json);
  }

  Future<CoopCollection> completeCollection(String id) async {
    final json = await _api.post<Map<String, dynamic>>(
      ApiEndpoints.coopCollectionComplete(id),
    );
    return CoopCollection.fromJson(json);
  }

  Future<void> cancelCollection(String id) async {
    await _api.delete<dynamic>(ApiEndpoints.coopCollectionById(id));
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
