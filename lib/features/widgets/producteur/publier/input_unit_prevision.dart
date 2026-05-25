import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_text_styles.dart';

/// Champ texte numerique avec suffixe d'unite (« kg », « F / kg »).
///
/// Le clavier est configurable via `keyboardType` et les chiffres-only
/// via `formatters`. `onChanged` est optionnel : la page mere s'en sert
/// pour re-evaluer si le bouton submit peut etre actif.
class InputUnitPrevision extends StatelessWidget {
  const InputUnitPrevision({
    required this.controller,
    required this.unit,
    required this.enabled,
    this.keyboardType,
    this.formatters,
    this.onChanged,
    super.key,
  });

  final TextEditingController controller;
  final String unit;
  final bool enabled;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? formatters;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      enabled: enabled,
      keyboardType: keyboardType,
      inputFormatters: formatters,
      onChanged: onChanged,
      style: AppTextStyles.bodyMedium.copyWith(fontSize: 14),
      decoration: InputDecoration(
        suffix: Text(
          unit,
          style: AppTextStyles.bodySmall.copyWith(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
    );
  }
}
