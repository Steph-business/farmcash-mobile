import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';

const List<String> _kFiltres = [
  'Bio',
  'Près de moi',
  'Prix bas',
  'Coop',
  '+ Filtres',
];

/// Liste horizontale de filtres secondaires (Bio, Près de moi, etc.).
/// Affichage purement décoratif pour le moment : les filtres ne sont
/// pas encore reliés au backend (TODO côté API marché).
class FiltresSecondairesMarche extends StatelessWidget {
  const FiltresSecondairesMarche({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 30,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: _kFiltres.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: AppColors.surfaceSoft,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: AppColors.border,
                width: AppDimens.borderThin,
              ),
            ),
            child: Text(
              _kFiltres[i],
              style: AppTextStyles.labelMedium.copyWith(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.text,
              ),
            ),
          );
        },
      ),
    );
  }
}
