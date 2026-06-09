import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';

/// Onglets de premier niveau de la page « Stock » coopérative.
///
/// Deux vues complémentaires sur la même marchandise :
///   • [inventaire]   — lots physiques en entrepôt (qté, qualité, lieu)
///   • [publications] — lots mis en vente sur le marché (qté restante,
///                      prix, statut)
enum OngletStockCoop { inventaire, publications }

/// Barre 2-segments sous le header — style aligné sur les autres
/// toggles cross-acteurs (commandes, mes publications producteur).
class OngletsStockCoop extends StatelessWidget {
  const OngletsStockCoop({
    super.key,
    required this.current,
    required this.onSelect,
    this.publicationsBadge = 0,
  });

  final OngletStockCoop current;
  final ValueChanged<OngletStockCoop> onSelect;

  /// Petite pastille sur Publications (ex. publications actives).
  final int publicationsBadge;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppColors.border,
            width: AppDimens.borderThin,
          ),
        ),
      ),
      child: Row(
        children: [
          _tab(OngletStockCoop.inventaire, 'Inventaire'),
          _tab(
            OngletStockCoop.publications,
            'Publications',
            badge: publicationsBadge,
          ),
        ],
      ),
    );
  }

  Widget _tab(OngletStockCoop value, String label, {int badge = 0}) {
    final active = value == current;
    return Expanded(
      child: InkWell(
        onTap: () => onSelect(value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: active ? AppColors.primary : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          alignment: Alignment.center,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: AppTextStyles.button.copyWith(
                  fontSize: 13.5,
                  fontWeight: active ? FontWeight.w800 : FontWeight.w600,
                  color: active ? AppColors.text : AppColors.textSecondary,
                ),
              ),
              if (badge > 0) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 1,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '$badge',
                    style: AppTextStyles.labelSmall.copyWith(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
