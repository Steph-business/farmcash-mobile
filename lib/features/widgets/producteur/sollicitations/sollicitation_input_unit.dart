import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';

/// Champ numérique avec unité suffixée (ex. "kg", "F / kg").
///
/// Variante sollicitation : bordure 12 px arrondie et hint optionnel.
class SollicitationInputUnit extends StatelessWidget {
  const SollicitationInputUnit({
    required this.controller,
    required this.unit,
    required this.enabled,
    this.hint,
    this.keyboardType,
    this.formatters,
    super.key,
  });

  final TextEditingController controller;
  final String unit;
  final bool enabled;
  final String? hint;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? formatters;

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
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              enabled: enabled,
              keyboardType: keyboardType,
              inputFormatters: formatters,
              textAlignVertical: TextAlignVertical.center,
              style: AppTextStyles.bodyMedium.copyWith(
                fontSize: 14,
                color: AppColors.text,
              ),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: AppTextStyles.bodyMedium.copyWith(
                  fontSize: 14,
                  color: AppColors.textSubtle,
                ),
                border: InputBorder.none,
                focusedBorder: InputBorder.none,
                enabledBorder: InputBorder.none,
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 12),
                isDense: true,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            unit,
            style: AppTextStyles.bodyMedium.copyWith(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
