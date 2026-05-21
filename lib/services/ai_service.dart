import 'package:dio/dio.dart';

import '../api_client/api_client.dart';
import '../api_client/api_endpoints.dart';
import '../models/models.dart';

/// IA — analyses de plantes, traitements, traçabilité, assistant chat, news,
/// insights personnalisés.
class AiService {
  final ApiClient _api;
  AiService(this._api);

  // ─── Analyses de plantes ─────────────────────────────────────────────

  /// Envoie une photo de plante pour analyse.
  ///
  /// [imagePath] : chemin local de l'image (camera ou galerie).
  /// Renvoie l'analyse créée + ses recommandations.
  Future<AnalysePlante> analyzePlant({
    required String imagePath,
    String? parcelleId,
    String? produitId,
    String? notes,
  }) async {
    final formData = FormData.fromMap({
      'image': await MultipartFile.fromFile(imagePath, filename: 'plant.jpg'),
      if (parcelleId != null) 'parcelle_id': parcelleId,
      if (produitId != null) 'produit_id': produitId,
      if (notes != null) 'notes': notes,
    });
    final json = await _api.upload<Map<String, dynamic>>(
      ApiEndpoints.plantAnalyses,
      formData: formData,
    );
    return AnalysePlante.fromJson(json);
  }

  Future<Paginated<AnalysePlante>> listPlantAnalyses({
    int page = 1,
    int limit = 20,
    String? parcelleId,
  }) async {
    final raw = await _api.get<dynamic>(
      ApiEndpoints.plantAnalyses,
      query: {
        'page': page,
        'limit': limit,
        if (parcelleId != null) 'parcelle_id': parcelleId,
      },
    );
    return Paginated.fromJsonOrList(raw, AnalysePlante.fromJson);
  }

  Future<AnalysePlante> getPlantAnalysis(String id) async {
    final json = await _api.get<Map<String, dynamic>>(
      ApiEndpoints.plantAnalysisById(id),
    );
    return AnalysePlante.fromJson(json);
  }

  // ─── Traitements ─────────────────────────────────────────────────────

  Future<List<Traitement>> listTreatments({
    String? type,
    bool? isBio,
    String? maladie,
  }) async {
    final raw = await _api.get<dynamic>(
      ApiEndpoints.treatments,
      query: {
        if (type != null) 'type': type,
        if (isBio != null) 'is_bio': isBio,
        if (maladie != null) 'maladie': maladie,
      },
    );
    return _asList(raw, Traitement.fromJson);
  }

  Future<List<Traitement>> getTreatmentsForAnalysis(String analysisId) async {
    final raw = await _api.get<dynamic>(
      ApiEndpoints.treatmentsForAnalysis(analysisId),
    );
    return _asList(raw, Traitement.fromJson);
  }

  Future<List<Traitement>> searchTreatments(String q) async {
    final raw = await _api.get<dynamic>(
      ApiEndpoints.treatmentsSearch,
      query: {'q': q},
    );
    return _asList(raw, Traitement.fromJson);
  }

  Future<Traitement> getTreatment(String id) async {
    final json = await _api.get<Map<String, dynamic>>(
      ApiEndpoints.treatmentById(id),
    );
    return Traitement.fromJson(json);
  }

  // ─── Traçabilité (public, scan QR) ───────────────────────────────────

  /// Historique brut d'un lot (legacy, kept for compatibility with the
  /// public scan QR flow). Préférer `getLotTraceability` qui renvoie
  /// aussi les infos du lot (produit, code, date de récolte).
  Future<List<TraceabilityEvent>> getTraceability(String lotId) async {
    final raw = await _api.get<dynamic>(
      ApiEndpoints.traceability(lotId),
      options: Options(extra: {'skipAuth': true}),
    );
    // Le backend renvoie `{ lot, events: [...] }` — on extrait `events`
    // pour conserver la signature historique de cette méthode.
    if (raw is Map && raw['events'] is List) {
      return (raw['events'] as List)
          .whereType<Map>()
          .map((m) => TraceabilityEvent.fromJson(m.cast<String, dynamic>()))
          .toList();
    }
    return _asList(raw, TraceabilityEvent.fromJson);
  }

  /// Parcours complet d'un lot pour la vue "from-farm-to-fork" côté acheteur.
  /// Renvoie le payload brut `{ lot, events }` car la coquille est riche
  /// (voir `lot.produit`, `lot.lot_code`, `lot.date_recolte`, …).
  /// Endpoint public — pas besoin de JWT (scan QR consommateur).
  Future<Map<String, dynamic>> getLotTraceability(String lotId) async {
    final raw = await _api.get<dynamic>(
      ApiEndpoints.traceability(lotId),
      options: Options(extra: {'skipAuth': true}),
    );
    if (raw is Map) return raw.cast<String, dynamic>();
    return const <String, dynamic>{};
  }

  // ─── Assistant conversationnel ───────────────────────────────────────

  Future<AiChatMessage> sendAssistantMessage({
    required String content,
    Map<String, dynamic>? context,
  }) async {
    final json = await _api.post<Map<String, dynamic>>(
      ApiEndpoints.assistantChat,
      body: {
        'content': content,
        if (context != null) 'context': context,
      },
    );
    return AiChatMessage.fromJson(json);
  }

  Future<List<AiChatMessage>> getAssistantHistory({int limit = 50}) async {
    final raw = await _api.get<dynamic>(
      ApiEndpoints.assistantHistory,
      query: {'limit': limit},
    );
    return _asList(raw, AiChatMessage.fromJson);
  }

  Future<void> resetAssistantSession() async {
    await _api.post<dynamic>(ApiEndpoints.assistantReset);
  }

  // ─── Insights ────────────────────────────────────────────────────────

  Future<AiInsights> getMyInsights() async {
    final json = await _api.get<Map<String, dynamic>>(
      ApiEndpoints.insightsMy,
    );
    return AiInsights.fromJson(json);
  }

  // ─── News ────────────────────────────────────────────────────────────

  Future<Paginated<NewsItem>> listNews({
    int page = 1,
    int limit = 20,
  }) async {
    final raw = await _api.get<dynamic>(
      ApiEndpoints.news,
      query: {'page': page, 'limit': limit},
    );
    return Paginated.fromJsonOrList(raw, NewsItem.fromJson);
  }

  Future<NewsItem> getNews(String id) async {
    final json = await _api.get<Map<String, dynamic>>(
      ApiEndpoints.newsById(id),
    );
    return NewsItem.fromJson(json);
  }

  // ─── Helper ──────────────────────────────────────────────────────────

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
