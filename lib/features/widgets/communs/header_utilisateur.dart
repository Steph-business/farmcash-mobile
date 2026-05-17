import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../models/enums.dart';
import '../../../models/utilisateur.dart';
import '../../../routing/route_names.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_dimens.dart';
import '../../../theme/app_text_styles.dart';
import '../../state/auth_state.dart';
import 'badge_notification.dart';

/// Header utilisateur partagé, posé en haut des pages d'accueil de chaque
/// rôle. Variantes contrôlées par [variant].
///
/// - **Avatar tappable** → ouvre le profil du rôle courant.
/// - **Sous-titre** : adapté au rôle (région, missions du jour, etc.).
/// - **Actions à droite** : icônes messages (sauf si Messages est en onglet
///   bottom nav), notifications, et panier pour l'acheteur.
class HeaderUtilisateur extends ConsumerWidget {
  const HeaderUtilisateur({
    required this.variant,
    this.unreadMessages = 0,
    this.unreadNotifications = 0,
    this.cartCount = 0,
    this.subtitleOverride,
    this.bottomChild,
    super.key,
  });

  /// Quel template d'affichage utiliser.
  final HeaderVariant variant;

  /// Badges (laisser à 0 = caché).
  final int unreadMessages;
  final int unreadNotifications;
  final int cartCount;

  /// Si fourni, remplace le sous-titre par défaut (ex: "12 actions à traiter"
  /// calculé dynamiquement côté Coop).
  final String? subtitleOverride;

  /// Slot optionnel sous le header (ex: search bar pour l'acheteur).
  final Widget? bottomChild;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);

    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppDimens.pagePaddingH,
        AppDimens.space12,
        AppDimens.pagePaddingH,
        AppDimens.space12,
      ),
      color: AppColors.background,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              _AvatarRond(
                user: user,
                onTap: () => _openProfile(context, user?.role),
              ),
              AppDimens.hGap12,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Ligne 1 : "Bienvenue" (ou subtitleOverride si fourni
                    // — utile pour la coop qui affiche "X actions à traiter").
                    Text(
                      _ligne1(),
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    // Ligne 2 : nom complet de l'utilisateur.
                    Text(
                      _nomComplet(user),
                      style: AppTextStyles.titleMedium.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              ..._actionsDroite(context),
            ],
          ),
          if (bottomChild != null) ...[
            AppDimens.vGap12,
            bottomChild!,
          ],
        ],
      ),
    );
  }

  // ─── Texte ─────────────────────────────────────────────────────────────

  /// Première ligne du header : "Bienvenue" par défaut, OU le sous-titre
  /// fourni par la page (ex: coop affiche "12 actions à traiter").
  String _ligne1() {
    return subtitleOverride ?? 'Bienvenue';
  }

  /// Nom complet du user (ou nom de la coopérative pour le rôle COOP).
  String _nomComplet(Utilisateur? user) {
    final nom = user?.fullName?.trim();
    if (nom != null && nom.isNotEmpty) return nom;
    switch (variant) {
      case HeaderVariant.cooperative:
        return 'Ma coopérative';
      default:
        return 'Utilisateur';
    }
  }

  // ─── Actions à droite ─────────────────────────────────────────────────

  List<Widget> _actionsDroite(BuildContext context) {
    switch (variant) {
      case HeaderVariant.producteur:
        return [
          _IconButton(
            icon: Icons.notifications_none,
            badge: unreadNotifications,
            onTap: () => _openNotifications(context),
          ),
        ];
      case HeaderVariant.acheteur:
        // Panier toujours visible côté acheteur (sorti du bottom nav).
        return [
          _IconButton(
            icon: Icons.shopping_cart_outlined,
            badge: cartCount,
            onTap: () => context.push(RouteNames.acheteurPanierPath),
          ),
          _IconButton(
            icon: Icons.notifications_none,
            badge: unreadNotifications,
            onTap: () => _openNotifications(context),
          ),
        ];
      case HeaderVariant.cooperative:
        return [
          _IconButton(
            icon: Icons.chat_bubble_outline,
            badge: unreadMessages,
            onTap: () => _openMessages(context),
          ),
          _IconButton(
            icon: Icons.notifications_none,
            badge: unreadNotifications,
            onTap: () => _openNotifications(context),
          ),
        ];
      case HeaderVariant.transporteur:
        // Pas d'icône messages : Messages est un onglet du bottom-nav.
        return [
          _IconButton(
            icon: Icons.notifications_none,
            badge: unreadNotifications,
            onTap: () => _openNotifications(context),
          ),
        ];
    }
  }

  // ─── Actions navigation ───────────────────────────────────────────────

  void _openProfile(BuildContext context, UserRole? role) {
    switch (role) {
      case UserRole.farmer:
        context.go(RouteNames.producteurProfilPath);
        break;
      case UserRole.buyer:
        context.go(RouteNames.acheteurProfilPath);
        break;
      case UserRole.cooperative:
        // Pas d'onglet profil côté coop → push d'une route top-level.
        context.push(RouteNames.cooperativeProfilPath);
        break;
      case UserRole.transporter:
        // Tap avatar transporteur → page profil & paramètres (top-level).
        context.push(RouteNames.transporteurProfilSettingsPath);
        break;
      default:
        break;
    }
  }

  void _openMessages(BuildContext context) {
    // La coopérative pousse vers sa page messages top-level.
    if (variant == HeaderVariant.cooperative) {
      context.push(RouteNames.cooperativeMessagesPath);
    }
  }

  void _openNotifications(BuildContext context) {
    switch (variant) {
      case HeaderVariant.producteur:
        context.push(RouteNames.producteurNotificationsPath);
        break;
      case HeaderVariant.acheteur:
        context.push(RouteNames.acheteurNotificationsPath);
        break;
      case HeaderVariant.cooperative:
        context.push(RouteNames.cooperativeNotificationsPath);
        break;
      case HeaderVariant.transporteur:
        context.push(RouteNames.transporteurNotificationsPath);
        break;
    }
  }
}

/// Variante d'affichage du header.
enum HeaderVariant { producteur, acheteur, cooperative, transporteur }

class _AvatarRond extends StatelessWidget {
  const _AvatarRond({required this.user, required this.onTap});

  final Utilisateur? user;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final initials = _initiales(user?.fullName);
    final photoUrl = user?.photoUrl;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: const Color(0xFFE8F5E9),
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.border, width: 1),
          image: photoUrl != null && photoUrl.isNotEmpty
              ? DecorationImage(
                  image: NetworkImage(photoUrl),
                  fit: BoxFit.cover,
                )
              : null,
        ),
        alignment: Alignment.center,
        child: photoUrl != null && photoUrl.isNotEmpty
            ? null
            : Text(
                initials,
                style: AppTextStyles.titleSmall.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
      ),
    );
  }

  String _initiales(String? fullName) {
    if (fullName == null || fullName.trim().isEmpty) return '?';
    final parts = fullName.trim().split(RegExp(r'\s+'));
    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
        .toUpperCase();
  }
}

class _IconButton extends StatelessWidget {
  const _IconButton({
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
