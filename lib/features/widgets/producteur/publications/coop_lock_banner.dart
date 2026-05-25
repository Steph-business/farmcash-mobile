import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';

/// Banner d'info bleu affiché en haut de la zone d'actions quand la coop a
/// `VALIDATED` ou `INCLUDED` la prévision. Explique au FARMER pourquoi les
/// boutons modifier/supprimer sont désactivés — il faut passer par la coop.
class CoopLockBanner extends StatelessWidget {
  const CoopLockBanner({this.coopStatus, super.key});

  final String? coopStatus;

  @override
  Widget build(BuildContext context) {
    final isIncluded = coopStatus == 'INCLUDED';
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.border,
          width: AppDimens.borderThin,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.lock_outline,
            color: Color(0xFF1D4ED8),
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isIncluded
                      ? 'Prévision intégrée à une publication coop'
                      : 'Prévision validée par ta coopérative',
                  style: AppTextStyles.titleSmall.copyWith(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1E40AF),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  isIncluded
                      ? 'Elle fait partie d\'une vente agrégée. Contacte ta '
                          'coopérative pour toute modification.'
                      : 'La coopérative la gère maintenant. Tu ne peux plus la '
                          'modifier ou la supprimer toi-même.',
                  style: AppTextStyles.bodySmall.copyWith(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
