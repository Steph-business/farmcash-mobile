import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';
import 'commandes_list_constants.dart';

/// Barre d'onglets "En cours / Livrées / Annulées" pour la liste des
/// commandes producteur. Affiche un compteur à côté de "En cours".
class OngletsCommandes extends StatelessWidget {
  const OngletsCommandes({
    super.key,
    required this.current,
    required this.enCoursCount,
    required this.onSelect,
  });

  final OrderTab current;
  final int enCoursCount;
  final ValueChanged<OrderTab> onSelect;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppDimens.pagePaddingH),
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
          _tab(OrderTab.enCours, 'En cours ($enCoursCount)'),
          _tab(OrderTab.livrees, 'Livrées'),
          _tab(OrderTab.annulees, 'Annulées'),
        ],
      ),
    );
  }

  Widget _tab(OrderTab value, String label) {
    final active = value == current;
    return Expanded(
      child: InkWell(
        onTap: () => onSelect(value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: active ? AppColors.primary : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: AppTextStyles.labelMedium.copyWith(
              fontSize: 13,
              fontWeight: active ? FontWeight.w600 : FontWeight.w500,
              color: active ? AppColors.primary : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}
