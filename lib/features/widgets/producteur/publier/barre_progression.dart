import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';

/// Barre de progression segmentée du wizard de publication d'annonce.
///
/// Affiche [total] segments dont les [index] + 1 premiers sont colorés
/// en vert primaire pour matérialiser l'étape courante.
class BarreProgression extends StatelessWidget {
  const BarreProgression({super.key, required this.index, required this.total});

  final int index;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppDimens.pagePaddingH,
        AppDimens.space4,
        AppDimens.pagePaddingH,
        AppDimens.space8,
      ),
      child: Row(
        children: List.generate(total, (i) {
          final actif = i <= index;
          return Expanded(
            child: Container(
              margin: EdgeInsets.only(right: i == total - 1 ? 0 : 6),
              height: 4,
              decoration: BoxDecoration(
                color: actif ? AppColors.primary : AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }),
      ),
    );
  }
}
