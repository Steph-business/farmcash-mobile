import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_text_styles.dart';

/// Sous-titre récap : "X offre(s) en attente" / "Aucune offre en attente".
class SousTitreOffres extends StatelessWidget {
  const SousTitreOffres({super.key, required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 4),
      child: Text(
        count == 0
            ? 'Aucune offre en attente'
            : '$count offre${count > 1 ? 's' : ''} en attente',
        style: AppTextStyles.bodySmall.copyWith(
          fontSize: 13,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}
