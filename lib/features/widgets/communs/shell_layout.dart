import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../state/badges_state.dart';
import 'barre_navigation.dart';

/// Wrapper générique d'un Shell go_router : pose la `BarreNavigation` en
/// bas, le contenu de l'onglet sélectionné dans le body via le
/// `StatefulNavigationShell`, et un `centralButton` optionnel.
///
/// Le shell délègue la sélection d'onglet à `navigationShell.goBranch(i)`
/// pour conserver l'état (lazy loading, scroll position) de chaque branche.
///
/// **Badges dynamiques** : on `watch` les providers globaux
/// (`unreadMessagesCountProvider`, `unreadNotificationsCountProvider`,
/// `cartCountProvider`) et on injecte le `badge` correspondant sur chaque
/// item dont le `label` matche. Comme ça pas besoin que chaque rôle
/// (producteur/acheteur/coop/transporteur) re-implémente la logique de
/// badge dans son bottom nav.
class ShellLayout extends ConsumerWidget {
  const ShellLayout({
    required this.navigationShell,
    required this.items,
    this.centralButton,
    super.key,
  });

  /// Reçu du `StatefulShellRoute.indexedStack` builder.
  final StatefulNavigationShell navigationShell;

  /// Items de la bottom nav (4 ou 5 selon la présence d'un FAB).
  final List<ItemNavigation> items;

  /// FAB central optionnel.
  final Widget? centralButton;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Badges globaux. `valueOrNull` retourne la valeur courante ou null
    // pendant le chargement initial — on substitue 0 dans ce cas.
    final msgsBadge = ref.watch(unreadMessagesCountProvider).valueOrNull ?? 0;
    final notifsBadge =
        ref.watch(unreadNotificationsCountProvider).valueOrNull ?? 0;
    final cartBadge = ref.watch(cartCountProvider).valueOrNull ?? 0;

    // On clone la liste d'items en injectant le badge correspondant
    // selon le label. Simple et type-safe — pas besoin d'enum custom.
    final itemsAvecBadge = items.map((item) {
      final label = item.label.toLowerCase();
      int badge = item.badge;
      if (label == 'messages') {
        badge = msgsBadge;
      } else if (label == 'notifications') {
        badge = notifsBadge;
      } else if (label == 'panier') {
        badge = cartBadge;
      }
      return ItemNavigation(
        label: item.label,
        icon: item.icon,
        iconSelected: item.iconSelected,
        badge: badge,
      );
    }).toList();

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: BarreNavigation(
        items: itemsAvecBadge,
        currentIndex: navigationShell.currentIndex,
        onTap: (i) => navigationShell.goBranch(
          i,
          initialLocation: i == navigationShell.currentIndex,
        ),
        centralButton: centralButton,
      ),
    );
  }
}
