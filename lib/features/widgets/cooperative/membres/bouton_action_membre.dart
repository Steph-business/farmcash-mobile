import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';

/// Bouton d'action contextuelle (Appeler / Message) sur la fiche membre.
class BoutonActionMembre extends StatelessWidget {
  const BoutonActionMembre({
    super.key,
    required this.icon,
    required this.label,
    required this.filled,
    required this.onTap,
  });

  /// Icône affichée à gauche du libellé.
  final IconData icon;

  /// Libellé du bouton.
  final String label;

  /// Vrai pour un bouton plein (primary), faux pour outline.
  final bool filled;

  /// Action déclenchée au tap.
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final fg = filled ? AppColors.onPrimary : AppColors.text;
    final bg = filled ? AppColors.primary : AppColors.background;
    final border = filled ? AppColors.primary : AppColors.border;

    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: border, width: AppDimens.borderThin),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: fg),
              const SizedBox(width: 6),
              Text(
                label,
                style: AppTextStyles.labelMedium.copyWith(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: fg,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
