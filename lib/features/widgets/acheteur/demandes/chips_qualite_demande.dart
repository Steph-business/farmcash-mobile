import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';
import 'publier_demande_constants.dart';

/// Chips de sélection de qualité (Standard / Premium / Bio / Équitable).
class ChipsQualiteDemande extends StatelessWidget {
  const ChipsQualiteDemande({
    required this.selected,
    required this.onChange,
    super.key,
  });

  final String selected;
  final ValueChanged<String> onChange;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final q in kPublierDemandeQualites)
          InkWell(
            onTap: () => onChange(q),
            borderRadius: BorderRadius.circular(14),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color:
                    q == selected ? AppColors.primary : AppColors.background,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: q == selected ? AppColors.primary : AppColors.border,
                  width: AppDimens.borderThin,
                ),
              ),
              child: Text(
                q,
                style: AppTextStyles.labelMedium.copyWith(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: q == selected
                      ? AppColors.onPrimary
                      : AppColors.textSecondary,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
