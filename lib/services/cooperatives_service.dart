import '../api_client/api_client.dart';
import '../api_client/api_endpoints.dart';
import '../models/models.dart';

/// Coopératives — annuaire public + management (rôle COOP) + vue producteur.
class CooperativesService {
  final ApiClient _api;
  CooperativesService(this._api);

  // ─── Annuaire public ─────────────────────────────────────────────────

  Future<List<Cooperative>> listPublic({
    String? search,
    String? regionId,
  }) async {
    final raw = await _api.get<dynamic>(
      ApiEndpoints.cooperatives,
      query: {
        if (search != null && search.isNotEmpty) 'q': search,
        if (regionId != null) 'region_id': regionId,
      },
    );
    return _asList(raw, Cooperative.fromJson);
  }

  Future<Cooperative> getPublic(String id) async {
    final json = await _api.get<Map<String, dynamic>>(
      ApiEndpoints.cooperativeById(id),
    );
    return Cooperative.fromJson(json);
  }

  Future<Paginated<PublicationCoop>> listPublications({
    String? cooperativeId,
    String? produitId,
    int page = 1,
    int limit = 20,
  }) async {
    final raw = await _api.get<dynamic>(
      ApiEndpoints.publicationsCoopList,
      query: {
        if (cooperativeId != null) 'cooperative_id': cooperativeId,
        if (produitId != null) 'produit_id': produitId,
        'page': page,
        'limit': limit,
      },
    );
    return Paginated.fromJsonOrList(raw, PublicationCoop.fromJson);
  }

  Future<PublicationCoop> getPublication(String id) async {
    final json = await _api.get<Map<String, dynamic>>(
      ApiEndpoints.publicationCoopById(id),
    );
    return PublicationCoop.fromJson(json);
  }

  // ─── Profil COOP ─────────────────────────────────────────────────────

  Future<Cooperative> updateProfile({
    String? nom,
    String? numeroAgrement,
    String? regionId,
    String? villeId,
    String? description,
    String? logoUrl,
    double? commissionRate,
    bool? autoDistribute,
  }) async {
    final json = await _api.put<Map<String, dynamic>>(
      ApiEndpoints.coopProfile,
      body: {
        if (nom != null) 'nom': nom,
        if (numeroAgrement != null) 'numero_agrement': numeroAgrement,
        if (regionId != null) 'region_id': regionId,
        if (villeId != null) 'ville_id': villeId,
        if (description != null) 'description': description,
        if (logoUrl != null) 'logo_url': logoUrl,
        if (commissionRate != null) 'commission_rate': commissionRate,
        if (autoDistribute != null) 'auto_distribute': autoDistribute,
      },
    );
    return Cooperative.fromJson(json);
  }

  // ─── Adhésion — FARMER initie ────────────────────────────────────────

  Future<CoopJoinRequest> requestToJoin({
    required String cooperativeId,
    String? message,
  }) async {
    final json = await _api.post<Map<String, dynamic>>(
      ApiEndpoints.coopJoinRequests,
      body: {
        'cooperative_id': cooperativeId,
        if (message != null) 'message': message,
      },
    );
    return CoopJoinRequest.fromJson(json);
  }

  Future<List<CoopJoinRequest>> listJoinRequests() async {
    final raw = await _api.get<dynamic>(ApiEndpoints.coopJoinRequests);
    return _asList(raw, CoopJoinRequest.fromJson);
  }

  Future<CoopJoinRequest> handleJoinRequest({
    required String id,
    required bool accept,
    String? motif,
  }) async {
    final json = await _api.put<Map<String, dynamic>>(
      ApiEndpoints.coopJoinRequestHandle(id),
      body: {
        'action': accept ? 'ACCEPT' : 'REJECT',
        if (motif != null) 'motif': motif,
      },
    );
    return CoopJoinRequest.fromJson(json);
  }

  // ─── Adhésion — COOP initie (invitations) ────────────────────────────

  Future<CoopInvitation> invite({
    required String phone,
    String? message,
  }) async {
    final json = await _api.post<Map<String, dynamic>>(
      ApiEndpoints.coopInvitations,
      body: {
        'phone': phone,
        if (message != null) 'message': message,
      },
    );
    return CoopInvitation.fromJson(json);
  }

  Future<List<CoopInvitation>> listMyInvitations() async {
    final raw = await _api.get<dynamic>(ApiEndpoints.coopInvitationsMy);
    return _asList(raw, CoopInvitation.fromJson);
  }

  Future<CoopInvitation> handleInvitation({
    required String id,
    required bool accept,
  }) async {
    final json = await _api.put<Map<String, dynamic>>(
      ApiEndpoints.coopInvitationHandle(id),
      body: {'action': accept ? 'ACCEPT' : 'REJECT'},
    );
    return CoopInvitation.fromJson(json);
  }

  // ─── Membres ─────────────────────────────────────────────────────────

  Future<Paginated<MembreCoop>> listMembers({
    int page = 1,
    int limit = 20,
    String? search,
  }) async {
    final raw = await _api.get<dynamic>(
      ApiEndpoints.coopMembers,
      query: {
        'page': page,
        'limit': limit,
        if (search != null && search.isNotEmpty) 'q': search,
      },
    );
    return Paginated.fromJsonOrList(raw, MembreCoop.fromJson);
  }

  Future<void> removeMember(String memberUserId) async {
    await _api.delete<dynamic>(ApiEndpoints.coopMemberById(memberUserId));
  }

  Future<MembreCoop> updateMemberRole({
    required String memberUserId,
    required CoopMemberRole role,
  }) async {
    final json = await _api.put<Map<String, dynamic>>(
      ApiEndpoints.coopMemberRole(memberUserId),
      body: {'role': role.apiValue},
    );
    return MembreCoop.fromJson(json);
  }

  // ─── Validation annonces ─────────────────────────────────────────────

  Future<List<AnnonceVente>> listAssignedAnnoncesVente({
    CoopAnnonceStatus? coopStatus,
  }) async {
    final raw = await _api.get<dynamic>(
      ApiEndpoints.coopAnnoncesVenteAssigned,
      query: {
        if (coopStatus != null) 'coop_status': coopStatus.apiValue,
      },
    );
    return _asList(raw, AnnonceVente.fromJson);
  }

  Future<AnnonceVente> validateAnnonceVente({
    required String id,
    double? quantiteValideeKg,
    double? prixValideKg,
    ProductQuality? qualiteValidee,
    String? notes,
  }) async {
    final json = await _api.put<Map<String, dynamic>>(
      ApiEndpoints.coopAnnonceVenteValidate(id),
      body: {
        if (quantiteValideeKg != null)
          'quantite_validee_kg': quantiteValideeKg,
        if (prixValideKg != null) 'prix_valide_kg': prixValideKg,
        if (qualiteValidee != null) 'qualite_validee': qualiteValidee.apiValue,
        if (notes != null) 'notes': notes,
      },
    );
    return AnnonceVente.fromJson(json);
  }

  Future<AnnonceVente> rejectAnnonceVente({
    required String id,
    required String motif,
  }) async {
    final json = await _api.put<Map<String, dynamic>>(
      ApiEndpoints.coopAnnonceVenteReject(id),
      body: {'motif': motif},
    );
    return AnnonceVente.fromJson(json);
  }

  Future<List<AnnonceAchat>> listIncomingAnnoncesAchat() async {
    final raw = await _api.get<dynamic>(ApiEndpoints.coopAnnoncesAchatIncoming);
    return _asList(raw, AnnonceAchat.fromJson);
  }

  // ─── Validation prévisions ───────────────────────────────────────────

  Future<List<Prevision>> listAssignedPrevisions({
    CoopAnnonceStatus? coopStatus,
  }) async {
    final raw = await _api.get<dynamic>(
      ApiEndpoints.coopPrevisionsAssigned,
      query: {
        if (coopStatus != null) 'coop_status': coopStatus.apiValue,
      },
    );
    return _asList(raw, Prevision.fromJson);
  }

  Future<Prevision> validatePrevision({
    required String id,
    String? notes,
  }) async {
    final json = await _api.put<Map<String, dynamic>>(
      ApiEndpoints.coopPrevisionValidate(id),
      body: {if (notes != null) 'notes': notes},
    );
    return Prevision.fromJson(json);
  }

  Future<Prevision> rejectPrevision({
    required String id,
    required String motif,
  }) async {
    final json = await _api.put<Map<String, dynamic>>(
      ApiEndpoints.coopPrevisionReject(id),
      body: {'motif': motif},
    );
    return Prevision.fromJson(json);
  }

  // ─── Agrégation publications ─────────────────────────────────────────

  Future<PublicationCoop> aggregatePublication({
    required List<String> annonceVenteIds,
    required String titre,
    String? description,
    List<String>? photos,
    double? prixParKg,
  }) async {
    final json = await _api.post<Map<String, dynamic>>(
      ApiEndpoints.coopPublicationsAggregate,
      body: {
        'annonce_vente_ids': annonceVenteIds,
        'titre': titre,
        if (description != null) 'description': description,
        if (photos != null) 'photos': photos,
        if (prixParKg != null) 'prix_par_kg': prixParKg,
      },
    );
    return PublicationCoop.fromJson(json);
  }

  Future<List<CoopContribution>> getPublicationContributions(
      String publicationId) async {
    final raw = await _api.get<dynamic>(
      ApiEndpoints.coopPublicationContributions(publicationId),
    );
    return _asList(raw, CoopContribution.fromJson);
  }

  Future<Map<String, dynamic>> distributePublication({
    required String publicationId,
    bool dryRun = false,
  }) async {
    return _api.post<Map<String, dynamic>>(
      ApiEndpoints.coopPublicationDistribute(publicationId),
      query: {if (dryRun) 'dry_run': true},
    );
  }

  // ─── Vue producteur (mes annonces gérées par coop) ───────────────────

  Future<List<AnnonceVente>> listMyAnnoncesInCoop() async {
    final raw = await _api.get<dynamic>(ApiEndpoints.coopMyAnnonces);
    return _asList(raw, AnnonceVente.fromJson);
  }

  Future<Map<String, dynamic>> getMyAnnonceContext(String id) async {
    return _api.get<Map<String, dynamic>>(
      ApiEndpoints.coopMyAnnonceContext(id),
    );
  }

  // ─── Avances ─────────────────────────────────────────────────────────

  Future<AvanceCoop> payAdvance({
    required String farmerId,
    required double amount,
    String? annonceVenteId,
    String? motif,
  }) async {
    final json = await _api.post<Map<String, dynamic>>(
      ApiEndpoints.coopAdvances,
      body: {
        'farmer_id': farmerId,
        'amount': amount,
        if (annonceVenteId != null) 'annonce_vente_id': annonceVenteId,
        if (motif != null) 'motif': motif,
      },
    );
    return AvanceCoop.fromJson(json);
  }

  Future<List<AvanceCoop>> listAdvances({CoopAdvanceStatus? status}) async {
    final raw = await _api.get<dynamic>(
      ApiEndpoints.coopAdvances,
      query: {
        if (status != null) 'status': status.apiValue,
      },
    );
    return _asList(raw, AvanceCoop.fromJson);
  }

  Future<List<AvanceCoop>> listAdvancesByAnnonce(String annonceId) async {
    final raw = await _api.get<dynamic>(
      ApiEndpoints.coopAdvancesByAnnonce(annonceId),
    );
    return _asList(raw, AvanceCoop.fromJson);
  }

  // ─── Publications COOP (CRUD direct) ─────────────────────────────────

  Future<PublicationCoop> createPublication({
    required String produitId,
    required String titre,
    required double quantiteKg,
    required double prixParKg,
    String? description,
    List<String>? photos,
    ProductQuality? qualite,
  }) async {
    final json = await _api.post<Map<String, dynamic>>(
      ApiEndpoints.coopPublications,
      body: {
        'produit_id': produitId,
        'titre': titre,
        'quantite_kg': quantiteKg,
        'prix_par_kg': prixParKg,
        if (description != null) 'description': description,
        if (photos != null) 'photos': photos,
        if (qualite != null) 'qualite': qualite.apiValue,
      },
    );
    return PublicationCoop.fromJson(json);
  }

  Future<PublicationCoop> updatePublication(
    String id, {
    String? titre,
    double? quantiteKg,
    double? prixParKg,
    String? description,
    ProductStatus? status,
  }) async {
    final json = await _api.put<Map<String, dynamic>>(
      ApiEndpoints.coopPublicationById(id),
      body: {
        if (titre != null) 'titre': titre,
        if (quantiteKg != null) 'quantite_kg': quantiteKg,
        if (prixParKg != null) 'prix_par_kg': prixParKg,
        if (description != null) 'description': description,
        if (status != null) 'status': status.apiValue,
      },
    );
    return PublicationCoop.fromJson(json);
  }

  Future<void> deletePublication(String id) async {
    await _api.delete<dynamic>(ApiEndpoints.coopPublicationById(id));
  }

  // ─── Sollicitations multi-audience (chantier 2) ──────────────────────

  /// COOP crée une sollicitation et fan-out aux audiences cochées.
  /// [audiences] ⊆ {MEMBRES, COOPS_VOISINES, INDEPENDANTS} (≥ 1 requis).
  /// [rayonKm] s'applique aux audiences géo (par défaut 50 côté back).
  /// [dureeJours] défaut backend = 7.
  ///
  /// Réponse : `{ sollicitation_id, recipients_count, notifications_dispatched }`.
  Future<Map<String, dynamic>> createSollicitation({
    required String annonceAchatId,
    required String message,
    required List<String> audiences,
    int? rayonKm,
    int? dureeJours,
  }) async {
    return _api.post<Map<String, dynamic>>(
      ApiEndpoints.sollicitations,
      body: {
        'annonce_achat_id': annonceAchatId,
        'message': message,
        'audiences': audiences,
        if (rayonKm != null) 'rayon_km': rayonKm,
        if (dureeJours != null) 'duree_jours': dureeJours,
      },
    );
  }

  /// Liste paginée des sollicitations émises par la coop courante.
  Future<Paginated<Sollicitation>> listSollicitations({
    String? status,
    int page = 1,
    int limit = 20,
  }) async {
    final raw = await _api.get<dynamic>(
      ApiEndpoints.sollicitations,
      query: {
        if (status != null) 'status': status,
        'page': page,
        'limit': limit,
      },
    );
    return Paginated.fromJsonOrList(raw, Sollicitation.fromJson);
  }

  /// Détail d'une sollicitation (coop initiatrice OU destinataire).
  /// Le payload est plus riche que le modèle `Sollicitation` plat
  /// (inclut `annonce`, `cooperative`, `recipients`, `responses_summary`)
  /// — on renvoie la Map brute pour laisser les écrans piocher.
  Future<Map<String, dynamic>> getSollicitation(String id) async {
    return _api.get<Map<String, dynamic>>(
      ApiEndpoints.sollicitationById(id),
    );
  }

  /// FARMER/COOP destinataire répond à une sollicitation.
  /// [quantiteKg] est OBLIGATOIRE côté back si [accept] = true.
  ///
  /// Réponse : `{ recipient_id, response_action, response_quantite_kg,
  /// sollicitation_status }`.
  Future<Map<String, dynamic>> respondSollicitation({
    required String id,
    required bool accept,
    double? quantiteKg,
  }) async {
    return _api.post<Map<String, dynamic>>(
      ApiEndpoints.sollicitationRespond(id),
      body: {
        'action': accept ? 'ACCEPTED' : 'REJECTED',
        if (accept && quantiteKg != null) 'quantite_kg': quantiteKg,
      },
    );
  }

  /// COOP initiatrice clôture manuellement (avant auto-FULFILLED).
  /// Réponse : `{ status: 'CLOSED' }`.
  Future<Map<String, dynamic>> closeSollicitation(String id) async {
    return _api.post<Map<String, dynamic>>(
      ApiEndpoints.sollicitationClose(id),
    );
  }

  /// COOP initiatrice confirme la réponse d'un destinataire (le destinataire
  /// a accepté la sollicitation, la coop scelle l'engagement).
  ///
  /// Effets : `sollicitation_recipients.response_action = 'CONFIRMED_BY_COOP'`
  /// + `confirmed_by_coop_at = now()`, notification envoyée au destinataire.
  Future<Map<String, dynamic>> confirmRecipientResponse({
    required String sollicitationId,
    required String recipientId,
  }) async {
    return _api.put<Map<String, dynamic>>(
      ApiEndpoints.sollicitationRecipientConfirm(sollicitationId, recipientId),
    );
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
