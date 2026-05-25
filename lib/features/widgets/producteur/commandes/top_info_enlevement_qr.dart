import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';

const Color _kWarnSoft = Color(0xFFFEF3C7);
const Color _kWarnSoftBorder = Color(0xFFFDE68A);
const Color _kWarn = Color(0xFFB45309);

/// Bandeau warn-soft expliquant au producteur de montrer le QR au transporteur
/// (declenche l'auto-release de l'escrow PRODUCT).
class TopInfoEnlevementQr extends StatelessWidget {
  const TopInfoEnlevementQr({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _kWarnSoft,
        borderRadius: BorderRadius.circular(12),
        border:
            Border.all(color: _kWarnSoftBorder, width: AppDimens.borderThin),
      ),
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              color: _kWarn,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.info_outline,
              size: 16,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Montre ce code au transporteur',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: _kWarn,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Il doit le scanner pour confirmer l\'enlèvement. C\'est '
                  'ce qui déclenche le versement des 169 750 F sur ton wallet.',
                  style: AppTextStyles.bodySmall.copyWith(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    height: 1.5,
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
