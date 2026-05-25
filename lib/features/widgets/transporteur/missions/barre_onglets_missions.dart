import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';
import 'mission_tab.dart';

/// Barre d'onglets de la liste des missions transporteur : En cours,
/// Disponibles, Terminées — avec compteurs et soulignement vert sur
/// l'onglet actif.
class BarreOngletsMissions extends StatelessWidget {
  const BarreOngletsMissions({
    super.key,
    required this.current,
    required this.enCoursCount,
    required this.disponiblesCount,
    required this.terminees,
    required this.onSelect,
  });

  final MissionTab current;
  final int enCoursCount;
  final int disponiblesCount;
  final int terminees;
  final ValueChanged<MissionTab> onSelect;

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
          _onglet(MissionTab.enCours, 'En cours ($enCoursCount)'),
          const SizedBox(width: 18),
          _onglet(MissionTab.disponibles, 'Disponibles ($disponiblesCount)'),
          const SizedBox(width: 18),
          _onglet(MissionTab.terminees, 'Terminées ($terminees)'),
        ],
      ),
    );
  }

  Widget _onglet(MissionTab value, String label) {
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
