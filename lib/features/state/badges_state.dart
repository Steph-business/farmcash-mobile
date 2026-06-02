import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/enums.dart';
import '../../services/providers.dart';
import '../storage/prefs_storage.dart';
import 'auth_state.dart';

/// Providers globaux des badges du header utilisateur **et** du bottom
/// nav. Chaque page/onglet qui veut afficher un badge `watch` ces
/// providers et reçoit le nombre à jour.
///
/// Important : ces providers ne sont **PAS** `autoDispose`. Avant, quand
/// l'utilisateur changeait d'onglet, les providers se disposaient et le
/// badge disparaissait/réapparaissait (panier qui clignote). Maintenant
/// la valeur reste cached entre les changements d'onglet — on l'invalide
/// explicitement après une action (mark as read, ajout panier, etc.) ou
/// automatiquement quand une notif SSE arrive (cf. `notifications_sse_state.dart`).
///
/// Réinitialisation : à la déconnexion, les providers retournent 0 car
/// ils watch `authStateProvider` / `currentUserProvider`.

// ─── Notifications non lues ──────────────────────────────────────────

/// Nombre de notifications non lues de l'utilisateur courant.
/// Calculé côté client par filtrage de la liste (endpoint backend n'a
/// pas de `GET /unread-count` dédié pour V1). Garde `limit=50` suffisant
/// pour la précision d'affichage du badge (au-delà on affiche "50+").
final unreadNotificationsCountProvider = FutureProvider<int>((ref) async {
  // Ne pas appeler le service si l'utilisateur n'est pas connecté
  // (l'API renverrait 401 et on polluerait les logs).
  final isAuth = ref.watch(authStateProvider).isAuthenticated;
  if (!isAuth) return 0;
  try {
    final page =
        await ref.read(notificationsServiceProvider).list(limit: 50);
    return page.data.where((n) => !n.isRead).length;
  } catch (_) {
    return 0;
  }
});

// ─── Panier (acheteur uniquement) ────────────────────────────────────

/// Nombre d'articles dans le panier — uniquement pour le rôle BUYER.
/// Retourne 0 pour les autres rôles (le header n'affiche pas l'icône
/// panier ailleurs de toute façon).
final cartCountProvider = FutureProvider<int>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user?.role != UserRole.buyer) return 0;
  try {
    final panier = await ref.read(marketplaceServiceProvider).getPanier();
    return panier.nbArticles;
  } catch (_) {
    return 0;
  }
});

// ─── Propositions reçues non traitées (négociations entrantes) ──────

/// Nombre de propositions reçues **nouvelles** (pas encore vues) sur
/// les demandes d'achat du buyer.
///
/// « Nouveau » = `updatedAt` postérieur à la dernière visite de la page
/// Négociations (timestamp stocké en SharedPreferences via
/// `PrefsStorage.negociationsLastSeen`). Quand l'utilisateur ouvre la
/// page, on met ce timestamp à `now()` → toutes les propositions
/// deviennent « vues » → le badge tombe à 0.
///
/// On garde aussi le filtre « encore actionnable » (PENDING ou
/// COUNTER_OFFERED) : une proposition déjà acceptée ou refusée ne
/// doit plus compter même si elle est « nouvelle » techniquement.
final propositionsRecuesNonTraiteesCountProvider =
    FutureProvider<int>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user?.role != UserRole.buyer) return 0;
  final prefs = ref.read(prefsStorageProvider);
  // 1ère ouverture jamais → considère tout comme nouveau (timestamp = 0).
  final lastSeen =
      prefs.negociationsLastSeen ?? DateTime.fromMillisecondsSinceEpoch(0);
  try {
    final list = await ref
        .read(negotiationServiceProvider)
        .listPropositions(direction: 'incoming');
    return list.where((p) {
      final s = p.status;
      final actionnable = s == NegotiationStatus.pending ||
          s == NegotiationStatus.counterOffered;
      if (!actionnable) return false;
      // « Nouvelle » = touchée depuis la dernière visite. On utilise
      // `updatedAt` (qui bouge à chaque message / contre-offre) plutôt
      // que `createdAt` pour que les propositions sur lesquelles le
      // vendeur a fait du nouveau apparaissent aussi comme à voir.
      final stamp = p.updatedAt ?? p.createdAt;
      if (stamp == null) return true; // sans date, prudence → on compte
      return stamp.isAfter(lastSeen);
    }).length;
  } catch (_) {
    return 0;
  }
});

// ─── Messages non lus ────────────────────────────────────────────────

/// Total de messages non lus toutes conversations confondues.
///
/// Le backend n'expose pas d'endpoint dédié `unread-count` — on récupère
/// la liste paginée des conversations (déjà munie d'un champ
/// `unreadCount` par conversation, calculé via `lastReadAt` côté backend)
/// et on somme. `limit=50` couvre 99% des cas : un user avec >50
/// conversations actives est exceptionnel.
final unreadMessagesCountProvider = FutureProvider<int>((ref) async {
  final isAuth = ref.watch(authStateProvider).isAuthenticated;
  if (!isAuth) return 0;
  try {
    final page =
        await ref.read(messagingServiceProvider).listConversations(limit: 50);
    return page.data.fold<int>(0, (acc, conv) => acc + conv.unreadCount);
  } catch (_) {
    return 0;
  }
});
