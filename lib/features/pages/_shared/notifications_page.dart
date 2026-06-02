import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../api_client/api_exception.dart';
import '../../../models/enums.dart';
import '../../../models/notification.dart';
import '../../../services/providers.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_dimens.dart';
import '../../state/auth_state.dart';
import '../../widgets/communs/snackbars.dart';
import '../../state/badges_state.dart';
import '../../widgets/notifications/entete_notifications.dart';
import '../../widgets/notifications/etat_erreur_notifications.dart';
import '../../widgets/notifications/etat_vide_notifications.dart';
import '../../widgets/notifications/router_notification.dart';
import '../../widgets/notifications/tuile_notification.dart';

// ─── Provider liste notifications ───────────────────────────────────────

/// Source de vérité : `GET /notifications` paginé (les 50 dernières
/// suffisent pour le scroll d'une session). Pull-to-refresh invalide ce
/// provider. Le flux SSE temps réel reste à câbler dans une PR dédiée.
final _notificationsProvider =
    FutureProvider.autoDispose<List<AppNotification>>((ref) async {
  final svc = ref.watch(notificationsServiceProvider);
  final page = await svc.list(limit: 50);
  return page.data;
});

/// Page Notifications partagée pour les 4 rôles.
///
/// Détecte le rôle via [currentUserProvider] et adapte :
/// - le rendu des tuiles (highlight unread varie selon le rôle),
/// - la navigation back (top-level vs in-stack),
/// - le bottom-nav décoratif quand pertinent.
///
/// La liste vient désormais de `notificationsService.list()` (réel API).
/// Tap → `markAsRead`, bouton "Tout lire" → `markAllAsRead`.
class NotificationsPage extends ConsumerWidget {
  const NotificationsPage({super.key});

  Future<void> _toutMarquerLu(BuildContext context, WidgetRef ref) async {
    try {
      await ref.read(notificationsServiceProvider).markAllAsRead();
      if (!context.mounted) return;
      ref.invalidate(_notificationsProvider);
      Snackbars.showInfo(
        context,
        'Toutes les notifications ont été marquées comme lues',
      );
    } on ApiException catch (e) {
      if (!context.mounted) return;
      Snackbars.showErreur(context, e.message);
    }
  }

  Future<void> _ouvrirNotif(
    BuildContext context,
    WidgetRef ref,
    AppNotification notif,
  ) async {
    // 1. Marquer comme lue (best-effort) + refresh du badge global.
    //    Une erreur ici n'empêche pas d'ouvrir la cible.
    if (!notif.isRead) {
      try {
        await ref.read(notificationsServiceProvider).markAsRead(notif.id);
        if (!context.mounted) return;
        ref.invalidate(_notificationsProvider);
        ref.invalidate(unreadNotificationsCountProvider);
      } on ApiException catch (_) {
        // Silencieux : l'invalidate suivant la recharge corrigera l'état.
      }
    }
    if (!context.mounted) return;
    // 2. Deep-link vers la cible (commande, chat, wallet, …) en fonction
    //    du type + data + rôle. Si pas de cible utile, snackbar fallback.
    final role = ref.read(currentUserProvider)?.role;
    ouvrirNotification(
      context,
      notif,
      role,
      onSystem: () {
        // Fallback : notif sans cible deep-link → on affiche juste son
        // titre via le snackbar unifié style apps pro.
        Snackbars.showInfo(
          context,
          notif.titre.isEmpty ? 'Notification' : notif.titre,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final role = ref.watch(currentUserProvider)?.role;
    final notifsAsync = ref.watch(_notificationsProvider);
    final highlightFullBg = _highlightFullBg(role);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            EnteteNotifications(
              role: role,
              onToutMarquerLu: () => _toutMarquerLu(context, ref),
            ),
            Expanded(
              child: notifsAsync.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                error: (err, _) => EtatErreurNotifications(
                  message: err is ApiException
                      ? err.message
                      : 'Erreur de chargement',
                  onRetry: () => ref.invalidate(_notificationsProvider),
                ),
                data: (items) {
                  if (items.isEmpty) return const EtatVideNotifications();
                  return RefreshIndicator(
                    onRefresh: () async {
                      ref.invalidate(_notificationsProvider);
                      await ref.read(_notificationsProvider.future);
                    },
                    child: ListView.builder(
                      padding: _listPadding(role),
                      itemCount: items.length,
                      itemBuilder: (_, i) {
                        final n = items[i];
                        return TuileNotification(
                          notif: n,
                          isLast: i == items.length - 1,
                          onTap: () => _ouvrirNotif(context, ref, n),
                          highlightFullBg: highlightFullBg,
                          layoutForAcheteur: role == UserRole.buyer,
                        );
                      },
                    ),
                  );
                },
              ),
            ),
            // Bottom-nav décoratif retiré : la page Notifications est
            // poussée hors shell, donc aucune barre du bas ne doit
            // s'afficher. Avant on rendait une fausse barre grisée
            // pour "rappeler" le contexte — ça créait juste de la
            // confusion (l'utilisateur croyait pouvoir tap, mais elle
            // était inactive).
          ],
        ),
      ),
    );
  }

  EdgeInsets _listPadding(UserRole? role) {
    if (role == UserRole.buyer) return EdgeInsets.zero;
    return const EdgeInsets.fromLTRB(
      AppDimens.pagePaddingH,
      0,
      AppDimens.pagePaddingH,
      AppDimens.space16,
    );
  }

  /// Acheteur / coop / transp. : fond primary-soft pour toute la tuile non-lue.
  /// Producteur : seulement la pastille + bulle (pas de fond plein).
  bool _highlightFullBg(UserRole? role) {
    return role == UserRole.buyer ||
        role == UserRole.cooperative ||
        role == UserRole.transporter;
  }
}

