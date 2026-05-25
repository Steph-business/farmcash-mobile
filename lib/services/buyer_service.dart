import '../api_client/api_client.dart';
import '../api_client/api_endpoints.dart';
import '../models/models.dart';

/// Service BUYER : adresses de livraison + (futur) préférences.
class BuyerService {
  final ApiClient _api;
  BuyerService(this._api);

  // ─── Adresses de livraison ──────────────────────────────────────────

  /// Liste les adresses du BUYER connecté. L'adresse `is_default = true`
  /// est toujours en première position côté backend.
  Future<List<BuyerAddress>> listAddresses() async {
    final raw = await _api.get<dynamic>(ApiEndpoints.buyerAddresses);
    return _asList(raw, BuyerAddress.fromJson);
  }

  /// Crée une adresse. Si [isDefault] est vrai, les autres adresses du
  /// user sont automatiquement débadgées par le backend dans une
  /// transaction (cohérence garantie).
  ///
  /// Aligné sur `CreateBuyerAddressDto` — `libelle`, `contact_nom`,
  /// `contact_phone`, `adresse_complete` sont REQUIRED côté backend.
  Future<BuyerAddress> createAddress({
    required String libelle,
    required String contactNom,
    required String contactPhone,
    required String adresseComplete,
    String? villeId,
    double? lat,
    double? lng,
    bool isDefault = false,
  }) async {
    final json = await _api.post<Map<String, dynamic>>(
      ApiEndpoints.buyerAddresses,
      body: {
        'libelle': libelle,
        'contact_nom': contactNom,
        'contact_phone': contactPhone,
        'adresse_complete': adresseComplete,
        if (villeId != null) 'ville_id': villeId,
        if (lat != null) 'lat': lat,
        if (lng != null) 'lng': lng,
        'is_default': isDefault,
      },
    );
    return BuyerAddress.fromJson(json);
  }

  Future<BuyerAddress> updateAddress(
    String id, {
    String? libelle,
    String? contactNom,
    String? contactPhone,
    String? adresseComplete,
    String? villeId,
    double? lat,
    double? lng,
    bool? isDefault,
  }) async {
    final json = await _api.put<Map<String, dynamic>>(
      ApiEndpoints.buyerAddressById(id),
      body: {
        if (libelle != null) 'libelle': libelle,
        if (contactNom != null) 'contact_nom': contactNom,
        if (contactPhone != null) 'contact_phone': contactPhone,
        if (adresseComplete != null) 'adresse_complete': adresseComplete,
        if (villeId != null) 'ville_id': villeId,
        if (lat != null) 'lat': lat,
        if (lng != null) 'lng': lng,
        if (isDefault != null) 'is_default': isDefault,
      },
    );
    return BuyerAddress.fromJson(json);
  }

  /// Soft delete (côté back : set `is_active = false`). Si l'adresse
  /// supprimée était la default, le back en désigne une autre.
  Future<void> deleteAddress(String id) async {
    await _api.delete<dynamic>(ApiEndpoints.buyerAddressById(id));
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
