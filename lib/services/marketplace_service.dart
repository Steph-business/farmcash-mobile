import 'dart:io';

import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';

import '../api_client/api_client.dart';
import '../api_client/api_endpoints.dart';
import '../models/models.dart';

/// Cible d'un upload de média : annonce de vente, publication coop, lot
/// ou parcelle agronomique.
enum MediaTargetType { annonceVente, publicationCoop, lot, parcelle }

extension on MediaTargetType {
  String get apiValue {
    switch (this) {
      case MediaTargetType.annonceVente:
        return 'ANNONCE_VENTE';
      case MediaTargetType.publicationCoop:
        return 'PUBLICATION_COOP';
      case MediaTargetType.lot:
        return 'LOT';
      case MediaTargetType.parcelle:
        return 'PARCELLE';
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
    String? farmerId,
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
        if (farmerId != null) 'farmer_id': farmerId,
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
    /// Date à laquelle le produit a été récolté. Aide l'acheteur à
    /// évaluer la fraîcheur. Distincte de `disponibleJusqu` (durée de
    /// validité de l'offre).
    DateTime? dateRecolte,
    /// Traçabilité : traitements appliqués sur le lot.
    ///
    /// Chaque entrée doit fournir SOIT `produit_traitement_id` (UUID
    /// catalogue) SOIT `produit_traitement_nom` (matching insensible
    /// à la casse côté backend). Champs optionnels : `dosage_utilise`,
    /// `date_application` (YYYY-MM-DD), `delai_carence_respecte`,
    /// `notes`.
    List<Map<String, dynamic>>? traitements,
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
        if (dateRecolte != null)
          'date_recolte':
              dateRecolte.toIso8601String().split('T').first,
        if (assignedToCooperativeId != null)
          'assigned_to_cooperative_id': assignedToCooperativeId,
        if (traitements != null && traitements.isNotEmpty)
          'traitements': traitements,
      },
    );
    // Backend nouveau : entité complète avec `id` + `farmer_id`. Backend
    // ancien : `{ message, annonce_id }` qui faisait crasher le parser
    // freezed sur les champs required. On gère les deux pour être robuste
    // pendant la transition + en cas de rollback backend (defense in depth).
    if (json.containsKey('id') && json.containsKey('farmer_id')) {
      return AnnonceVente.fromJson(json);
    }
    final fallbackId =
        (json['annonce_id'] ?? json['id']) as String?;
    if (fallbackId == null) {
      throw StateError(
        'Réponse backend createAnnonceVente inattendue : ni entité ni id.',
      );
    }
    return getAnnonceVente(fallbackId);
  }

  /// Met à jour partiellement une annonce de vente.
  ///
  /// Aligné sur `UpdateAnnonceVenteDto` (annonces.dto.ts) — accepte
  /// uniquement `titre`, `description`, `quantite_kg`, `prix_par_kg`,
  /// `quantite_min_kg`, `qualite`, `status`. Les photos passent par
  /// [uploadAnnonceMedia] (multipart séparé).
  Future<AnnonceVente> updateAnnonceVente(
    String id, {
    String? titre,
    double? quantiteKg,
    double? prixParKg,
    double? quantiteMinKg,
    String? description,
    ProductQuality? qualite,
    ProductStatus? status,
  }) async {
    final json = await _api.put<Map<String, dynamic>>(
      ApiEndpoints.annonceVenteById(id),
      body: {
        if (titre != null) 'titre': titre,
        if (quantiteKg != null) 'quantite_kg': quantiteKg,
        if (prixParKg != null) 'prix_par_kg': prixParKg,
        if (quantiteMinKg != null) 'quantite_min_kg': quantiteMinKg,
        if (description != null) 'description': description,
        if (qualite != null) 'qualite': qualite.apiValue,
        if (status != null) 'status': status.apiValue,
      },
    );
    return AnnonceVente.fromJson(json);
  }

  Future<void> deleteAnnonceVente(String id) async {
    await _api.delete<dynamic>(ApiEndpoints.annonceVenteById(id));
  }

  // ─── Annonces d'achat ────────────────────────────────────────────────

  /// Liste paginée des annonces d'achat (offres publiques).
  ///
  /// Aligné sur `ListerAnnoncesAchatQueryDto` (annonces.dto.ts) — accepte
  /// uniquement `page`, `limit`, `produit_id`, `region_id`, `qualite`.
  /// Le DTO refuse `prix_max` (whitelist stricte côté backend).
  Future<Paginated<AnnonceAchat>> listAnnoncesAchat({
    String? produitId,
    String? regionId,
    ProductQuality? qualite,
    int page = 1,
    int limit = 20,
  }) async {
    final raw = await _api.get<dynamic>(
      ApiEndpoints.annoncesAchat,
      query: {
        if (produitId != null) 'produit_id': produitId,
        if (regionId != null) 'region_id': regionId,
        if (qualite != null) 'qualite': qualite.apiValue,
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

  /// Crée une annonce d'achat (BUYER).
  ///
  /// Aligné sur `CreateAnnonceAchatDto` (annonces.dto.ts). Le DTO exige
  /// `produit_id`, `quantite_kg`, `region_id` ; les autres champs sont
  /// optionnels. Le DTO refuse `titre`, `description`,
  /// `date_limite_livraison` — ces champs n'existent pas dans la table
  /// `annonces_achat`.
  Future<AnnonceAchat> createAnnonceAchat({
    required String produitId,
    required double quantiteKg,
    required String regionId,
    double? prixMaxKg,
    ProductQuality? qualite,
    int? rayonKm,
    BuyOfferAudience? audience,
    String? targetCooperativeId,
  }) async {
    final json = await _api.post<Map<String, dynamic>>(
      ApiEndpoints.annoncesAchat,
      body: {
        'produit_id': produitId,
        'quantite_kg': quantiteKg,
        'region_id': regionId,
        if (prixMaxKg != null) 'prix_max_kg': prixMaxKg,
        if (qualite != null) 'qualite': qualite.apiValue,
        if (rayonKm != null) 'rayon_km': rayonKm,
        if (audience != null) 'target_audience': audience.apiValue,
        if (targetCooperativeId != null)
          'target_cooperative_id': targetCooperativeId,
      },
    );
    return AnnonceAchat.fromJson(json);
  }

  /// Met à jour une annonce d'achat.
  ///
  /// Aligné sur `UpdateAnnonceAchatDto` — accepte uniquement
  /// `quantite_kg`, `prix_max_kg`, `is_active`. Les champs `description`
  /// et `status` ne sont pas whitelistés côté backend.
  Future<AnnonceAchat> updateAnnonceAchat(
    String id, {
    double? quantiteKg,
    double? prixMaxKg,
    bool? isActive,
  }) async {
    final json = await _api.put<Map<String, dynamic>>(
      ApiEndpoints.annonceAchatById(id),
      body: {
        if (quantiteKg != null) 'quantite_kg': quantiteKg,
        if (prixMaxKg != null) 'prix_max_kg': prixMaxKg,
        if (isActive != null) 'is_active': isActive,
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

  /// Poste un avis sur une annonce (vendeur ou produit).
  ///
  /// Aligné sur `AddAvisDto` (interactions.dto.ts) — attend
  /// `{annonce_id, rating, commentaire?}`. La note doit être un entier
  /// 1..5. L'identité du reviewer est déduite du JWT côté backend.
  Future<Avis> postAvis({
    required String annonceId,
    required int rating,
    String? commentaire,
  }) async {
    final json = await _api.post<Map<String, dynamic>>(
      ApiEndpoints.avis,
      body: {
        'annonce_id': annonceId,
        'rating': rating,
        if (commentaire != null) 'commentaire': commentaire,
      },
    );
    return Avis.fromJson(json);
  }

  Future<void> deleteAvis(String id) async {
    await _api.delete<dynamic>(ApiEndpoints.avisById(id));
  }

  // ─── Médias ──────────────────────────────────────────────────────────

  /// Attache un média existant (URL déjà uploadée) à une cible
  /// (annonce / publication / lot / parcelle).
  ///
  /// Aligné sur `AddMediaDto` (interactions.dto.ts) — attend
  /// `{target_type, target_id, url, type, thumbnail_url?}`. Le DTO
  /// rejette `annonce_id` et `position`. Pour uploader un nouveau
  /// fichier, préférer [uploadAnnonceMedia] qui crée la ligne `medias`
  /// directement côté serveur.
  Future<Media> addMedia({
    required MediaTargetType targetType,
    required String targetId,
    required String url,
    required String type,
    String? thumbnailUrl,
  }) async {
    final json = await _api.post<Map<String, dynamic>>(
      ApiEndpoints.medias,
      body: {
        'target_type': targetType.apiValue,
        'target_id': targetId,
        'url': url,
        'type': type,
        if (thumbnailUrl != null) 'thumbnail_url': thumbnailUrl,
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

  /// Crée un entrepôt physique.
  ///
  /// Aligné sur `CreateEntrepotDto` (stock.dto.ts) — exige `nom`,
  /// `region_id`, `ville_id` ; `capacite_kg`, `adresse`, `is_refrigere`
  /// sont optionnels. Les champs `location`, `lat`, `lng`,
  /// `temperature_min`, `temperature_max` ne sont pas whitelistés.
  Future<Entrepot> createEntrepot({
    required String nom,
    required String regionId,
    required String villeId,
    double? capaciteKg,
    String? adresse,
    bool isRefrigere = false,
  }) async {
    final json = await _api.post<Map<String, dynamic>>(
      ApiEndpoints.entrepots,
      body: {
        'nom': nom,
        'region_id': regionId,
        'ville_id': villeId,
        if (capaciteKg != null) 'capacite_kg': capaciteKg,
        if (adresse != null) 'adresse': adresse,
        'is_refrigere': isRefrigere,
      },
    );
    return Entrepot.fromJson(json);
  }

  /// Met à jour un entrepôt. Aligné sur `UpdateEntrepotDto`.
  Future<Entrepot> updateEntrepot(
    String id, {
    String? nom,
    double? capaciteKg,
    bool? isRefrigere,
    bool? isActive,
  }) async {
    final json = await _api.put<Map<String, dynamic>>(
      ApiEndpoints.entrepotById(id),
      body: {
        if (nom != null) 'nom': nom,
        if (capaciteKg != null) 'capacite_kg': capaciteKg,
        if (isRefrigere != null) 'is_refrigere': isRefrigere,
        if (isActive != null) 'is_active': isActive,
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

  /// Lots présents physiquement dans un entrepôt (via la table `stock`).
  /// Le backend retourne un tableau d'objets `{ stock_id, quantite_kg,
  /// date_entree, date_sortie_prev, notes, lot: {...} }`.
  ///
  /// On extrait le `lot` imbriqué pour rester compatible avec l'UI qui
  /// attend une `List<Lot>`. La quantité dans CET entrepôt est portée par
  /// la ligne stock — si besoin, faire un override côté presenter.
  Future<List<Lot>> listLotsByEntrepot(String entrepotId) async {
    final raw = await _api.get<dynamic>(ApiEndpoints.entrepotLots(entrepotId));
    if (raw is! List) return const <Lot>[];
    return raw
        .whereType<Map>()
        .map((m) {
          final lotRaw = m['lot'];
          if (lotRaw is Map) {
            return Lot.fromJson(lotRaw.cast<String, dynamic>());
          }
          return null;
        })
        .whereType<Lot>()
        .toList();
  }

  /// Crée un lot dans le stock (FARMER → INDIVIDUAL, COOP → COOPERATIVE).
  ///
  /// Aligné sur `CreateLotDto` (stock.dto.ts) — exige `lot_code` (3..30
  /// chars), `type`, `quantite_kg` ; `produit_id`, `qualite`,
  /// `date_recolte` optionnels. `farmer_id`/`cooperative_id` sont
  /// déduits du JWT côté backend (à ne PAS envoyer).
  Future<Lot> createLot({
    required String lotCode,
    required String type,
    required double quantiteKg,
    String? produitId,
    ProductQuality? qualite,
    DateTime? dateRecolte,
  }) async {
    final json = await _api.post<Map<String, dynamic>>(
      ApiEndpoints.lots,
      body: {
        'lot_code': lotCode,
        'type': type,
        'quantite_kg': quantiteKg,
        if (produitId != null) 'produit_id': produitId,
        if (qualite != null) 'qualite': qualite.apiValue,
        if (dateRecolte != null)
          'date_recolte': dateRecolte.toIso8601String().split('T').first,
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
  ///
  /// Le backend renvoie désormais l'entité `parcelle` complète. Les
  /// versions antérieures renvoyaient `{message, id}` — on conserve un
  /// fallback qui refait un GET de la parcelle créée pour rester
  /// compatible avec un serveur pas encore déployé (defense in depth).
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
    // Backend nouveau : l'entité complète a au moins `nom` ou `user_id`.
    // Backend ancien : shape `{message, id}` → on retombe sur un GET de
    // la liste pour récupérer l'entité réelle (l'`id` retourné identifie
    // sans ambiguïté la parcelle qu'on vient de créer).
    if (json.containsKey('nom') || json.containsKey('user_id')) {
      return Parcelle.fromJson(json);
    }
    final fallbackId = json['id'] as String?;
    if (fallbackId == null) {
      throw StateError(
        'Réponse backend createParcelle inattendue : ni entité ni id.',
      );
    }
    final all = await listParcelles();
    final found =
        all.where((p) => p.id == fallbackId).cast<Parcelle?>().firstOrNull;
    if (found == null) {
      throw StateError(
        'Parcelle id=$fallbackId créée mais introuvable au GET.',
      );
    }
    return found;
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

  /// Crée une culture sur une parcelle.
  ///
  /// Aligné sur `AddCultureDto` (agronomie.dto.ts) — exige
  /// `parcelle_id`, `produit_id`, `superficie_ha`. `date_plantation`
  /// (YYYY-MM-DD) est optionnelle. Le DTO refuse `date_semis`,
  /// `date_recolte_prevue`, `quantite_estimee_kg`.
  Future<Culture> addCulture({
    required String parcelleId,
    required String produitId,
    required double superficieHa,
    DateTime? datePlantation,
  }) async {
    final json = await _api.post<Map<String, dynamic>>(
      ApiEndpoints.cultures,
      body: {
        'parcelle_id': parcelleId,
        'produit_id': produitId,
        'superficie_ha': superficieHa,
        if (datePlantation != null)
          'date_plantation':
              datePlantation.toIso8601String().split('T').first,
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

  /// Crée une prévision de récolte côté FARMER.
  ///
  /// La `dateRecoltePrev` est sérialisée en **YYYY-MM-DD** (et non en ISO
  /// avec heure) car le backend valide `target.getTime() > Date.now()` —
  /// envoyer "2026-06-15T00:00:00.000Z" risquait de tomber dans le passé
  /// si on est le 15 juin l'après-midi. En format date pure, Postgres
  /// stocke la journée entière → toujours future tant que le jour change.
  ///
  /// Retour : entité complète (depuis le fix backend récent). On garde
  /// un fallback `listPrevisions().firstWhere(id)` si le serveur n'est
  /// pas encore redéployé avec le nouveau shape.
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
          'date_recolte_prev':
              dateRecoltePrev.toIso8601String().split('T').first,
        if (prixCibleKg != null) 'prix_cible_kg': prixCibleKg,
        if (parcelleId != null) 'parcelle_id': parcelleId,
      },
    );
    // Backend nouveau : entité complète (au moins `farmer_id`).
    // Backend ancien : `{ message, id }` → fallback via GET liste.
    if (json.containsKey('farmer_id') || json.containsKey('quantite_prev_kg')) {
      return Prevision.fromJson(json);
    }
    final fallbackId = json['id'] as String?;
    if (fallbackId == null) {
      throw StateError(
        'Réponse backend createPrevision inattendue : ni entité ni id.',
      );
    }
    final all = await listPrevisions();
    final found =
        all.where((p) => p.id == fallbackId).cast<Prevision?>().firstOrNull;
    if (found == null) {
      throw StateError(
        'Prévision id=$fallbackId créée mais introuvable au GET.',
      );
    }
    return found;
  }

  /// Modifie une prévision existante (champs partiels). Le backend
  /// refuse si l'utilisateur n'est pas le propriétaire OU si la coop a
  /// déjà VALIDATED/INCLUDED la prévision (lock workflow coop).
  Future<Prevision> updatePrevision(
    String id, {
    double? quantitePrevKg,
    DateTime? dateRecoltePrev,
    double? prixCibleKg,
    String? saison,
    String? notes,
  }) async {
    final json = await _api.put<Map<String, dynamic>>(
      ApiEndpoints.previsionById(id),
      body: {
        if (quantitePrevKg != null) 'quantite_prev_kg': quantitePrevKg,
        if (dateRecoltePrev != null)
          'date_recolte_prev':
              dateRecoltePrev.toIso8601String().split('T').first,
        if (prixCibleKg != null) 'prix_cible_kg': prixCibleKg,
        if (saison != null) 'saison': saison,
        if (notes != null) 'notes': notes,
      },
    );
    return Prevision.fromJson(json);
  }

  /// Supprime une prévision. Le backend rembourse AUTOMATIQUEMENT tous
  /// les acheteurs ayant déjà réservé un acompte (crédite leur wallet
  /// + notif `WALLET_CREDITED`). Retourne le résumé :
  ///   • `refundedCount` : nombre d'acheteurs remboursés
  ///   • `totalRefunded` : somme totale remboursée en F
  /// Refus uniquement si :
  ///   • pas propriétaire
  ///   • coop a VALIDATED/INCLUDED
  Future<({int refundedCount, double totalRefunded, String message})>
      deletePrevision(String id) async {
    final json = await _api.delete<Map<String, dynamic>>(
      ApiEndpoints.previsionById(id),
    );
    final refundedCount = (json['refunded_count'] as num?)?.toInt() ?? 0;
    final totalRefunded =
        (json['total_refunded'] as num?)?.toDouble() ?? 0;
    final message =
        json['message'] as String? ?? 'Prévision supprimée.';
    return (
      refundedCount: refundedCount,
      totalRefunded: totalRefunded,
      message: message,
    );
  }

  /// Réserve une part d'une prévision de récolte (paie un acompte).
  ///
  /// Aligné sur `CreateReservationDto` (previsions.dto.ts) — exige
  /// `prevision_id`, `quantite_kg`, `payment_method_id` (UUID du moyen
  /// de paiement) ; `prix_reserve_kg` optionnel.
  Future<Reservation> reserverPrevision({
    required String previsionId,
    required double quantiteKg,
    required String paymentMethodId,
    double? prixReserveKg,
  }) async {
    final json = await _api.post<Map<String, dynamic>>(
      ApiEndpoints.previsionsReserver,
      body: {
        'prevision_id': previsionId,
        'quantite_kg': quantiteKg,
        'payment_method_id': paymentMethodId,
        if (prixReserveKg != null) 'prix_reserve_kg': prixReserveKg,
      },
    );
    return Reservation.fromJson(json);
  }

  /// Liste les réservations de prévisions du BUYER connecté.
  ///
  /// Endpoint `GET /marketplace/reservations/my`.
  Future<List<Reservation>> listMyReservations() async {
    final raw = await _api.get<dynamic>(ApiEndpoints.reservationsMy);
    return _asList(raw, Reservation.fromJson);
  }

  /// Convertit une prévision en annonce de vente officielle.
  ///
  /// Aligné sur `ConvertPrevisionDto` (previsions.dto.ts) — exige
  /// `titre`, `prix_par_kg`, `quantite_min_kg`, `qualite`, `region_id`,
  /// `ville_id`, `coordinates {lat, lng}`. `description` optionnel.
  Future<AnnonceVente> convertPrevision(
    String previsionId, {
    required String titre,
    required double prixParKg,
    required double quantiteMinKg,
    required ProductQuality qualite,
    required String regionId,
    required String villeId,
    required double lat,
    required double lng,
    String? description,
  }) async {
    final json = await _api.post<Map<String, dynamic>>(
      ApiEndpoints.previsionConvert(previsionId),
      body: {
        'titre': titre,
        'prix_par_kg': prixParKg,
        'quantite_min_kg': quantiteMinKg,
        'qualite': qualite.apiValue,
        'region_id': regionId,
        'ville_id': villeId,
        'coordinates': {'lat': lat, 'lng': lng},
        if (description != null) 'description': description,
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
