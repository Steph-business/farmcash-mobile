import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_text_styles.dart';

/// Label de champ de formulaire (12px, semibold, gris) au-dessus
/// d'un widget enfant (typiquement un `TextField` ou un sélecteur).
///
/// Utilisé sur toutes les étapes du wizard parcelle pour uniformiser
/// l'apparence des intitulés de champs.
class ChampLabel extends StatelessWidget {
  const ChampLabel({
    required this.label,
    required this.child,
    super.key,
  });

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 6),
        child,
      ],
    );
  }
}
