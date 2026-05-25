import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';

/// Récapitulatif court du stock total + nombre d'entrepôts.
class ResumeStock extends StatelessWidget {
  const ResumeStock({
    super.key,
    required this.stockLabel,
    required this.nbEntrepots,
  });

  /// Libellé déjà formaté du stock total (ex. « 5.0 t stockées »).
  final String stockLabel;

  /// Nombre d'entrepôts associés.
  final int nbEntrepots;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppDimens.pagePaddingH,
        0,
        AppDimens.pagePaddingH,
        AppDimens.space12,
      ),
      child: RichText(
        text: TextSpan(
          style: AppTextStyles.bodySmall.copyWith(
            fontSize: 13,
            color: AppColors.textSecondary,
          ),
          children: [
            TextSpan(
              text: stockLabel,
              style: AppTextStyles.bodySmall.copyWith(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.text,
              ),
            ),
            TextSpan(
              text: ' · $nbEntrepots entrepôt${nbEntrepots > 1 ? 's' : ''}',
            ),
          ],
        ),
      ),
    );
  }
}
