import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_dimens.dart';
import '../../../theme/app_text_styles.dart';

/// Bouton primaire plat, vert, radius 10, sans ombre.
///
/// Affiche un spinner blanc quand [isLoading] est vrai, et désactive
/// automatiquement les interactions.
class BoutonPrincipal extends StatelessWidget {
  const BoutonPrincipal({
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.enabled = true,
    this.icon,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool enabled;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final disabled = !enabled || isLoading || onPressed == null;

    // Style explicite pour ne PAS dépendre du theme : on a constaté des
    // boutons "trop clairs" sur certains écrans car le theme override
    // peut ne pas s'appliquer (custom Container, parent qui force un
    // ColorScheme local, etc.). Ici on garantit visuellement :
    //   • fond vert primary saturé (#2E7D32)
    //   • texte blanc pur, fontWeight 700 (plus gras qu'avant)
    //   • aucun "tint" Material qui blanchirait le fond
    return SizedBox(
      height: AppDimens.buttonHeight,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: disabled ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          disabledBackgroundColor: AppColors.borderStrong,
          disabledForegroundColor: AppColors.textSubtle,
          shadowColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          padding: AppDimens.paddingButton,
          shape: const RoundedRectangleBorder(
            borderRadius: AppDimens.brButton,
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2.2,
                  color: AppColors.onPrimary,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: AppDimens.iconM),
                    AppDimens.hGap8,
                  ],
                  Text(
                    label,
                    style: AppTextStyles.button.copyWith(
                      // Override explicite : on a vu des cas où le
                      // foregroundColor du ElevatedButton n'arrivait pas
                      // jusqu'au Text (ex: parent qui injecte un
                      // DefaultTextStyle). On force ici en clair.
                      color: AppColors.onPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
