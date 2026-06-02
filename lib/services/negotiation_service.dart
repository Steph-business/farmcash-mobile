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

  /// Traite une candidature.
  ///
  /// Backend retourne `{ message, commande_id?, reference? }` — PAS la
  /// candidature complète. D'où le type [TraitementNegociationResultat].
  Future<TraitementNegociationResultat> traiterCandidature({
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
    return TraitementNegociationResultat.fromJson(json);
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

  /// Traite une proposition (Accepter / Refuser / Contre-offre / Annuler).
  ///
  /// Backend retourne `{ message, commande_id?, reference? }` — PAS la
  /// proposition complète. Tenter `Proposition.fromJson` ici crashait
  /// avec « id is null » (cf. fix 2026-05-27).
  Future<TraitementNegociationResultat> traiterProposition({
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
    return TraitementNegociationResultat.fromJson(json);
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

  /// Crée une contre-offre sur une publication coop.
  ///
  /// Aligné sur `CreateContreOffreCoopDto` — attend `publication_id`,
  /// pas `publication_coop_id`.
  Future<ContreOffreCoop> createContreOffreCoop({
    required String publicationCoopId,
    required double quantiteKg,
    required double prixProposeKg,
    String? message,
  }) async {
    final json = await _api.post<Map<String, dynamic>>(
      ApiEndpoints.contreOffresCoop,
      body: {
        'publication_id': publicationCoopId,
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

  /// Traite une contre-offre coop.
  ///
  /// Backend retourne `{ message }` (parfois enrichi). Cf. note sur
  /// [traiterProposition].
  Future<TraitementNegociationResultat> traiterContreOffreCoop({
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
    return TraitementNegociationResultat.fromJson(json);
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

  /// Construit le body uniforme pour les endpoints `traiter*`.
  ///
  /// Aligné sur `TraiterOffreDto` (candidatures.dto.ts) — attend
  /// `action`, `prix_contre_offre`, `quantite_kg`, `note`.
  Map<String, dynamic> _traiterBody(
    NegotiationAction action,
    double? prixContreOffreKg,
    double? quantiteContreOffreKg,
    String? message,
  ) {
    return {
      'action': action.apiValue,
      if (prixContreOffreKg != null) 'prix_contre_offre': prixContreOffreKg,
      if (quantiteContreOffreKg != null)
        'quantite_kg': quantiteContreOffreKg,
      if (message != null) 'note': message,
    };
  }

  /// Convertit un payload `List` ou `{ data: List }` en liste typée.
  ///
  /// Robuste face aux items malformés : si la déserialisation d'UN item
  /// échoue (ex. champ obligatoire à null côté backend), on log l'item
  /// problématique et on continue avec les autres. Sans cette tolérance
  /// un seul record cassé en base fait crash toute la page de liste.
  List<T> _asList<T>(dynamic raw, T Function(Map<String, dynamic>) from) {
    Iterable<dynamic>? items;
    if (raw is List) {
      items = raw;
    } else if (raw is Map && raw['data'] is List) {
      items = raw['data'] as List;
    } else {
      return const [];
    }

    final result = <T>[];
    for (final item in items) {
      if (item is! Map) continue;
      try {
        result.add(from(item.cast<String, dynamic>()));
      } catch (e, st) {
        // ignore: avoid_print
        print(
          '[NegotiationService._asList] item malformé skipped: $e\n'
          'item=$item\n$st',
        );
      }
    }
    return result;
  }
}

/// Actions sur une négociation (candidature, proposition, contre-offre).
///
/// Aligné sur l'enum backend `NegotiationAction` (candidatures.dto.ts).
/// Les valeurs API sont `ACCEPTED|REJECTED|COUNTER_OFFER|CANCELLED` —
/// PAS les formes courtes `ACCEPT|REJECT|COUNTER|CANCEL`.
enum NegotiationAction {
  accept,
  reject,
  counter,
  cancel;

  String get apiValue {
    switch (this) {
      case NegotiationAction.accept:
        return 'ACCEPTED';
      case NegotiationAction.reject:
        return 'REJECTED';
      case NegotiationAction.counter:
        return 'COUNTER_OFFER';
      case NegotiationAction.cancel:
        return 'CANCELLED';
    }
  }
}
