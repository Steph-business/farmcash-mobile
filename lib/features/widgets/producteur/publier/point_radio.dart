import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';

/// Point radio circulaire (20 x 20) utilisé pour les sélections du
/// wizard de publication (carte culture, audience…).
///
/// Coché quand [selected] est vrai : bordure verte primaire +
/// pastille pleine au centre.
class PointRadio extends StatelessWidget {
  const PointRadio({super.key, required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: selected ? AppColors.primary : AppColors.borderStrong,
          width: 1.5,
        ),
      ),
      child: selected
          ? Center(
              child: Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
            )
          : null,
    );
  }
}
