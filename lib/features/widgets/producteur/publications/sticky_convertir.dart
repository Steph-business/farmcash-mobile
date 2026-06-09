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
      decoration: BoxDecoration(
        color: AppColors.background,
        // Shadow soft top → effet plateau flottant qui décolle le sticky du
        // contenu scrollable au-dessus.
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
        border: const Border(
          top: BorderSide(
            color: AppColors.border,
            width: AppDimens.borderThin,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        minimum: const EdgeInsets.only(bottom: 8),
        child: Padding(
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
        ),
      ),
    );
  }
}
