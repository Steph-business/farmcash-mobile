import '../api_client/api_client.dart';
import '../api_client/api_endpoints.dart';
import '../models/models.dart';

/// Notifications — liste + lecture + stream SSE.
///
/// Note : le stream SSE est exposé via une URL (préfixée du baseUrl) à
/// consommer avec un client SSE séparé (ex. `package:eventsource_plus`).
/// Ici on expose seulement l'URL pour éviter une dépendance lourde.
class NotificationsService {
  final ApiClient _api;
  NotificationsService(this._api);

  Future<Paginated<AppNotification>> list({
    bool? unreadOnly,
    String? type,
    int page = 1,
    int limit = 30,
  }) async {
    final raw = await _api.get<dynamic>(
      ApiEndpoints.notifications,
      query: {
        if (unreadOnly != null) 'unread_only': unreadOnly,
        if (type != null) 'type': type,
        'page': page,
        'limit': limit,
      },
    );
    return Paginated.fromJsonOrList(raw, AppNotification.fromJson);
  }

  Future<AppNotification> markAsRead(String id) async {
    final json = await _api.put<Map<String, dynamic>>(
      ApiEndpoints.notificationRead(id),
    );
    return AppNotification.fromJson(json);
  }

  Future<void> markAllAsRead() async {
    await _api.put<dynamic>(ApiEndpoints.notificationsReadAll);
  }

  Future<void> delete(String id) async {
    await _api.delete<dynamic>(ApiEndpoints.notificationById(id));
  }

  /// URL complète du flux SSE (à consommer avec un client SSE externe).
  String get streamUrl =>
      '${_api.dio.options.baseUrl}${ApiEndpoints.notificationsStream}';
}
