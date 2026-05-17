import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'barre_navigation.dart';

/// Wrapper générique d'un Shell go_router : pose la `BarreNavigation` en
/// bas, le contenu de l'onglet sélectionné dans le body via le
/// `StatefulNavigationShell`, et un `centralButton` optionnel.
///
/// Le shell délègue la sélection d'onglet à `navigationShell.goBranch(i)`
/// pour conserver l'état (lazy loading, scroll position) de chaque branche.
class ShellLayout extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: BarreNavigation(
        items: items,
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
