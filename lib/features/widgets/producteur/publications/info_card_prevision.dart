import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';
import 'prevision_detail_constants.dart';

/// Carte d'info verte explicative : prévient le farmer qu'il sera notifié
/// 5 jours avant la récolte pour convertir sa prévision en annonce.
class InfoCardPrevision extends StatelessWidget {
  const InfoCardPrevision({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: kPrevisionDetailPrimarySoft,
        borderRadius: BorderRadius.circular(14),
        border:
            Border.all(color: AppColors.border, width: AppDimens.borderThin),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.background,
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.info_outline,
              size: 18,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Tu seras notifié 5 jours avant la date prévue. '
              'Tu pourras alors convertir cette prévision en annonce de vente '
              'au prix de ton choix.',
              style: AppTextStyles.bodyMedium.copyWith(
                fontSize: 13,
                color: AppColors.text,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
