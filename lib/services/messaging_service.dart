import '../api_client/api_client.dart';
import '../api_client/api_endpoints.dart';
import '../models/models.dart';

/// Messaging — conversations 1-1 + messages.
class MessagingService {
  final ApiClient _api;
  MessagingService(this._api);

  /// Crée (ou retrouve) une conversation 1-1 ou groupe.
  ///
  /// Aligné sur `CreateConversationDto` — attend
  /// `{participants: string[], titre?, type?}`. Le créateur est ajouté
  /// automatiquement côté serveur — n'inclure que les AUTRES
  /// participants.
  Future<Conversation> createConversation({
    required List<String> participantIds,
    String? titre,
    String? type,
  }) async {
    final json = await _api.post<Map<String, dynamic>>(
      ApiEndpoints.conversations,
      body: {
        'participants': participantIds,
        if (titre != null) 'titre': titre,
        if (type != null) 'type': type,
      },
    );
    return Conversation.fromJson(json);
  }

  /// Wrapper rétro-compatible pour le flow conversation 1-1.
  ///
  /// La signature historique était `{otherUserId, contextType?, contextId?}`.
  /// Le backend ne supporte pas les `context_*` — on les ignore et on
  /// délègue à [createConversation].
  Future<Conversation> createOrFindConversation({
    required String otherUserId,
    String? contextType,
    String? contextId,
  }) {
    return createConversation(participantIds: [otherUserId]);
  }

  Future<Paginated<Conversation>> listConversations({
    int page = 1,
    int limit = 20,
  }) async {
    final raw = await _api.get<dynamic>(
      ApiEndpoints.conversations,
      query: {'page': page, 'limit': limit},
    );
    return Paginated.fromJsonOrList(raw, Conversation.fromJson);
  }

  /// Envoie un message dans une conversation.
  ///
  /// Aligné sur `SendMessageDto` — `content` est REQUIRED (1..5000
  /// chars). Pour un message purement média, l'UI doit injecter une
  /// description ou le nom du fichier ; on substitue ici un fallback
  /// minimal (média sans texte) afin d'éviter un 400.
  Future<Message> sendMessage({
    required String conversationId,
    String? content,
    String? mediaUrl,
    String? mediaType,
  }) async {
    final body = <String, dynamic>{};
    final c = content?.trim();
    if (c != null && c.isNotEmpty) {
      body['content'] = c;
    } else if (mediaUrl != null && mediaUrl.isNotEmpty) {
      // Le DTO refuse `content` vide → fallback documenté à partir du
      // type de média.
      body['content'] = mediaType == 'IMAGE'
          ? '[photo]'
          : mediaType == 'VIDEO'
              ? '[vidéo]'
              : mediaType == 'AUDIO'
                  ? '[audio]'
                  : mediaType == 'DOCUMENT'
                      ? '[document]'
                      : '[média]';
    } else {
      body['content'] = '';
    }
    if (mediaUrl != null) body['media_url'] = mediaUrl;
    if (mediaType != null) body['media_type'] = mediaType;
    final json = await _api.post<Map<String, dynamic>>(
      ApiEndpoints.conversationMessages(conversationId),
      body: body,
    );
    return Message.fromJson(json);
  }

  Future<Paginated<Message>> listMessages({
    required String conversationId,
    int page = 1,
    int limit = 30,
    DateTime? before,
  }) async {
    final raw = await _api.get<dynamic>(
      ApiEndpoints.conversationMessages(conversationId),
      query: {
        'page': page,
        'limit': limit,
        if (before != null) 'before': before.toIso8601String(),
      },
    );
    return Paginated.fromJsonOrList(raw, Message.fromJson);
  }

  Future<void> markConversationRead(String conversationId) async {
    await _api.put<dynamic>(ApiEndpoints.conversationRead(conversationId));
  }

  // ─── Phone proxy (chantier 5) ────────────────────────────────────────

  /// Demande un numéro proxy (Twilio) pour appeler [calleeUserId] sans
  /// exposer son vrai numéro. Le backend exige une relation business
  /// active (commande, livraison, même coop) — sinon 403.
  ///
  /// Réutilise une session existante si TTL non expiré (14j par défaut).
  /// [commandeId] est OBLIGATOIRE pour les paires FARMER↔BUYER.
  Future<PhoneProxySession> createProxyCall({
    required String calleeUserId,
    String? commandeId,
  }) async {
    final json = await _api.post<Map<String, dynamic>>(
      ApiEndpoints.phoneProxy,
      body: {
        'callee_user_id': calleeUserId,
        if (commandeId != null) 'commande_id': commandeId,
      },
    );
    return PhoneProxySession.fromJson(json);
  }
}
