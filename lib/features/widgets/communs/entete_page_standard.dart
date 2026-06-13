// =====================================================================
//  EntetePageStandard — en-tête unifié de TOUTES les pages secondaires
//  ---------------------------------------------------------------------
//  Pattern unique appliqué dans toute l'app pour les 4 rôles :
//
//     [←]  Titre de la page                              [🔔]
//
//  - Flèche retour à gauche : vrai back (`context.pop()`) avec fallback
//    vers l'accueil du rôle si la pile de navigation est vide.
//  - Titre de la page au centre (ce que demande le PO : « le nom de la
//    page en question là où on est »).
//  - Cloche notifications à droite : badge dynamique, route vers la page
//    notifications DU RÔLE COURANT (détecté via currentUserProvider).
//
//  Les pages d'ACCUEIL (racine d'onglet) gardent leur header identité
//  (avatar + nom + cloche) — ce composant ne s'applique QU'AUX pages
//  secondaires (détail, sous-pages, formulaires…).
//
//  Optionnellement, `actions` permet d'insérer des boutons custom AVANT
//  la cloche (ex : panier acheteur, partage, édition).
// =====================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../models/enums.dart';
import '../../../routing/route_names.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_dimens.dart';
import '../../../theme/app_text_styles.dart';
import '../../state/auth_state.dart';
import '../../state/badges_state.dart';
import 'badge_notification.dart';

class EntetePageStandard extends ConsumerWidget {
  const EntetePageStandard({
    required this.titre,
    this.onBack,
    this.actions = const [],
    this.montrerNotifications = true,
    super.key,
  });

  /// Nom de la page affiché à droite du back.
  final String titre;

  /// Action back custom. Si null → `context.pop()` (avec fallback accueil
  /// du rôle si la pile est vide, pour ne jamais coincer l'utilisateur).
  final VoidCallback? onBack;

  /// Boutons custom insérés AVANT la cloche notifications (optionnel).
  final List<Widget> actions;

  /// Masque la cloche si false (rare — ex. flux d'inscription).
  final bool montrerNotifications;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifCount =
        ref.watch(unreadNotificationsCountProvider).valueOrNull ?? 0;
    final role = ref.watch(currentUserProvider)?.role;

    return Container(
      color: AppColors.background,
      padding: const EdgeInsets.fromLTRB(
        AppDimens.space8,
        AppDimens.space8,
        AppDimens.space8,
        AppDimens.space8,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ── Flèche retour ───────────────────────────────────────────
          _IconRond(
            icon: Icons.arrow_back,
            onTap: onBack ?? () => _backOuAccueil(context, role),
          ),
          const SizedBox(width: 4),
          // ── Titre de la page ────────────────────────────────────────
          Expanded(
            child: Text(
              titre,
              style: AppTextStyles.titleMedium.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.text,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          // ── Actions custom optionnelles ─────────────────────────────
          ...actions,
          // ── Cloche notifications ────────────────────────────────────
          if (montrerNotifications)
            _IconRond(
              icon: Icons.notifications_none,
              badge: notifCount,
              onTap: () => _ouvrirNotifications(context, role),
            ),
        ],
      ),
    );
  }

  /// Retour arrière : pop la route courante ; si pas de route à pop
  /// (deep-link direct, par ex.), on retombe sur l'accueil du rôle.
  void _backOuAccueil(BuildContext context, UserRole? role) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(_accueilPour(role));
    }
  }

  void _ouvrirNotifications(BuildContext context, UserRole? role) {
    switch (role) {
      case UserRole.farmer:
        context.push(RouteNames.producteurNotificationsPath);
      case UserRole.buyer:
        context.push(RouteNames.acheteurNotificationsPath);
      case UserRole.cooperative:
        context.push(RouteNames.cooperativeNotificationsPath);
      case UserRole.transporter:
        context.push(RouteNames.transporteurNotificationsPath);
      case _:
        // Rôle inconnu — pas de page notif dédiée, on ne fait rien.
        break;
    }
  }

  String _accueilPour(UserRole? role) {
    switch (role) {
      case UserRole.farmer:
        return RouteNames.accueilProducteurPath;
      case UserRole.buyer:
        return RouteNames.accueilAcheteurPath;
      case UserRole.cooperative:
        return RouteNames.accueilCooperativePath;
      case UserRole.transporter:
        return RouteNames.accueilTransporteurPath;
      case _:
        return RouteNames.connexionPath;
    }
  }
}

/// Bouton icône arrondi avec pastille optionnelle. Style aligné sur les
/// autres en-têtes (HeaderUtilisateur, EntetePageCompacte*).
class _IconRond extends StatelessWidget {
  const _IconRond({
    required this.icon,
    required this.onTap,
    this.badge = 0,
  });

  final IconData icon;
  final VoidCallback onTap;
  final int badge;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: BadgeNotification(
          count: badge,
          child: Icon(
            icon,
            size: AppDimens.iconL,
            color: AppColors.text,
          ),
        ),
      ),
    );
  }
}
