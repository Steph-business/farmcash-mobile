import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../routing/route_names.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_dimens.dart';
import '../../../theme/app_text_styles.dart';
import '../../state/badges_state.dart';
import 'badge_notification.dart';

/// En-tête compact réutilisable côté acheteur — une seule ligne :
///
///   [← Titre                                 🛒 🔔]
///
/// Remplace le combo `HeaderUtilisateur` (avatar + « Bienvenue X »)
/// + `TitrePage` sur les pages où l'identité utilisateur n'apporte rien
/// (Commandes, Messages, …). Le titre est paramétrable ; les badges
/// panier / notifications sont lus depuis les providers globaux donc
/// restent cohérents avec le reste de l'app.
class EntetePageCompacteAcheteur extends ConsumerWidget {
  const EntetePageCompacteAcheteur({
    required this.title,
    super.key,
  });

  /// Titre affiché à droite du back. Ex: « Commandes », « Messages ».
  final String title;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartCount = ref.watch(cartCountProvider).valueOrNull ?? 0;
    final notifCount =
        ref.watch(unreadNotificationsCountProvider).valueOrNull ?? 0;

    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppDimens.space8,
        AppDimens.space8,
        AppDimens.space8,
        AppDimens.space8,
      ),
      color: AppColors.background,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ── Back ────────────────────────────────────────────────────
          // La page est un onglet du shell ; on ramène à l'accueil
          // acheteur (équivalent à appuyer sur l'onglet « Accueil »).
          _IconRond(
            icon: Icons.arrow_back,
            onTap: () => context.go(RouteNames.accueilAcheteurPath),
          ),
          const SizedBox(width: 4),
          // ── Titre ───────────────────────────────────────────────────
          Expanded(
            child: Text(
              title,
              style: AppTextStyles.titleMedium.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.text,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          // ── Actions droite ──────────────────────────────────────────
          _IconRond(
            icon: Icons.shopping_cart_outlined,
            badge: cartCount,
            onTap: () => context.push(RouteNames.acheteurPanierPath),
          ),
          _IconRond(
            icon: Icons.notifications_none,
            badge: notifCount,
            onTap: () =>
                context.push(RouteNames.acheteurNotificationsPath),
          ),
        ],
      ),
    );
  }
}

/// Bouton icône arrondi avec pastille optionnelle. Aligné sur le style du
/// `HeaderUtilisateur` pour cohérence visuelle entre les pages.
class _IconRond extends StatelessWidget {
  const _IconRond({required this.icon, required this.onTap, this.badge = 0});

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
