import '../api_client/api_client.dart';
import '../api_client/api_endpoints.dart';
import '../models/matching.dart';

/// Matching intelligent — connecte les acteurs sur la base des cultures
/// déclarées, des annonces actives et des régions.
///
/// Côté producteur : liste les demandes d'achat qui matchent ses cultures.
/// Côté acheteur / coop : liste les producteurs qui matchent une demande
/// d'achat précise. Endpoints backend dans `modules/ai/src/matching.*`.
class MatchingService {
  final ApiClient _api;

  MatchingService(this._api);

  /// Opportunités du producteur connecté — demandes d'achat actives qui
  /// matchent ses cultures déclarées. Le scoring est calculé côté backend
  /// (match exact produit + bonus région + bonus annonce active).
  Future<List<MatchingOpportunity>> listMyOpportunities() async {
    final raw = await _api.get<dynamic>(
      ApiEndpoints.aiMatchingOpportunities,
    );
    return _asList(raw, MatchingOpportunity.fromJson);
  }

  /// Producteurs matchant une demande d'achat précise — vue acheteur / coop.
  /// Le tri par score (région + culture déclarée + annonce active) est
  /// fait côté backend.
  Future<List<MatchedSupplier>> listMatchingSuppliers(String annonceId) async {
    final raw = await _api.get<dynamic>(
      ApiEndpoints.aiMatchingSuppliersFor(annonceId),
    );
    return _asList(raw, MatchedSupplier.fromJson);
  }

  // ─── Helpers ─────────────────────────────────────────────────────────

  /// Tolère soit un tableau brut, soit l'enveloppe `{data: [...]}`.
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
