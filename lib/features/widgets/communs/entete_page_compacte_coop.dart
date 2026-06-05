import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../routing/route_names.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_dimens.dart';
import '../../../theme/app_text_styles.dart';
import '../../state/badges_state.dart';
import 'badge_notification.dart';

/// En-tête compact réutilisable côté COOPÉRATIVE — une seule ligne :
///
///   [← Titre                                 💬 🔔]
///
/// Remplace le combo `HeaderUtilisateur` (avatar + « Bienvenue Coop X »)
/// + titre de page sur les sous-pages où l'identité coop n'apporte rien
/// (Membres, Adhésions, etc.). Pas de panier (la coop ne consomme pas
/// le marché côté acheteur) — juste les badges messages + notifications,
/// lus depuis les providers globaux donc cohérents partout dans l'app.
///
/// Symétrique de `EntetePageCompacteAcheteur` — même structure, mêmes
/// dimensions, mêmes badges. Différence : routes coop + pas d'icône
/// panier. Le bouton retour est optionnel via [showBack] : `true` (défaut)
/// sur les pages secondaires hors-shell, `false` sur les onglets du
/// bottom-nav où un back n'a pas de sens.
class EntetePageCompacteCoop extends ConsumerWidget {
  const EntetePageCompacteCoop({
    super.key,
    required this.title,
    this.showBack = true,
  });

  /// Titre affiché. Ex: « Membres », « Marché », « Stock », « Commandes ».
  final String title;

  /// Affiche la flèche retour à gauche. À mettre à `false` sur les
  /// onglets du bottom-nav (Marché/Stock/Commandes) — un onglet n'a
  /// pas de page « précédente » à laquelle revenir.
  final bool showBack;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifCount =
        ref.watch(unreadNotificationsCountProvider).valueOrNull ?? 0;
    final unreadMsg =
        ref.watch(unreadMessagesCountProvider).valueOrNull ?? 0;

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
          if (showBack) ...[
            _IconRond(
              icon: Icons.arrow_back,
              onTap: () => context.canPop()
                  ? context.pop()
                  : context.go(RouteNames.accueilCooperativePath),
            ),
            const SizedBox(width: 4),
          ] else
            // Petit padding gauche aligné sur la grille — sans back le
            // titre serait collé au bord, ça fait moche.
            const SizedBox(width: 8),
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
          _IconRond(
            icon: Icons.chat_bubble_outline_rounded,
            badge: unreadMsg,
            onTap: () => context.push(RouteNames.cooperativeMessagesPath),
          ),
          _IconRond(
            icon: Icons.notifications_none,
            badge: notifCount,
            onTap: () =>
                context.push(RouteNames.cooperativeNotificationsPath),
          ),
        ],
      ),
    );
  }
}

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
