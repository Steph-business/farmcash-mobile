import 'dart:io';

import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';

import '../api_client/api_client.dart';
import '../api_client/api_endpoints.dart';
import '../models/models.dart';

/// Cible d'un upload de média : annonce de vente, publication coop, ou lot.
enum MediaTargetType { annonceVente, publicationCoop, lot }

extension on MediaTargetType {
  String get apiValue {
    switch (this) {
      case MediaTargetType.annonceVente:
        return 'ANNONCE_VENTE';
      case MediaTargetType.publicationCoop:
        return 'PUBLICATION_COOP';
      case MediaTargetType.lot:
        return 'LOT';
    }
  }
}

/// Réponse de l'endpoint `POST /interactions/medias/upload`.
class UploadedMedia {
  const UploadedMedia({
    required this.id,
    required this.url,
    this.thumbnailUrl,
  });

  factory UploadedMedia.fromJson(Map<String, dynamic> json) => UploadedMedia(
        id: json['id'] as String,
        url: json['url'] as String,
        thumbnailUrl: json['thumbnail_url'] as String?,
      );

  final String id;
  final String url;
  final String? thumbnailUrl;
}

/// Marketplace — catalogue, annonces vente/achat, panier, interactions,
/// stocks, agronomie, prévisions.
class MarketplaceService {
  final ApiClient _api;
  MarketplaceService(this._api);

  // ─── Catalogue ───────────────────────────────────────────────────────

  Future<List<Produit>> listProduits() async {
    final raw = await _api.get<dynamic>(ApiEndpoints.produits);
    return _asList(raw, Produit.fromJson);
  }

  Future<List<Categorie>> listCategories() async {
    final raw = await _api.get<dynamic>(ApiEndpoints.categories);
    return _asList(raw, Categorie.fromJson);
  }

  /// Référentiel des villes CI (~40 entrées). Endpoint public, charge
  /// une fois par session.
  Future<List<Ville>> listVilles() async {
    final raw = await _api.get<dynamic>(ApiEndpoints.villes);
    return _asList(raw, Ville.fromJson);
  }

  // ─── Annonces de vente ───────────────────────────────────────────────

  Future<Paginated<AnnonceVente>> listAnnoncesVente({
    String? produitId,
    String? regionId,
    ProductQuality? qualite,
    double? prixMin,
    double? prixMax,
    String? search,
    int page = 1,
    int limit = 20,
  }) async {
    final raw = await _api.get<dynamic>(
      ApiEndpoints.annoncesVente,
      query: {
        if (produitId != null) 'produit_id': produitId,
        if (regionId != null) 'region_id': regionId,
        if (qualite != null) 'qualite': qualite.apiValue,
        if (prixMin != null) 'prix_min': prixMin,
        if (prixMax != null) 'prix_max': prixMax,
        if (search != null && search.isNotEmpty) 'q': search,
        'page': page,
        'limit': limit,
      },
    );
    return Paginated.fromJsonOrList(raw, AnnonceVente.fromJson);
  }

  Future<AnnonceVente> getAnnonceVente(String id) async {
    final json = await _api.get<Map<String, dynamic>>(
      ApiEndpoints.annonceVenteById(id),
    );
    return AnnonceVente.fromJson(json);
  }

  /// Crée une annonce de vente côté FARMER.
  ///
  /// Champs obligatoires : produit, titre, quantité, prix, qualité, et
  /// les coordonnées GPS (`lat`/`lng` — le back exige `coordinates`).
  ///
  /// Options :
  ///   • [quantiteMinKg]            : quantité minimum vendable. Si nulle,
  ///     le back applique la valeur de `quantiteKg` (l'acheteur prend tout).
  ///   • [assignedToCooperativeId] : si renseigné, l'annonce passe en
  ///     workflow validation par la coop (statut PENDING jusqu'à intégration).
  ///   • [disponibleJusqu]         : date limite de disponibilité.
  ///
  /// Les photos ne sont PAS envoyées ici — elles s'attachent dans un
  /// second temps via [uploadAnnonceMedia] (multipart MinIO).
  Future<AnnonceVente> createAnnonceVente({
    required String produitId,
    required String titre,
    required double quantiteKg,
    required double prixParKg,
    required double lat,
    required double lng,
    required ProductQuality qualite,
    String? description,
    List<String>? certifications,
    String? regionId,
    String? villeId,
    double? quantiteMinKg,
    String? assignedToCooperativeId,
    DateTime? disponibleJusqu,
  }) async {
    final json = await _api.post<Map<String, dynamic>>(
      ApiEndpoints.annoncesVente,
      body: {
        'produit_id': produitId,
        'titre': titre,
        'quantite_kg': quantiteKg,
        'prix_par_kg': prixParKg,
        'qualite': qualite.apiValue,
        'coordinates': {'lat': lat, 'lng': lng},
        if (quantiteMinKg != null) 'quantite_min_kg': quantiteMinKg,
        if (description != null && description.isNotEmpty)
          'description': description,
        if (certifications != null && certifications.isNotEmpty)
          'certifications': certifications,
        if (regionId != null) 'region_id': regionId,
        if (villeId != null) 'ville_id': villeId,
        if (disponibleJusqu != null)
          'disponible_jusqu':
              disponibleJusqu.toIso8601String().split('T').first,
        if (assignedToCooperativeId != null)
          'assigned_to_cooperative_id': assignedToCooperativeId,
      },
    );
    return AnnonceVente.fromJson(json);
  }

  Future<AnnonceVente> updateAnnonceVente(
    String id, {
    String? titre,
    double? quantiteKg,
    double? prixParKg,
    String? description,
    ProductStatus? status,
    List<String>? photos,
  }) async {
    final json = await _api.put<Map<String, dynamic>>(
      ApiEndpoints.annonceVenteById(id),
      body: {
        if (titre != null) 'titre': titre,
        if (quantiteKg != null) 'quantite_kg': quantiteKg,
        if (prixParKg != null) 'prix_par_kg': prixParKg,
        if (description != null) 'description': description,
        if (status != null) 'status': status.apiValue,
        if (photos != null) 'photos': photos,
      },
    );
    return AnnonceVente.fromJson(json);
  }

  Future<void> deleteAnnonceVente(String id) async {
    await _api.delete<dynamic>(ApiEndpoints.annonceVenteById(id));
  }

  // ─── Annonces d'achat ────────────────────────────────────────────────

  Future<Paginated<AnnonceAchat>> listAnnoncesAchat({
    String? produitId,
    String? regionId,
    double? prixMax,
    int page = 1,
    int limit = 20,
  }) async {
    final raw = await _api.get<dynamic>(
      ApiEndpoints.annoncesAchat,
      query: {
        if (produitId != null) 'produit_id': produitId,
        if (regionId != null) 'region_id': regionId,
        if (prixMax != null) 'prix_max': prixMax,
        'page': page,
        'limit': limit,
      },
    );
    return Paginated.fromJsonOrList(raw, AnnonceAchat.fromJson);
  }

  Future<AnnonceAchat> getAnnonceAchat(String id) async {
    final json = await _api.get<Map<String, dynamic>>(
      ApiEndpoints.annonceAchatById(id),
    );
    return AnnonceAchat.fromJson(json);
  }

  Future<AnnonceAchat> createAnnonceAchat({
    required String produitId,
    required double quantiteKg,
    required double prixMaxKg,
    String? titre,
    String? description,
    String? regionId,
    BuyOfferAudience? audience,
    String? targetCooperativeId,
    DateTime? dateLimiteLivraison,
  }) async {
    final json = await _api.post<Map<String, dynamic>>(
      ApiEndpoints.annoncesAchat,
      body: {
        'produit_id': produitId,
        'quantite_kg': quantiteKg,
        'prix_max_kg': prixMaxKg,
        if (titre != null) 'titre': titre,
        if (description != null) 'description': description,
        if (regionId != null) 'region_id': regionId,
        if (audience != null) 'target_audience': audience.apiValue,
        if (targetCooperativeId != null)
          'target_cooperative_id': targetCooperativeId,
        if (dateLimiteLivraison != null)
          'date_limite_livraison': dateLimiteLivraison.toIso8601String(),
      },
    );
    return AnnonceAchat.fromJson(json);
  }

  Future<AnnonceAchat> updateAnnonceAchat(
    String id, {
    double? quantiteKg,
    double? prixMaxKg,
    String? description,
    ProductStatus? status,
  }) async {
    final json = await _api.put<Map<String, dynamic>>(
      ApiEndpoints.annonceAchatById(id),
      body: {
        if (quantiteKg != null) 'quantite_kg': quantiteKg,
        if (prixMaxKg != null) 'prix_max_kg': prixMaxKg,
        if (description != null) 'description': description,
        if (status != null) 'status': status.apiValue,
      },
    );
    return AnnonceAchat.fromJson(json);
  }

  Future<void> deleteAnnonceAchat(String id) async {
    await _api.delete<dynamic>(ApiEndpoints.annonceAchatById(id));
  }

  // ─── Panier ──────────────────────────────────────────────────────────

  Future<Panier> getPanier() async {
    final json = await _api.get<Map<String, dynamic>>(ApiEndpoints.panier);
    return Panier.fromJson(json);
  }

  Future<Panier> addToPanier({
    required String annonceId,
    required double quantiteKg,
  }) async {
    final json = await _api.post<Map<String, dynamic>>(
      ApiEndpoints.panierAdd,
      body: {'annonce_id': annonceId, 'quantite_kg': quantiteKg},
    );
    return Panier.fromJson(json);
  }

  Future<void> removeFromPanier(String itemId) async {
    await _api.delete<dynamic>(ApiEndpoints.panierItem(itemId));
  }

  // ─── Favoris ─────────────────────────────────────────────────────────

  Future<List<AnnonceVente>> listFavoris() async {
    final raw = await _api.get<dynamic>(ApiEndpoints.favoris);
    return _asList(raw, AnnonceVente.fromJson);
  }

  Future<void> toggleFavori({required String annonceId}) async {
    await _api.post<dynamic>(
      ApiEndpoints.favorisToggle,
      body: {'annonce_id': annonceId},
    );
  }

  // ─── Avis ────────────────────────────────────────────────────────────

  Future<Avis> postAvis({
    required String reviewedUserId,
    required String contextType,
    required String contextId,
    required int note,
    String? commentaire,
  }) async {
    final json = await _api.post<Map<String, dynamic>>(
      ApiEndpoints.avis,
      body: {
        'reviewed_user_id': reviewedUserId,
        'context_type': contextType,
        'context_id': contextId,
        'note': note,
        if (commentaire != null) 'commentaire': commentaire,
      },
    );
    return Avis.fromJson(json);
  }

  Future<void> deleteAvis(String id) async {
    await _api.delete<dynamic>(ApiEndpoints.avisById(id));
  }

  // ─── Médias ──────────────────────────────────────────────────────────

  Future<Media> addMedia({
    String? annonceId,
    required String url,
    String? type,
    int? position,
  }) async {
    final json = await _api.post<Map<String, dynamic>>(
      ApiEndpoints.medias,
      body: {
        if (annonceId != null) 'annonce_id': annonceId,
        'url': url,
        if (type != null) 'type': type,
        if (position != null) 'position': position,
      },
    );
    return Media.fromJson(json);
  }

  Future<void> deleteMedia(String id) async {
    await _api.delete<dynamic>(ApiEndpoints.mediaById(id));
  }

  /// Upload multipart d'une image/vidéo vers MinIO via le backend.
  /// Le backend :
  ///   1. vérifie l'ownership sur (target_type, target_id)
  ///   2. pousse le binaire dans MinIO sous `annonces/<id>/<uuid>.<ext>`
  ///   3. crée la row `medias` et renvoie l'URL publique
  ///
  /// Le client n'a donc PAS à orchestrer 2 appels : un seul POST suffit.
  ///
  /// [progress] est un callback optionnel pour afficher une barre de
  /// téléversement (octets envoyés / total).
  Future<UploadedMedia> uploadAnnonceMedia({
    required File file,
    required String annonceId,
    MediaTargetType targetType = MediaTargetType.annonceVente,
    String type = 'IMAGE',
    void Function(int sent, int total)? progress,
  }) async {
    final fileName = file.path.split(Platform.pathSeparator).last;
    final mime = _guessImageMime(fileName);
    final form = FormData.fromMap({
      'target_type': targetType.apiValue,
      'target_id': annonceId,
      'type': type,
      'file': await MultipartFile.fromFile(
        file.path,
        filename: fileName,
        contentType: mime != null ? MediaType.parse(mime) : null,
      ),
    });

    final json = await _api.upload<Map<String, dynamic>>(
      ApiEndpoints.mediasUpload,
      formData: form,
      onSendProgress: progress,
    );
    return UploadedMedia.fromJson(json);
  }

  /// MIME fallback à partir de l'extension. Les libs natives (image_picker)
  /// fournissent la plupart du temps une extension fiable.
  String? _guessImageMime(String filename) {
    final lower = filename.toLowerCase();
    if (lower.endsWith('.jpg') || lower.endsWith('.jpeg')) return 'image/jpeg';
    if (lower.endsWith('.png')) return 'image/png';
    if (lower.endsWith('.webp')) return 'image/webp';
    if (lower.endsWith('.heic')) return 'image/heic';
    if (lower.endsWith('.mp4')) return 'video/mp4';
    if (lower.endsWith('.mov')) return 'video/quicktime';
    return null;
  }

  // ─── Stocks (entrepôts + lots) ───────────────────────────────────────

  Future<List<Entrepot>> listEntrepots() async {
    final raw = await _api.get<dynamic>(ApiEndpoints.entrepots);
    return _asList(raw, Entrepot.fromJson);
  }

  Future<Entrepot> createEntrepot({
    required String nom,
    required double capaciteKg,
    String? location,
    double? lat,
    double? lng,
    bool isRefrigere = false,
    double? temperatureMin,
    double? temperatureMax,
  }) async {
    final json = await _api.post<Map<String, dynamic>>(
      ApiEndpoints.entrepots,
      body: {
        'nom': nom,
        'capacite_kg': capaciteKg,
        if (location != null) 'location': location,
        if (lat != null) 'lat': lat,
        if (lng != null) 'lng': lng,
        'is_refrigere': isRefrigere,
        if (temperatureMin != null) 'temperature_min': temperatureMin,
        if (temperatureMax != null) 'temperature_max': temperatureMax,
      },
    );
    return Entrepot.fromJson(json);
  }

  Future<Entrepot> updateEntrepot(
    String id, {
    String? nom,
    double? capaciteKg,
    String? location,
  }) async {
    final json = await _api.put<Map<String, dynamic>>(
      ApiEndpoints.entrepotById(id),
      body: {
        if (nom != null) 'nom': nom,
        if (capaciteKg != null) 'capacite_kg': capaciteKg,
        if (location != null) 'location': location,
      },
    );
    return Entrepot.fromJson(json);
  }

  Future<void> deleteEntrepot(String id) async {
    await _api.delete<dynamic>(ApiEndpoints.entrepotById(id));
  }

  Future<List<Lot>> listLots() async {
    final raw = await _api.get<dynamic>(ApiEndpoints.lots);
    return _asList(raw, Lot.fromJson);
  }

  Future<Lot> createLot({
    required String type,
    required String produitId,
    required double quantiteKg,
    String? farmerId,
    String? cooperativeId,
    ProductQuality? qualite,
    DateTime? dateRecolte,
  }) async {
    final json = await _api.post<Map<String, dynamic>>(
      ApiEndpoints.lots,
      body: {
        'type': type,
        'produit_id': produitId,
        'quantite_kg': quantiteKg,
        if (farmerId != null) 'farmer_id': farmerId,
        if (cooperativeId != null) 'cooperative_id': cooperativeId,
        if (qualite != null) 'qualite': qualite.apiValue,
        if (dateRecolte != null)
          'date_recolte': dateRecolte.toIso8601String(),
      },
    );
    return Lot.fromJson(json);
  }

  Future<Lot> updateLot(
    String id, {
    double? quantiteKg,
    ProductQuality? qualite,
  }) async {
    final json = await _api.put<Map<String, dynamic>>(
      ApiEndpoints.lotById(id),
      body: {
        if (quantiteKg != null) 'quantite_kg': quantiteKg,
        if (qualite != null) 'qualite': qualite.apiValue,
      },
    );
    return Lot.fromJson(json);
  }

  Future<void> deleteLot(String id) async {
    await _api.delete<dynamic>(ApiEndpoints.lotById(id));
  }

  // ─── Agronomie ───────────────────────────────────────────────────────

  Future<List<Parcelle>> listParcelles() async {
    final raw = await _api.get<dynamic>(ApiEndpoints.parcelles);
    return _asList(raw, Parcelle.fromJson);
  }

  /// Crée une parcelle. La saisie low-tech demande au minimum :
  ///   • [nom] (texte libre)
  ///   • [superficieHa]
  ///   • [lat]/[lng] (centroid GPS — typiquement la position du téléphone)
  ///
  /// [produitId] est optionnel mais recommandé pour la traçabilité.
  /// [villeId] est accepté en paramètre côté client mais PAS encore envoyé
  /// au backend (le DTO serveur ne le supporte pas pour l'instant).
  // TODO: brancher villeId une fois supporté côté backend.
  Future<Parcelle> createParcelle({
    required String nom,
    required double superficieHa,
    String? produitId,
    double? lat,
    double? lng,
    String? villeId,
  }) async {
    final json = await _api.post<Map<String, dynamic>>(
      ApiEndpoints.parcelles,
      body: {
        'nom': nom,
        'superficie_ha': superficieHa,
        if (produitId != null) 'produit_id': produitId,
        if (lat != null && lng != null)
          'centroid': {'lat': lat, 'lng': lng},
        // TODO: ajouter `'ville_id': villeId` ici une fois le backend prêt.
      },
    );
    return Parcelle.fromJson(json);
  }

  Future<Parcelle> updateParcelle(
    String id, {
    String? nom,
    double? superficieHa,
    String? produitId,
  }) async {
    final json = await _api.put<Map<String, dynamic>>(
      ApiEndpoints.parcelleById(id),
      body: {
        if (nom != null) 'nom': nom,
        if (superficieHa != null) 'superficie_ha': superficieHa,
        if (produitId != null) 'produit_id': produitId,
      },
    );
    return Parcelle.fromJson(json);
  }

  Future<void> deleteParcelle(String id) async {
    await _api.delete<dynamic>(ApiEndpoints.parcelleById(id));
  }

  /// Liste les cultures du farmer. Si [parcelleId] est fourni, on ne
  /// reçoit que les cultures de cette parcelle (utilisé par publier
  /// annonce pour afficher uniquement les cultures du champ choisi).
  Future<List<Culture>> listCultures({String? parcelleId}) async {
    final raw = await _api.get<dynamic>(
      ApiEndpoints.cultures,
      query: parcelleId != null ? {'parcelle_id': parcelleId} : null,
    );
    return _asList(raw, Culture.fromJson);
  }

  /// Crée une culture sur une parcelle. `superficie_ha` est obligatoire
  /// côté back (vérifie que la somme ne dépasse pas la parcelle).
  Future<Culture> addCulture({
    required String parcelleId,
    required String produitId,
    required double superficieHa,
    DateTime? dateSemis,
    DateTime? dateRecoltePrevue,
    double? quantiteEstimeeKg,
  }) async {
    final json = await _api.post<Map<String, dynamic>>(
      ApiEndpoints.cultures,
      body: {
        'parcelle_id': parcelleId,
        'produit_id': produitId,
        'superficie_ha': superficieHa,
        if (dateSemis != null) 'date_semis': dateSemis.toIso8601String(),
        if (dateRecoltePrevue != null)
          'date_recolte_prevue': dateRecoltePrevue.toIso8601String(),
        if (quantiteEstimeeKg != null)
          'quantite_estimee_kg': quantiteEstimeeKg,
      },
    );
    return Culture.fromJson(json);
  }

  Future<void> deleteCulture(String id) async {
    await _api.delete<dynamic>(ApiEndpoints.cultureById(id));
  }

  // ─── Prévisions ──────────────────────────────────────────────────────

  Future<List<Prevision>> listPrevisions() async {
    final raw = await _api.get<dynamic>(ApiEndpoints.previsions);
    return _asList(raw, Prevision.fromJson);
  }

  Future<Prevision> createPrevision({
    required String produitId,
    required double quantitePrevKg,
    DateTime? dateRecoltePrev,
    double? prixCibleKg,
    String? parcelleId,
  }) async {
    final json = await _api.post<Map<String, dynamic>>(
      ApiEndpoints.previsions,
      body: {
        'produit_id': produitId,
        'quantite_prev_kg': quantitePrevKg,
        if (dateRecoltePrev != null)
          'date_recolte_prev': dateRecoltePrev.toIso8601String(),
        if (prixCibleKg != null) 'prix_cible_kg': prixCibleKg,
        if (parcelleId != null) 'parcelle_id': parcelleId,
      },
    );
    return Prevision.fromJson(json);
  }

  Future<Reservation> reserverPrevision({
    required String previsionId,
    required double quantiteKg,
  }) async {
    final json = await _api.post<Map<String, dynamic>>(
      ApiEndpoints.previsionsReserver,
      body: {'prevision_id': previsionId, 'quantite_kg': quantiteKg},
    );
    return Reservation.fromJson(json);
  }

  Future<AnnonceVente> convertPrevision(
    String previsionId, {
    double? prixParKg,
  }) async {
    final json = await _api.post<Map<String, dynamic>>(
      ApiEndpoints.previsionConvert(previsionId),
      body: {
        if (prixParKg != null) 'prix_par_kg': prixParKg,
      },
    );
    return AnnonceVente.fromJson(json);
  }

  // ─── Helpers ─────────────────────────────────────────────────────────

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
