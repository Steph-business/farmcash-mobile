import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';

/// Card rouge affichée si la sollicitation ne peut pas être chargée.
///
/// Le producteur peut quand même répondre — on ne bloque pas le
/// formulaire en aval, l'utilisateur conserve la main.
class SollicitationRecapCardError extends StatelessWidget {
  const SollicitationRecapCardError({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFDECEA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.error,
          width: AppDimens.borderThin,
        ),
      ),
      padding: const EdgeInsets.all(14),
      child: Text(
        'Impossible de charger le détail de la sollicitation. '
        'Tu peux quand même répondre.',
        style: AppTextStyles.bodySmall.copyWith(
          fontSize: 12,
          color: AppColors.error,
        ),
      ),
    );
  }
}
