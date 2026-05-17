import '../api_client/api_client.dart';
import '../api_client/api_endpoints.dart';
import '../models/models.dart';

/// Messaging — conversations 1-1 + messages.
class MessagingService {
  final ApiClient _api;
  MessagingService(this._api);

  Future<Conversation> createOrFindConversation({
    required String otherUserId,
    String? contextType,
    String? contextId,
  }) async {
    final json = await _api.post<Map<String, dynamic>>(
      ApiEndpoints.conversations,
      body: {
        'other_user_id': otherUserId,
        if (contextType != null) 'context_type': contextType,
        if (contextId != null) 'context_id': contextId,
      },
    );
    return Conversation.fromJson(json);
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

  Future<Message> sendMessage({
    required String conversationId,
    String? content,
    String? mediaUrl,
    String? mediaType,
  }) async {
    final json = await _api.post<Map<String, dynamic>>(
      ApiEndpoints.conversationMessages(conversationId),
      body: {
        if (content != null) 'content': content,
        if (mediaUrl != null) 'media_url': mediaUrl,
        if (mediaType != null) 'media_type': mediaType,
      },
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
