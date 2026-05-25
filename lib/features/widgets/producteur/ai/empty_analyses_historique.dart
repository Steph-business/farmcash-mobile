import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';

/// Etat vide de l'historique des analyses : icone eco + message + sous-titre.
class EmptyAnalysesHistorique extends StatelessWidget {
  const EmptyAnalysesHistorique({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimens.space24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.eco_outlined,
              size: 40,
              color: AppColors.textSubtle.withValues(alpha: 0.9),
            ),
            const SizedBox(height: AppDimens.space12),
            Text(
              "Tu n'as pas encore lancé d'analyse",
              style: AppTextStyles.titleSmall,
            ),
            AppDimens.vGap4,
            Text(
              'Reviens ici une fois que tu auras diagnostiqué une plante.',
              style: AppTextStyles.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
