import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';

/// Barre sticky bas avec bouton "Convertir maintenant". Le bouton peut être
/// désactivé (opacité réduite, onTap inerte) avec un sous-titre explicatif
/// (ex. "Disponible à partir du …") pour ne pas frustrer le farmer.
class StickyConvertir extends StatelessWidget {
  const StickyConvertir({
    required this.enabled,
    required this.onConvertir,
    this.subtitle,
    super.key,
  });

  final bool enabled;
  final VoidCallback onConvertir;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(
          top: BorderSide(
            color: AppColors.border,
            width: AppDimens.borderThin,
          ),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Opacity(
            opacity: enabled ? 1 : 0.5,
            child: InkWell(
              onTap: enabled ? onConvertir : null,
              borderRadius: AppDimens.brButton,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 13),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: AppDimens.brButton,
                  border: Border.all(
                    color: AppColors.primary,
                    width: AppDimens.borderThin,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  'Convertir maintenant',
                  style: AppTextStyles.button.copyWith(
                    fontSize: 14,
                    color: AppColors.onPrimary,
                  ),
                ),
              ),
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 6),
            Text(
              subtitle!,
              style: AppTextStyles.labelSmall.copyWith(
                fontSize: 11,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}
