import 'package:flutter/material.dart';

import '../../../../models/parcelle.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';

/// Dropdown pour rattacher l'analyse à une parcelle existante (optionnel).
/// Si l'utilisateur n'a pas encore de parcelle, le dropdown est désactivé
/// avec un hint explicite.
class ParcelleDropdown extends StatelessWidget {
  const ParcelleDropdown({
    required this.value,
    required this.parcelles,
    required this.onChanged,
    super.key,
  });

  final String? value;
  final List<Parcelle> parcelles;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppDimens.inputHeight,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppDimens.brInput,
        border: Border.all(
          color: AppColors.borderStrong,
          width: AppDimens.borderThin,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String?>(
          value: value,
          isExpanded: true,
          hint: Text(
            parcelles.isEmpty
                ? 'Aucune parcelle enregistrée'
                : 'Sélectionner une parcelle',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSubtle,
            ),
          ),
          icon: const Icon(
            Icons.keyboard_arrow_down,
            color: AppColors.textSecondary,
          ),
          items: [
            const DropdownMenuItem<String?>(
              value: null,
              child: Text('Aucune parcelle'),
            ),
            ...parcelles.map(
              (p) => DropdownMenuItem<String?>(
                value: p.id,
                child: Text(
                  p.nom,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
          onChanged: parcelles.isEmpty ? null : onChanged,
        ),
      ),
    );
  }
}
