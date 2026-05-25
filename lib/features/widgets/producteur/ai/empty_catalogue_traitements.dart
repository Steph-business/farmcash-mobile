import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';

/// Etat vide pour le catalogue traitements.
///
/// Icone science + message + indication d'ajuster les filtres. Centre,
/// padding 24 px.
class EmptyCatalogueTraitements extends StatelessWidget {
  const EmptyCatalogueTraitements({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimens.space24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.science_outlined,
              size: 40,
              color: AppColors.textSubtle.withValues(alpha: 0.9),
            ),
            const SizedBox(height: AppDimens.space12),
            Text(
              'Aucun traitement trouvé',
              style: AppTextStyles.titleSmall,
            ),
            AppDimens.vGap4,
            Text(
              'Modifie les filtres ou la recherche pour voir plus de résultats.',
              style: AppTextStyles.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
