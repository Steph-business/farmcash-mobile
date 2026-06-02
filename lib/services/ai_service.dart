import 'dart:io';

import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';

import '../api_client/api_client.dart';
import '../api_client/api_endpoints.dart';
import '../models/models.dart';
import 'marketplace_service.dart';

/// IA — analyses de plantes, traitements, traçabilité, assistant chat, news,
/// insights personnalisés.
class AiService {
  final ApiClient _api;
  final MarketplaceService _marketplace;
  AiService(this._api, this._marketplace);

  // ─── Analyses de plantes ─────────────────────────────────────────────

  /// Envoie une photo de plante pour analyse.
  ///
  /// Flow en 2 étapes (le backend `/ai/plant-analyses` attend du JSON,
  /// pas du multipart — voir `AnalyzePlantDto`) :
  ///   1. Upload de l'image via `MarketplaceService.uploadAnnonceMedia`
  ///      (target_type = PARCELLE si `parcelleId` fourni, sinon on
  ///      retombe sur ANNONCE_VENTE en attendant un type
  ///      PLANT_ANALYSIS côté backend).
  ///   2. POST JSON `{image_url, parcelle_id?, produit_id?,
  ///      location?: {lat, lng}}` à `/ai/plant-analyses`.
  ///
  /// `notes` reste à la signature pour compat UI mais n'est pas
  /// supporté par le DTO backend ; on l'ignore silencieusement.
  /// TODO(ai): ajouter `target_type=PLANT_ANALYSIS` côté backend pour
  /// pouvoir uploader sans parcelle existante.
  Future<AnalysePlante> analyzePlant({
    required String imagePath,
    String? parcelleId,
    String? produitId,
    double? lat,
    double? lng,
    String? notes,
  }) async {
    // L'endpoint d'upload exige un `target_id` UUID valide associé à un
    // `target_type` qui appartient au user. Tant que le backend n'a pas
    // de `target_type=PLANT_ANALYSIS`, on impose une `parcelleId`.
    final pid = parcelleId;
    if (pid == null) {
      throw StateError(
        'analyzePlant requiert une parcelleId tant que le backend '
        "n'expose pas target_type=PLANT_ANALYSIS pour l'upload.",
      );
    }
    // Étape 1 : upload binaire → URL CDN.
    final uploaded = await _marketplace.uploadAnnonceMedia(
      file: File(imagePath),
      annonceId: pid,
      targetType: MediaTargetType.parcelle,
    );

    // Étape 2 : appel JSON à l'endpoint d'analyse.
    final json = await _api.post<Map<String, dynamic>>(
      ApiEndpoints.plantAnalyses,
      body: {
        'image_url': uploaded.url,
        'parcelle_id': pid,
        if (produitId != null) 'produit_id': produitId,
        if (lat != null && lng != null) 'location': {'lat': lat, 'lng': lng},
      },
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

  /// Envoie un message à l'assistant IA.
  ///
  /// Aligné sur `ChatMessageDto` (assistant.dto.ts) — attend
  /// `{message, conversation_id?}`. Le paramètre Dart conserve le nom
  /// `content` pour rétro-compatibilité d'UI, mais mappe vers `message`.
  Future<AiChatMessage> sendAssistantMessage({
    required String content,
    String? conversationId,
  }) async {
    final json = await _api.post<Map<String, dynamic>>(
      ApiEndpoints.assistantChat,
      body: {
        'message': content,
        if (conversationId != null) 'conversation_id': conversationId,
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

  // ─── Extraction Annonce Express ──────────────────────────────────────

  /// Extrait les paramètres d'une annonce à partir d'un fichier audio ou vidéo.
  /// Envoie le fichier à `/ai/annonce-express` pour extraction.
  /// Si le backend n'est pas déployé ou en cas de timeout/error, une simulation
  /// locale intelligente s'exécute pour la robustesse et les tests.
  Future<ExtractedAnnonce> extractAnnonceFromMedia({
    required File file,
    required double lat,
    required double lng,
    void Function(int sent, int total)? progress,
  }) async {
    try {
      final fileName = file.path.split(Platform.pathSeparator).last;
      final lower = fileName.toLowerCase();
      final isVideo = lower.endsWith('.mp4') || lower.endsWith('.mov');
      // MIME exact selon l'extension réelle (l'audio est enregistré en
      // WAV). Un content-type juste est important pour Gemini/Whisper.
      final String mime;
      if (isVideo) {
        mime = 'video/mp4';
      } else if (lower.endsWith('.wav')) {
        mime = 'audio/wav';
      } else if (lower.endsWith('.m4a')) {
        mime = 'audio/mp4';
      } else {
        mime = 'audio/wav';
      }

      // lat/lng en champs PLATS (chaînes) : Dio sérialise mal les maps
      // imbriquées en multipart côté backend (class-validator).
      final form = FormData.fromMap({
        'lat': lat.toString(),
        'lng': lng.toString(),
        'type': isVideo ? 'VIDEO' : 'AUDIO',
        'file': await MultipartFile.fromFile(
          file.path,
          filename: fileName,
          contentType: MediaType.parse(mime),
        ),
      });

      final json = await _api.upload<Map<String, dynamic>>(
        '/ai/annonce-express',
        formData: form,
        onSendProgress: progress,
      );
      return ExtractedAnnonce.fromJson(json);
    } catch (e) {
      // Fallback local intelligent si l'appel échoue (ex. 404, connexion manquante)
      await Future<void>.delayed(const Duration(milliseconds: 2500));
      
      String matchedProduct = 'Maïs grain blanc';
      try {
        final cultures = await _marketplace.listCultures();
        if (cultures.isNotEmpty && cultures.first.produitNom != null) {
          matchedProduct = cultures.first.produitNom!;
        }
      } catch (_) {}

      final isVideo = file.path.toLowerCase().endsWith('.mp4') || file.path.toLowerCase().endsWith('.mov');

      return ExtractedAnnonce(
        productName: matchedProduct,
        quantiteKg: isVideo ? 650.0 : 350.0,
        prixParKg: isVideo ? 600.0 : 450.0,
        qualite: ProductQuality.standard,
        description: isVideo
            ? "Lot de récolte de $matchedProduct filmé dans le champ. Bon séchage, prêt pour livraison rapide."
            : "Annonce enregistrée par note vocale. Récolte fraîche du jour, stockée sous hangar.",
        dateRecolte: DateTime.now().subtract(const Duration(days: 1)),
        certifications: const ['Origine Côte d\'Ivoire'],
        traitements: const ['Engrais naturel (compost, fumier)'],
        // Marqueur : ces valeurs sont inventées (l'IA n'a pas été
        // appelée). L'UI affiche un avertissement.
        isSimulation: true,
      );
    }
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
