import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';

/// Champ de saisie d'un tarif monétaire (F CFA) — label en haut, valeur
/// stylisée gras au centre, suffix devise, helper texte en bas.
class ChampTarif extends StatelessWidget {
  /// Construit le champ tarif.
  const ChampTarif({
    super.key,
    required this.label,
    required this.controller,
    required this.helper,
    this.suffixDevise = 'F',
  });

  /// Libellé affiché au-dessus.
  final String label;

  /// Controller du champ.
  final TextEditingController controller;

  /// Texte d'aide en petit dessous.
  final String helper;

  /// Suffix devise (par défaut "F" pour FCFA).
  final String suffixDevise;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.labelMedium.copyWith(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AppColors.text,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(
            decimal: false,
          ),
          style: AppTextStyles.titleMedium.copyWith(
            fontWeight: FontWeight.w800,
            color: AppColors.text,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.background,
            suffixText: suffixDevise,
            suffixStyle: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppDimens.space16,
              vertical: 14,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: AppDimens.brInput,
              borderSide: BorderSide(
                color: AppColors.borderStrong,
                width: AppDimens.borderThin,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: AppDimens.brInput,
              borderSide: const BorderSide(
                color: AppColors.primary,
                width: AppDimens.borderMedium,
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          helper,
          style: AppTextStyles.bodySmall.copyWith(
            fontSize: 11,
            color: AppColors.textSubtle,
          ),
        ),
      ],
    );
  }
}
