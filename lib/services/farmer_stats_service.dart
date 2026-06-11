import '../api_client/api_client.dart';
import '../api_client/api_endpoints.dart';
import '../models/farmer_stats.dart';

/// Tableau de bord analytique du PRODUCTEUR (rôle FARMER).
///
/// Branche les endpoints `GET /oversight/farmer/*` consommés par la page
/// « Mes statistiques » : vue agrégée, actions en attente, funnel de
/// conversion par annonce. Endpoints backend dans
/// `modules/oversight/src/farmer-oversight.*`.
class FarmerStatsService {
  final ApiClient _api;

  FarmerStatsService(this._api);

  /// Vue agrégée : commerce, revenus 30j, cultures, note, wallet.
  Future<FarmerOverview> getOverview() async {
    final raw = await _api.get<dynamic>(ApiEndpoints.farmerOverview);
    return FarmerOverview.fromJson(_asMap(raw));
  }

  /// Mini-todo board : candidatures, livraisons, prévisions, annonces coop.
  Future<FarmerPendingActions> getPendingActions() async {
    final raw = await _api.get<dynamic>(ApiEndpoints.farmerPendingActions);
    return FarmerPendingActions.fromJson(_asMap(raw));
  }

  /// Funnel de conversion par annonce active (vues → candidatures →
  /// commandes). Le backend renvoie un tableau brut.
  Future<List<FarmerConversionRow>> getConversionFunnel() async {
    final raw = await _api.get<dynamic>(ApiEndpoints.farmerConversionFunnel);
    return _asList(raw, FarmerConversionRow.fromJson);
  }

  // ─── Helpers ─────────────────────────────────────────────────────────

  /// Tolère soit un objet brut, soit l'enveloppe `{data: {...}}`.
  Map<String, dynamic> _asMap(dynamic raw) {
    if (raw is Map) {
      if (raw['data'] is Map) {
        return (raw['data'] as Map).cast<String, dynamic>();
      }
      return raw.cast<String, dynamic>();
    }
    return const {};
  }

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
