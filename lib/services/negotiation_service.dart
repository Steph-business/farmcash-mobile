import '../api_client/api_client.dart';
import '../api_client/api_endpoints.dart';
import '../models/models.dart';

/// Négociation — candidatures (BUYER → FARMER), propositions (FARMER/COOP →
/// BUYER), contre-offres COOP (BUYER → COOP).
///
/// L'action de réponse est uniforme : `traiter` avec une action parmi
/// `ACCEPT | REJECT | COUNTER | CANCEL`.
class NegotiationService {
  final ApiClient _api;
  NegotiationService(this._api);

  // ─── Candidatures (BUYER sur annonce vente) ──────────────────────────

  Future<Candidature> createCandidature({
    required String annonceId,
    required double quantiteKg,
    required double prixProposeKg,
    String? message,
  }) async {
    final json = await _api.post<Map<String, dynamic>>(
      ApiEndpoints.candidatures,
      body: {
        'annonce_id': annonceId,
        'quantite_kg': quantiteKg,
        'prix_propose_kg': prixProposeKg,
        if (message != null) 'message': message,
      },
    );
    return Candidature.fromJson(json);
  }

  Future<List<Candidature>> listCandidatures({
    String direction = 'outgoing',
    NegotiationStatus? status,
  }) async {
    final raw = await _api.get<dynamic>(
      ApiEndpoints.candidatures,
      query: {
        'direction': direction,
        if (status != null) 'status': status.apiValue,
      },
    );
    return _asList(raw, Candidature.fromJson);
  }

  Future<Candidature> traiterCandidature({
    required String id,
    required NegotiationAction action,
    double? prixContreOffreKg,
    double? quantiteContreOffreKg,
    String? message,
  }) async {
    final json = await _api.put<Map<String, dynamic>>(
      ApiEndpoints.candidatureTraiter(id),
      body: _traiterBody(
        action,
        prixContreOffreKg,
        quantiteContreOffreKg,
        message,
      ),
    );
    return Candidature.fromJson(json);
  }

  Future<Message> sendCandidatureMessage({
    required String candidatureId,
    required String content,
  }) async {
    final json = await _api.post<Map<String, dynamic>>(
      ApiEndpoints.candidatureMessages(candidatureId),
      body: {'content': content},
    );
    return Message.fromJson(json);
  }

  Future<List<Message>> listCandidatureMessages(String candidatureId) async {
    final raw =
        await _api.get<dynamic>(ApiEndpoints.candidatureMessages(candidatureId));
    return _asList(raw, Message.fromJson);
  }

  // ─── Propositions (FARMER/COOP sur annonce achat) ────────────────────

  Future<Proposition> createProposition({
    required String annonceAchatId,
    required double quantiteKg,
    required double prixProposeKg,
    String? message,
  }) async {
    final json = await _api.post<Map<String, dynamic>>(
      ApiEndpoints.propositions,
      body: {
        'annonce_achat_id': annonceAchatId,
        'quantite_kg': quantiteKg,
        'prix_propose_kg': prixProposeKg,
        if (message != null) 'message': message,
      },
    );
    return Proposition.fromJson(json);
  }

  Future<List<Proposition>> listPropositions({
    String direction = 'outgoing',
    NegotiationStatus? status,
  }) async {
    final raw = await _api.get<dynamic>(
      ApiEndpoints.propositions,
      query: {
        'direction': direction,
        if (status != null) 'status': status.apiValue,
      },
    );
    return _asList(raw, Proposition.fromJson);
  }

  Future<Proposition> traiterProposition({
    required String id,
    required NegotiationAction action,
    double? prixContreOffreKg,
    double? quantiteContreOffreKg,
    String? message,
  }) async {
    final json = await _api.put<Map<String, dynamic>>(
      ApiEndpoints.propositionTraiter(id),
      body: _traiterBody(
        action,
        prixContreOffreKg,
        quantiteContreOffreKg,
        message,
      ),
    );
    return Proposition.fromJson(json);
  }

  Future<Message> sendPropositionMessage({
    required String propositionId,
    required String content,
  }) async {
    final json = await _api.post<Map<String, dynamic>>(
      ApiEndpoints.propositionMessages(propositionId),
      body: {'content': content},
    );
    return Message.fromJson(json);
  }

  Future<List<Message>> listPropositionMessages(String propositionId) async {
    final raw =
        await _api.get<dynamic>(ApiEndpoints.propositionMessages(propositionId));
    return _asList(raw, Message.fromJson);
  }

  // ─── Contre-offres COOP (BUYER sur publication coop) ─────────────────

  Future<ContreOffreCoop> createContreOffreCoop({
    required String publicationCoopId,
    required double quantiteKg,
    required double prixProposeKg,
    String? message,
  }) async {
    final json = await _api.post<Map<String, dynamic>>(
      ApiEndpoints.contreOffresCoop,
      body: {
        'publication_coop_id': publicationCoopId,
        'quantite_kg': quantiteKg,
        'prix_propose_kg': prixProposeKg,
        if (message != null) 'message': message,
      },
    );
    return ContreOffreCoop.fromJson(json);
  }

  Future<List<ContreOffreCoop>> listContreOffresCoop({
    String direction = 'outgoing',
    NegotiationStatus? status,
  }) async {
    final raw = await _api.get<dynamic>(
      ApiEndpoints.contreOffresCoop,
      query: {
        'direction': direction,
        if (status != null) 'status': status.apiValue,
      },
    );
    return _asList(raw, ContreOffreCoop.fromJson);
  }

  Future<ContreOffreCoop> traiterContreOffreCoop({
    required String id,
    required NegotiationAction action,
    double? prixContreOffreKg,
    double? quantiteContreOffreKg,
    String? message,
  }) async {
    final json = await _api.put<Map<String, dynamic>>(
      ApiEndpoints.contreOffreCoopTraiter(id),
      body: _traiterBody(
        action,
        prixContreOffreKg,
        quantiteContreOffreKg,
        message,
      ),
    );
    return ContreOffreCoop.fromJson(json);
  }

  Future<Message> sendContreOffreCoopMessage({
    required String contreOffreId,
    required String content,
  }) async {
    final json = await _api.post<Map<String, dynamic>>(
      ApiEndpoints.contreOffreCoopMessages(contreOffreId),
      body: {'content': content},
    );
    return Message.fromJson(json);
  }

  Future<List<Message>> listContreOffreCoopMessages(
      String contreOffreId) async {
    final raw = await _api.get<dynamic>(
      ApiEndpoints.contreOffreCoopMessages(contreOffreId),
    );
    return _asList(raw, Message.fromJson);
  }

  // ─── Helpers ─────────────────────────────────────────────────────────

  Map<String, dynamic> _traiterBody(
    NegotiationAction action,
    double? prixContreOffreKg,
    double? quantiteContreOffreKg,
    String? message,
  ) {
    return {
      'action': action.apiValue,
      if (prixContreOffreKg != null) 'prix_contre_offre_kg': prixContreOffreKg,
      if (quantiteContreOffreKg != null)
        'quantite_contre_offre_kg': quantiteContreOffreKg,
      if (message != null) 'message': message,
    };
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

enum NegotiationAction {
  accept,
  reject,
  counter,
  cancel;

  String get apiValue {
    switch (this) {
      case NegotiationAction.accept:
        return 'ACCEPT';
      case NegotiationAction.reject:
        return 'REJECT';
      case NegotiationAction.counter:
        return 'COUNTER';
      case NegotiationAction.cancel:
        return 'CANCEL';
    }
  }
}
