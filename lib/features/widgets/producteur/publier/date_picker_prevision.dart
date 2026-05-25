import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';

/// Champ « date de recolte prevue » : tap → ouvre le picker, bouton X
/// pour effacer la valeur. Format affiche : « d MMM y » en fr_FR.
class DatePickerPrevision extends StatelessWidget {
  const DatePickerPrevision({
    required this.value,
    required this.enabled,
    required this.onTap,
    required this.onClear,
    super.key,
  });

  final DateTime? value;
  final bool enabled;
  final VoidCallback onTap;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final label = value != null
        ? DateFormat('d MMM y', 'fr_FR').format(value!)
        : 'Choisir une date';
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: AppColors.border,
            width: AppDimens.borderThin,
          ),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.calendar_today_outlined,
              size: 18,
              color: AppColors.textSecondary,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontSize: 14,
                  color: value != null
                      ? AppColors.text
                      : AppColors.textSubtle,
                ),
              ),
            ),
            if (value != null && enabled)
              InkWell(
                onTap: onClear,
                borderRadius: BorderRadius.circular(16),
                child: const Padding(
                  padding: EdgeInsets.all(4),
                  child: Icon(
                    Icons.close,
                    size: 16,
                    color: AppColors.textSubtle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
