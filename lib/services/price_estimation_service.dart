import '../api_client/api_client.dart';
import '../api_client/api_endpoints.dart';
import '../models/price_estimate.dart';

/// Service best-effort autour de `GET /ai/price-estimate`.
///
/// Le badge "Prix marché" est un nice-to-have : si l'endpoint échoue, on
/// retourne `null` plutôt que de propager l'exception. Aucune erreur
/// visible côté UI — le widget retombe simplement sur `SizedBox.shrink()`.
///
/// Côté producteur (publier annonce) : appelé pour afficher la fourchette
/// de marché à côté du champ prix + verdict si saisie.
/// Côté acheteur (fiche annonce, fiche publication coop) : appelé pour
/// afficher l'écart vs marché ("Sous le marché −15 % ✅", etc.).
class PriceEstimationService {
  final ApiClient _api;

  PriceEstimationService(this._api);

  /// Récupère une estimation de prix pour `produitId`.
  ///
  /// - [regionId] : filtre régional optionnel. Quand fourni, le backend
  ///   privilégie les commandes locales (meilleur signal prix).
  /// - [qualite] : `STANDARD | PREMIUM | BIO | EQUITABLE` — backend
  ///   filtre par qualité pour aligner la médiane sur le bon segment.
  /// - [periodDays] : fenêtre temporelle. Default backend = 90 jours.
  ///
  /// Retourne `null` si l'appel échoue (réseau, 5xx, parse error). Pas
  /// de crash, pas de toast — la feature reste silencieuse.
  Future<PriceEstimate?> estimate({
    required String produitId,
    String? regionId,
    String? qualite,
    int? periodDays,
  }) async {
    try {
      final json = await _api.get<Map<String, dynamic>>(
        ApiEndpoints.aiPriceEstimate,
        query: {
          'produit_id': produitId,
          if (regionId != null && regionId.isNotEmpty) 'region_id': regionId,
          if (qualite != null && qualite.isNotEmpty) 'qualite': qualite,
          if (periodDays != null) 'period_days': periodDays,
        },
      );
      return PriceEstimate.fromJson(json);
    } catch (_) {
      // Best-effort : on absorbe tout pour ne jamais polluer l'UI.
      return null;
    }
  }
}
