import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';
import 'publier_demande_constants.dart';

/// Dropdown utilisé quand la cible est "Une coopérative spécifique" — propose
/// le catalogue local `kPublierDemandeCoops`.
class DropdownCoopDemande extends StatelessWidget {
  const DropdownCoopDemande({
    required this.value,
    required this.onChange,
    super.key,
  });

  final PublierDemandeCoopOption? value;
  final ValueChanged<PublierDemandeCoopOption?> onChange;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.border,
          width: AppDimens.borderThin,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<PublierDemandeCoopOption>(
          isExpanded: true,
          value: value,
          hint: Text(
            'Choisir une coopérative',
            style: AppTextStyles.bodyMedium.copyWith(
              fontSize: 13,
              color: AppColors.textSubtle,
            ),
          ),
          items: [
            for (final c in kPublierDemandeCoops)
              DropdownMenuItem(
                value: c,
                child: Text(
                  c.nom,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontSize: 13,
                    color: AppColors.text,
                  ),
                ),
              ),
          ],
          onChanged: onChange,
        ),
      ),
    );
  }
}
