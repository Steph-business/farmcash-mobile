import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_dimens.dart';
import '../../../theme/app_text_styles.dart';

/// Carte cliquable de sélection de rôle.
///
/// Visuel sobre : fond blanc, bordure 1px grise au repos, bordure verte
/// 1px à l'état sélectionné. Aucun fond coloré, aucune ombre.
class CarteRole extends StatelessWidget {
  const CarteRole({
    required this.title,
    required this.description,
    required this.icon,
    required this.selected,
    required this.onTap,
    super.key,
  });

  final String title;
  final String description;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final borderColor =
        selected ? AppColors.primary : AppColors.border;

    return Material(
      color: AppColors.surface,
      borderRadius: AppDimens.brCard,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppDimens.brCard,
        child: Ink(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: AppDimens.brCard,
            border: Border.all(
              color: borderColor,
              width: AppDimens.borderThin,
            ),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimens.space16,
            vertical: AppDimens.space16,
          ),
          child: Row(
            children: [
              _IconeRonde(icon: icon),
              AppDimens.hGap16,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.titleMedium,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      description,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              AppDimens.hGap8,
              const Icon(
                Icons.chevron_right,
                size: 20,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _IconeRonde extends StatelessWidget {
  const _IconeRonde({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: AppColors.surface,
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.border,
          width: AppDimens.borderThin,
        ),
      ),
      alignment: Alignment.center,
      child: Icon(
        icon,
        size: 20,
        color: AppColors.textSecondary,
      ),
    );
  }
}
