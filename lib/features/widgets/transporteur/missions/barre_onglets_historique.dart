import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';
import 'onglet_historique.dart';

/// Barre d'onglets segmentée pour la page d'historique : Livrées /
/// Annulées avec compteur. L'onglet sélectionné est souligné en vert.
class BarreOngletsHistorique extends StatelessWidget {
  const BarreOngletsHistorique({
    required this.current,
    required this.livreesCount,
    required this.annuleesCount,
    required this.onSelect,
    super.key,
  });

  final OngletHistorique current;
  final int livreesCount;
  final int annuleesCount;
  final ValueChanged<OngletHistorique> onSelect;

  @override
  Widget build(BuildContext context) {
    return Container(
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
          _onglet(OngletHistorique.livrees, 'Livrées ($livreesCount)'),
          const SizedBox(width: 18),
          _onglet(OngletHistorique.annulees, 'Annulées ($annuleesCount)'),
        ],
      ),
    );
  }

  Widget _onglet(OngletHistorique value, String label) {
    final active = value == current;
    return InkWell(
      onTap: () => onSelect(value),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: active ? AppColors.primary : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.labelMedium.copyWith(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: active ? AppColors.primary : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
