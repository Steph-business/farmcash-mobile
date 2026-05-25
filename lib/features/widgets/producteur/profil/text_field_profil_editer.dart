import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';

/// Champ texte stylise de la page edition du profil producteur. Supporte
/// validation, etat disabled (champ telephone) et helperText.
class TextFieldProfilEditer extends StatelessWidget {
  const TextFieldProfilEditer({
    required this.controller,
    required this.hint,
    this.keyboardType,
    this.validator,
    this.enabled = true,
    this.helperText,
    super.key,
  });

  final TextEditingController controller;
  final String hint;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final bool enabled;
  final String? helperText;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      enabled: enabled,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.textSubtle,
        ),
        helperText: helperText,
        helperStyle: AppTextStyles.labelSmall.copyWith(
          fontSize: 11,
          color: AppColors.textSubtle,
        ),
        filled: true,
        fillColor: enabled ? AppColors.surface : AppColors.surfaceSoft,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: AppDimens.brInput,
          borderSide: const BorderSide(
            color: AppColors.border,
            width: AppDimens.borderThin,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppDimens.brInput,
          borderSide: const BorderSide(
            color: AppColors.border,
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
    );
  }
}
