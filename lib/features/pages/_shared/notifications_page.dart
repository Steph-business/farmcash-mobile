import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../api_client/api_exception.dart';
import '../../../models/enums.dart';
import '../../../models/notification.dart';
import '../../../services/providers.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_dimens.dart';
import '../../../theme/app_text_styles.dart';
import '../../state/auth_state.dart';
import '../../widgets/communs/snackbars.dart';
import '../../widgets/notifications/entete_notifications.dart';
import '../../widgets/notifications/etat_erreur_notifications.dart';
import '../../widgets/notifications/etat_vide_notifications.dart';
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
    // Marquage best-effort si non lue. Une erreur ici n'a pas d'impact UX.
    if (!notif.isRead) {
      try {
        await ref.read(notificationsServiceProvider).markAsRead(notif.id);
        if (!context.mounted) return;
        ref.invalidate(_notificationsProvider);
      } on ApiException catch (_) {
        // Silencieux : l'invalidate suivant la recharge corrigera l'état.
      }
    }
    // TODO(notif-deeplink) : router vers la cible selon `notif.data`
    // (commande_id → page commande, candidature_id → négo, etc.). Pour
    // l'instant on affiche un toast informatif minimal.
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(notif.titre.isEmpty ? 'Notification' : notif.titre),
        behavior: SnackBarBehavior.floating,
      ),
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
            _BottomNavForRole(role: role),
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

// ─── Bottom-nav par rôle ────────────────────────────────────────────────
//
// TODO(refacto-bottom-nav) : factoriser ces 4 variantes (+ `_NavItem`)
// vers `widgets/communs/` une fois le pattern stabilisé sur l'ensemble
// des pages. Pour l'instant elles restent inline ici car elles sont
// purement décoratives (Opacity 0.45) et propres à la page Notifications.

class _BottomNavForRole extends StatelessWidget {
  const _BottomNavForRole({required this.role});

  final UserRole? role;

  @override
  Widget build(BuildContext context) {
    switch (role) {
      case UserRole.farmer:
        return const _BottomNavStaticProducteur();
      case UserRole.buyer:
        return const _BottomNavDimmedAcheteur();
      case UserRole.cooperative:
        return const _BottomNavDimmedCooperative();
      case UserRole.transporter:
        return const _BottomNavDimmedTransporteur();
      default:
        return const SizedBox.shrink();
    }
  }
}

class _BottomNavStaticProducteur extends StatelessWidget {
  const _BottomNavStaticProducteur();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppDimens.bottomNavHeight,
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(
          top: BorderSide(
            color: AppColors.border,
            width: AppDimens.borderThin,
          ),
        ),
      ),
      child: Row(
        children: const [
          _NavItem(icon: Icons.home_outlined, label: 'Accueil'),
          _NavItem(icon: Icons.chat_bubble_outline, label: 'Messages'),
          SizedBox(width: 56 + 8),
          _NavItem(icon: Icons.receipt_long_outlined, label: 'Commandes'),
          _NavItem(icon: Icons.person_outline, label: 'Profil'),
        ],
      ),
    );
  }
}

class _BottomNavDimmedAcheteur extends StatelessWidget {
  const _BottomNavDimmedAcheteur();

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: 0.45,
      child: Container(
        height: AppDimens.bottomNavHeight,
        decoration: const BoxDecoration(
          color: AppColors.background,
          border: Border(
            top: BorderSide(
              color: AppColors.border,
              width: AppDimens.borderThin,
            ),
          ),
        ),
        child: Row(
          children: const [
            _NavItem(icon: Icons.home_outlined, label: 'Accueil'),
            _NavItem(icon: Icons.storefront_outlined, label: 'Marché'),
            _NavItem(icon: Icons.chat_bubble_outline, label: 'Messages'),
            _NavItem(icon: Icons.receipt_long_outlined, label: 'Commandes'),
            _NavItem(icon: Icons.person_outline, label: 'Profil'),
          ],
        ),
      ),
    );
  }
}

class _BottomNavDimmedCooperative extends StatelessWidget {
  const _BottomNavDimmedCooperative();

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: 0.45,
      child: Container(
        height: AppDimens.bottomNavHeight,
        decoration: const BoxDecoration(
          color: AppColors.background,
          border: Border(
            top: BorderSide(
              color: AppColors.border,
              width: AppDimens.borderThin,
            ),
          ),
        ),
        child: Row(
          children: const [
            _NavItem(icon: Icons.home_outlined, label: 'Accueil'),
            _NavItem(icon: Icons.groups_outlined, label: 'Membres'),
            SizedBox(width: 56 + 8),
            _NavItem(icon: Icons.inventory_2_outlined, label: 'Stock'),
            _NavItem(icon: Icons.storefront_outlined, label: 'Marché'),
          ],
        ),
      ),
    );
  }
}

class _BottomNavDimmedTransporteur extends StatelessWidget {
  const _BottomNavDimmedTransporteur();

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: 0.45,
      child: Container(
        height: AppDimens.bottomNavHeight,
        decoration: const BoxDecoration(
          color: AppColors.background,
          border: Border(
            top: BorderSide(
              color: AppColors.border,
              width: AppDimens.borderThin,
            ),
          ),
        ),
        child: Row(
          children: const [
            _NavItem(icon: Icons.home_outlined, label: 'Accueil'),
            _NavItem(icon: Icons.local_shipping_outlined, label: 'Missions'),
            _NavItem(icon: Icons.chat_bubble_outline, label: 'Messages'),
            _NavItem(icon: Icons.person_outline, label: 'Profil'),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 22, color: AppColors.textSecondary),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
