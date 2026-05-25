import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';

/// Ligne récapitulative sous le titre : "X commandes en cours · Y livrées ce mois".
class RecapCommandes extends StatelessWidget {
  const RecapCommandes({
    super.key,
    required this.enCours,
    required this.livreesCeMois,
  });

  final int enCours;
  final int livreesCeMois;

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
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
          children: [
            TextSpan(
              text: '$enCours commande${enCours > 1 ? 's' : ''} en cours',
              style: AppTextStyles.bodySmall.copyWith(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.text,
              ),
            ),
            const TextSpan(text: ' · '),
            TextSpan(
              text:
                  '$livreesCeMois livrée${livreesCeMois > 1 ? 's' : ''} ce mois',
            ),
          ],
        ),
      ),
    );
  }
}
