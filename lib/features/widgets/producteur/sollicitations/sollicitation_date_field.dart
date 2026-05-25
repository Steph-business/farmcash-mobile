import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';
import 'sollicitation_field_label.dart';

/// Sélecteur de date estimée (utilisé quand le producteur choisit
/// "Plus tard" comme date de livraison).
///
/// Affiche un label "Date estimée" + une zone cliquable montrant la
/// date au format dd/MM/yyyy, ou "Choisir une date" si vide.
class SollicitationDateField extends StatelessWidget {
  const SollicitationDateField({
    required this.date,
    required this.onTap,
    required this.enabled,
    super.key,
  });

  final DateTime? date;
  final VoidCallback onTap;
  final bool enabled;

  String _format(DateTime d) {
    final dd = d.day.toString().padLeft(2, '0');
    final mm = d.month.toString().padLeft(2, '0');
    return '$dd/$mm/${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SollicitationFieldLabel(label: 'Date estimée'),
        AppDimens.vGap8,
        InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(12),
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
                const Icon(
                  Icons.calendar_today_outlined,
                  size: AppDimens.iconM,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    date != null ? _format(date!) : 'Choisir une date',
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontSize: 14,
                      color: date != null
                          ? AppColors.text
                          : AppColors.textSubtle,
                    ),
                  ),
                ),
                const Icon(
                  Icons.keyboard_arrow_down,
                  size: AppDimens.iconM,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
