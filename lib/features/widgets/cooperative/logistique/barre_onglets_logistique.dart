import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';
import 'onglet_logistique.dart';

/// Barre des deux onglets de la page Logistique coop : "Parc vehicules" et
/// "Collectes". L'onglet actif a un soulignement primaire et un libelle
/// en couleur primaire.
class BarreOngletsLogistique extends StatelessWidget {
  const BarreOngletsLogistique({
    required this.current,
    required this.parcCount,
    required this.collectesCount,
    required this.onSelect,
    super.key,
  });

  final OngletLogistique current;
  final int parcCount;
  final int collectesCount;
  final ValueChanged<OngletLogistique> onSelect;

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
          _tab(OngletLogistique.parc, 'Parc véhicules ($parcCount)'),
          const SizedBox(width: 18),
          _tab(OngletLogistique.collectes, 'Collectes ($collectesCount)'),
        ],
      ),
    );
  }

  Widget _tab(OngletLogistique value, String label) {
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
