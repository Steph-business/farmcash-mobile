import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_dimens.dart';
import '../../../theme/app_text_styles.dart';

/// Bottom navigation custom qui supporte un bouton central (FAB-like)
/// optionnel. Pas d'ombre. Conforme DESIGN.md.
///
/// Si [centralButton] est fourni, il prend la place de l'index `length~/2`
/// dans la barre visuelle. Le `currentIndex` ignore alors ce slot.
///
/// Exemple sans FAB (5 onglets égaux) :
/// ```dart
/// BarreNavigation(
///   items: [...],
///   currentIndex: 0,
///   onTap: (i) => ...,
/// );
/// ```
///
/// Exemple avec FAB central :
/// ```dart
/// BarreNavigation(
///   items: [...4 items...],
///   currentIndex: 0,
///   onTap: (i) => ...,
///   centralButton: BoutonAjoutCentral(onTap: () => ...),
/// );
/// ```
class BarreNavigation extends StatelessWidget {
  const BarreNavigation({
    required this.items,
    required this.currentIndex,
    required this.onTap,
    this.centralButton,
    super.key,
  });

  final List<ItemNavigation> items;

  /// Index 0..N-1 dans la liste `items` (pas la position visuelle).
  final int currentIndex;

  /// Callback appelé avec l'index `items[i]` choisi.
  final ValueChanged<int> onTap;

  /// Si fourni, posé entre la moitié des items. La barre visuelle compte
  /// alors `items.length + 1` slots.
  final Widget? centralButton;

  @override
  Widget build(BuildContext context) {
    final hasCentral = centralButton != null;
    final visualSlots = items.length + (hasCentral ? 1 : 0);
    final centralVisualIndex = hasCentral ? visualSlots ~/ 2 : -1;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(
          top: BorderSide(color: AppColors.border, width: 1),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            children: List.generate(visualSlots, (visualIndex) {
              if (visualIndex == centralVisualIndex) {
                return Expanded(
                  child: Center(child: centralButton),
                );
              }
              final itemIndex = hasCentral && visualIndex > centralVisualIndex
                  ? visualIndex - 1
                  : visualIndex;
              return Expanded(
                child: _NavItemTile(
                  item: items[itemIndex],
                  selected: currentIndex == itemIndex,
                  onTap: () => onTap(itemIndex),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class ItemNavigation {
  const ItemNavigation({
    required this.label,
    required this.icon,
    this.iconSelected,
    this.badge = 0,
  });

  final String label;
  final IconData icon;
  final IconData? iconSelected;
  final int badge;
}

class _NavItemTile extends StatelessWidget {
  const _NavItemTile({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final ItemNavigation item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.primary : AppColors.textSecondary;
    final icon = selected ? (item.iconSelected ?? item.icon) : item.icon;

    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(icon, color: color, size: AppDimens.iconL),
              if (item.badge > 0)
                Positioned(
                  right: -6,
                  top: -3,
                  child: Container(
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 1,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.error,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppColors.background,
                        width: 1.5,
                      ),
                    ),
                    child: Text(
                      item.badge > 99 ? '99+' : '${item.badge}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AppColors.onError,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        height: 1.1,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            item.label,
            style: AppTextStyles.labelSmall.copyWith(
              color: color,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
