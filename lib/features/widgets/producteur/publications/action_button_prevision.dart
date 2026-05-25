import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';

/// Variantes visuelles des boutons d'actions disponibles sur la page détail
/// prévision : vert (action principale, ex. modifier date) ou gris (action
/// neutre / destructive secondaire, ex. annuler prévision).
enum ActionVariantPrevision { outlineGreen, outlineGrey }

/// Bouton outline plein largeur utilisé dans la section "Actions" du détail
/// prévision. Icône à gauche + label centré. Le `Opacity` est appliqué par
/// le parent pour matérialiser l'état désactivé.
class ActionButtonPrevision extends StatelessWidget {
  const ActionButtonPrevision({
    required this.icon,
    required this.label,
    required this.variant,
    required this.onTap,
    super.key,
  });

  final IconData icon;
  final String label;
  final ActionVariantPrevision variant;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isGreen = variant == ActionVariantPrevision.outlineGreen;
    return InkWell(
      onTap: onTap,
      borderRadius: AppDimens.brButton,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 12),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: AppDimens.brButton,
          border: Border.all(
            color: isGreen ? AppColors.primary : AppColors.border,
            width: AppDimens.borderThin,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: AppDimens.iconM,
              color: isGreen ? AppColors.primary : AppColors.textSecondary,
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                label,
                style: AppTextStyles.button.copyWith(
                  fontSize: 14,
                  color:
                      isGreen ? AppColors.primary : AppColors.textSecondary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
