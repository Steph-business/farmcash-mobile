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

  /// Met à jour le profil de la coopérative.
  ///
  /// Aligné sur `UpsertCoopProfileDto` (cooperatives.dto.ts) — accepte
  /// `nom`, `numero_agrement`, `region_id`, `ville_id`, `nb_membres`,
  /// `commission_rate`, `auto_distribute`. Les champs `logo_url` et
  /// `description` ne sont pas whitelistés.
  Future<Cooperative> updateProfile({
    String? nom,
    String? numeroAgrement,
    String? regionId,
    String? villeId,
    int? nbMembres,
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
        if (nbMembres != null) 'nb_membres': nbMembres,
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

  /// Accepte ou rejette une demande d'adhésion FARMER → COOP.
  ///
  /// Aligné sur `HandleJoinRequestDto` — attend
  /// `{decision: 'ACCEPTED'|'REJECTED', rejection_reason?}`.
  Future<CoopJoinRequest> handleJoinRequest({
    required String id,
    required bool accept,
    String? rejectionReason,
  }) async {
    final json = await _api.put<Map<String, dynamic>>(
      ApiEndpoints.coopJoinRequestHandle(id),
      body: {
        'decision': accept ? 'ACCEPTED' : 'REJECTED',
        if (rejectionReason != null) 'rejection_reason': rejectionReason,
      },
    );
    return CoopJoinRequest.fromJson(json);
  }

  // ─── Adhésion — COOP initie (invitations) ────────────────────────────

  /// Invite un FARMER par téléphone à rejoindre la coopérative.
  ///
  /// Aligné sur `CreateInvitationDto` — attend `invited_phone`, pas
  /// `phone`.
  Future<CoopInvitation> invite({
    required String invitedPhone,
    String? message,
  }) async {
    final json = await _api.post<Map<String, dynamic>>(
      ApiEndpoints.coopInvitations,
      body: {
        'invited_phone': invitedPhone,
        if (message != null) 'message': message,
      },
    );
    return CoopInvitation.fromJson(json);
  }

  Future<List<CoopInvitation>> listMyInvitations() async {
    final raw = await _api.get<dynamic>(ApiEndpoints.coopInvitationsMy);
    return _asList(raw, CoopInvitation.fromJson);
  }

  /// Accepte ou rejette une invitation côté FARMER.
  ///
  /// Aligné sur `HandleInvitationDto` — attend `decision: 'ACCEPTED' |
  /// 'REJECTED'`.
  Future<CoopInvitation> handleInvitation({
    required String id,
    required bool accept,
  }) async {
    final json = await _api.put<Map<String, dynamic>>(
      ApiEndpoints.coopInvitationHandle(id),
      body: {'decision': accept ? 'ACCEPTED' : 'REJECTED'},
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

  /// Enregistre un farmer **géré** par la coopérative (sans téléphone).
  ///
  /// Cas d'usage : la coop saisit en présentiel les producteurs sans
  /// smartphone. Aucun OTP envoyé. La coop publiera ensuite les annonces
  /// au nom du farmer via `act_as_farmer_id`.
  ///
  /// Aligné sur le DTO backend `POST /coop/members/managed` :
  /// `{ full_name, village?, default_product_id?, photo_url? }`.
  Future<MembreCoop> createManagedMember({
    required String fullName,
    String? village,
    String? defaultProductId,
    String? photoUrl,
  }) async {
    final json = await _api.post<Map<String, dynamic>>(
      ApiEndpoints.coopMembersManaged,
      body: {
        'full_name': fullName,
        if (village != null && village.isNotEmpty) 'village': village,
        if (defaultProductId != null) 'default_product_id': defaultProductId,
        if (photoUrl != null && photoUrl.isNotEmpty) 'photo_url': photoUrl,
      },
    );
    return MembreCoop.fromJson(json);
  }

  /// Promeut un farmer géré en farmer autonome dès qu'il obtient un
  /// téléphone. Le backend déclenche un OTP de vérification et bascule
  /// `managed_by_coop_id` → `null`.
  ///
  /// Aligné sur `POST /coop/members/:id/promote` — attend `{ phone }`
  /// au format E.164 (`+225XXXXXXXXXX`).
  Future<MembreCoop> promoteManagedMember({
    required String memberUserId,
    required String phone,
  }) async {
    final json = await _api.post<Map<String, dynamic>>(
      ApiEndpoints.coopMemberPromote(memberUserId),
      body: {'phone': phone},
    );
    return MembreCoop.fromJson(json);
  }

  /// Change le rôle d'un membre dans la coopérative.
  ///
  /// Aligné sur `UpdateMemberRoleDto` — attend `role_in_coop`, pas
  /// `role`.
  Future<MembreCoop> updateMemberRole({
    required String memberUserId,
    required CoopMemberRole role,
  }) async {
    final json = await _api.put<Map<String, dynamic>>(
      ApiEndpoints.coopMemberRole(memberUserId),
      body: {'role_in_coop': role.apiValue},
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

  /// Valide une annonce de vente assignée (la coop pèse / contrôle).
  ///
  /// Aligné sur `ValidateAnnonceDto` — exige `quantite_kg_reelle` ;
  /// `qualite_reelle` et `notes_pesee` optionnels. Le DTO refuse
  /// `prix_valide_kg`.
  Future<AnnonceVente> validateAnnonceVente({
    required String id,
    required double quantiteKgReelle,
    ProductQuality? qualiteReelle,
    String? notesPesee,
  }) async {
    final json = await _api.put<Map<String, dynamic>>(
      ApiEndpoints.coopAnnonceVenteValidate(id),
      body: {
        'quantite_kg_reelle': quantiteKgReelle,
        if (qualiteReelle != null) 'qualite_reelle': qualiteReelle.apiValue,
        if (notesPesee != null) 'notes_pesee': notesPesee,
      },
    );
    return AnnonceVente.fromJson(json);
  }

  /// Rejette une annonce de vente assignée.
  ///
  /// Aligné sur `RejectAnnonceDto` — exige `rejection_reason` (5..1000
  /// chars).
  Future<AnnonceVente> rejectAnnonceVente({
    required String id,
    required String rejectionReason,
  }) async {
    final json = await _api.put<Map<String, dynamic>>(
      ApiEndpoints.coopAnnonceVenteReject(id),
      body: {'rejection_reason': rejectionReason},
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

  /// Valide une prévision assignée (inspection coop).
  ///
  /// Aligné sur `ValidatePrevisionDto` — exige `quantite_kg_validee` ;
  /// `notes_inspection` optionnel.
  Future<Prevision> validatePrevision({
    required String id,
    required double quantiteKgValidee,
    String? notesInspection,
  }) async {
    final json = await _api.put<Map<String, dynamic>>(
      ApiEndpoints.coopPrevisionValidate(id),
      body: {
        'quantite_kg_validee': quantiteKgValidee,
        if (notesInspection != null) 'notes_inspection': notesInspection,
      },
    );
    return Prevision.fromJson(json);
  }

  /// Rejette une prévision assignée.
  ///
  /// Aligné sur `RejectAnnonceDto` (réutilisé) — attend
  /// `rejection_reason`.
  Future<Prevision> rejectPrevision({
    required String id,
    required String rejectionReason,
  }) async {
    final json = await _api.put<Map<String, dynamic>>(
      ApiEndpoints.coopPrevisionReject(id),
      body: {'rejection_reason': rejectionReason},
    );
    return Prevision.fromJson(json);
  }

  // ─── Agrégation publications ─────────────────────────────────────────

  /// Agrège plusieurs annonces validées en une publication coop.
  ///
  /// Aligné sur `AggregatePublicationDto` — exige `annonce_ids`,
  /// `prix_par_kg`, `qualite`. `region_id`, `ville_id`, `adresse_detail`
  /// optionnels. Les champs `titre`, `description`, `photos` ne sont
  /// pas whitelistés.
  Future<PublicationCoop> aggregatePublication({
    required List<String> annonceIds,
    required double prixParKg,
    required ProductQuality qualite,
    String? regionId,
    String? villeId,
    String? adresseDetail,
  }) async {
    final json = await _api.post<Map<String, dynamic>>(
      ApiEndpoints.coopPublicationsAggregate,
      body: {
        'annonce_ids': annonceIds,
        'prix_par_kg': prixParKg,
        'qualite': qualite.apiValue,
        if (regionId != null) 'region_id': regionId,
        if (villeId != null) 'ville_id': villeId,
        if (adresseDetail != null) 'adresse_detail': adresseDetail,
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

  /// Verse une avance à un membre de la coopérative.
  ///
  /// Aligné sur `PayAdvanceDto` — attend `notes`, pas `motif`. Le
  /// paramètre Dart conserve `motif` pour rester cohérent avec l'UI.
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
        if (motif != null) 'notes': motif,
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

  /// Crée une publication coop directement (sans agréger d'annonces).
  ///
  /// Aligné sur `CreatePublicationCoopDto` — exige `produit_id`,
  /// `quantite_kg`, `region_id`, `ville_id`, `coordinates {lat, lng}`.
  /// `prix_par_kg`, `qualite` optionnels. Les champs `titre`,
  /// `description`, `photos` ne sont pas whitelistés.
  Future<PublicationCoop> createPublication({
    required String produitId,
    required double quantiteKg,
    required String regionId,
    required String villeId,
    required double lat,
    required double lng,
    double? prixParKg,
    ProductQuality? qualite,
  }) async {
    final json = await _api.post<Map<String, dynamic>>(
      ApiEndpoints.coopPublications,
      body: {
        'produit_id': produitId,
        'quantite_kg': quantiteKg,
        'region_id': regionId,
        'ville_id': villeId,
        'coordinates': {'lat': lat, 'lng': lng},
        if (prixParKg != null) 'prix_par_kg': prixParKg,
        if (qualite != null) 'qualite': qualite.apiValue,
      },
    );
    return PublicationCoop.fromJson(json);
  }

  /// Met à jour une publication coop.
  ///
  /// Aligné sur `UpdatePublicationCoopDto` — accepte `quantite_kg`,
  /// `prix_par_kg`, `qualite`, `is_active`. Les champs `titre`,
  /// `description`, `status` ne sont pas whitelistés.
  Future<PublicationCoop> updatePublication(
    String id, {
    double? quantiteKg,
    double? prixParKg,
    ProductQuality? qualite,
    bool? isActive,
  }) async {
    final json = await _api.put<Map<String, dynamic>>(
      ApiEndpoints.coopPublicationById(id),
      body: {
        if (quantiteKg != null) 'quantite_kg': quantiteKg,
        if (prixParKg != null) 'prix_par_kg': prixParKg,
        if (qualite != null) 'qualite': qualite.apiValue,
        if (isActive != null) 'is_active': isActive,
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
