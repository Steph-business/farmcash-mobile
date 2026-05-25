import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';
import 'onglet_marche_publications.dart';

/// Barre d'onglets « Actives / Archivées » du marché coop.
class BarreOngletsMarche extends StatelessWidget {
  const BarreOngletsMarche({
    super.key,
    required this.current,
    required this.activesCount,
    required this.archiveesCount,
    required this.onSelect,
  });

  /// Onglet sélectionné.
  final OngletMarcheCoop current;

  /// Nombre de publications actives.
  final int activesCount;

  /// Nombre de publications archivées.
  final int archiveesCount;

  /// Callback de sélection d'un onglet.
  final ValueChanged<OngletMarcheCoop> onSelect;

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
          _tab(OngletMarcheCoop.actives, 'Actives ($activesCount)'),
          _tab(OngletMarcheCoop.archivees, 'Archivées ($archiveesCount)'),
        ],
      ),
    );
  }

  Widget _tab(OngletMarcheCoop value, String label) {
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
