import 'dart:convert';

import 'package:flutter_client_sse/constants/sse_request_type_enum.dart';
import 'package:flutter_client_sse/flutter_client_sse.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../api_client/api_endpoints.dart';
import '../../constants/app_constants.dart';
import '../../models/notification.dart';
import 'auth_state.dart';
import 'badges_state.dart';

// ─── Stream SSE des notifications temps réel ──────────────────────────
//
// Le backend expose `GET /notifications/stream` (SSE) qui pousse en
// temps réel chaque notification destinée à l'utilisateur connecté.
// Le payload du `data:` SSE est l'objet notification complet (cf.
// `notifications.controller.ts:55`).
//
// Côté mobile, on s'y abonne dès qu'un user est connecté et on émet
// les notifications parsées sur un Stream. Un Consumer plus haut dans
// l'arbre (`AppShell` ou équivalent) écoute ce stream pour :
//   - invalider `unreadNotificationsCountProvider` (badge cloche)
//   - invalider les providers métier selon `data.commande_id` /
//     `data.shipment_id` (commandes, missions transporteur, etc.)
//
// On utilise un `StreamProvider.autoDispose` : tant qu'au moins un
// listener écoute, la connexion reste ouverte. Quand l'utilisateur
// quitte l'app ou se déconnecte (currentUser passe à null), le provider
// se dispose et la connexion SSE se ferme proprement.

/// Stream SSE des notifications temps réel pour l'utilisateur connecté.
/// Émet `null` quand l'utilisateur n'est pas connecté (no-op).
final notificationsLiveStreamProvider =
    StreamProvider.autoDispose<AppNotification>((ref) async* {
  // Si pas d'utilisateur connecté → pas de stream. Le provider se
  // redémarrera automatiquement quand `currentUserProvider` change.
  final user = ref.watch(currentUserProvider);
  if (user == null) return;

  // Récupère le JWT pour authentifier la connexion SSE. On lit
  // directement le secure storage parce que les headers de Dio ne
  // sont pas réutilisables avec un client SSE séparé.
  const storage = FlutterSecureStorage();
  final token = await storage.read(key: AppConstants.accessTokenKey);
  if (token == null) return;

  final url = '${AppConstants.apiBaseUrl}${ApiEndpoints.notificationsStream}';
  final sub = SSEClient.subscribeToSSE(
    method: SSERequestType.GET,
    url: url,
    header: {
      'Authorization': 'Bearer $token',
      'Accept': 'text/event-stream',
      'Cache-Control': 'no-cache',
    },
  );

  // Fermer proprement la connexion SSE quand le provider est disposed
  // (logout, hot-restart, app en background…).
  ref.onDispose(() {
    SSEClient.unsubscribeFromSSE();
  });

  await for (final event in sub) {
    final data = event.data;
    if (data == null || data.isEmpty || data == 'null') continue;
    try {
      final decoded = jsonDecode(data);
      if (decoded is Map<String, dynamic>) {
        yield AppNotification.fromJson(decoded);
      }
    } catch (_) {
      // Payload non parseable (event control SSE par ex.) — on skip.
    }
  }
});

/// Hook à appeler depuis un widget racine pour brancher l'invalidation
/// automatique des providers concernés sur chaque notif reçue.
///
/// Utilisation :
/// ```dart
/// class _RootListenerState extends ConsumerState<RootListener> {
///   @override
///   void initState() {
///     super.initState();
///     // Démarrer l'écoute après le 1er frame pour que Riverpod
///     // ait fini d'initialiser les providers.
///     WidgetsBinding.instance.addPostFrameCallback((_) {
///       brancherListenerNotificationsLive(ref);
///     });
///   }
/// }
/// ```
void brancherListenerNotificationsLive(WidgetRef ref) {
  ref.listen<AsyncValue<AppNotification>>(
    notificationsLiveStreamProvider,
    (previous, next) {
      next.whenData((notif) {
        // Toujours invalider le badge global (compteur non-lu) — la
        // cloche en header doit refléter l'arrivée d'une nouvelle notif.
        ref.invalidate(unreadNotificationsCountProvider);

        // Si la notif est de type MESSAGE, invalider aussi le compteur
        // messages — le badge sur l'onglet "Messages" du bottom nav
        // doit s'incrémenter sans pull-to-refresh.
        final typeUpper = notif.type.toUpperCase();
        if (typeUpper == 'MESSAGE' || typeUpper == 'NEW_MESSAGE') {
          ref.invalidate(unreadMessagesCountProvider);
        }

        // NEGOTIATION (nouvelle proposition reçue sur une demande
        // d'achat, ou changement de statut) → invalider le compteur
        // de la tuile « Négociations » pour que le badge se mette
        // à jour live.
        if (typeUpper == 'NEGOTIATION' ||
            typeUpper == 'ORDER_FROM_NEGOTIATION') {
          ref.invalidate(propositionsRecuesNonTraiteesCountProvider);
        }

        // TODO : invalidations spécifiques selon data.commande_id /
        // shipment_id quand on identifiera des providers globaux à
        // rafraîchir (liste commandes, missions transporteur…).
      });
    },
  );
}
