import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';

const BorderRadius _kBrCard12 = BorderRadius.all(Radius.circular(12));

/// Boîte de saisie du poids mesuré pendant la pesée : champ digits-only
/// avec suffixe « kg », et message d'écart annoncé/mesuré coloré (vert
/// si < 10 kg de moins, orange/avertissement au-delà).
class BoitePoidsPesee extends StatelessWidget {
  const BoitePoidsPesee({
    required this.controller,
    required this.ecartLabel,
    required this.ecartColor,
    super.key,
  });
  final TextEditingController controller;
  final String ecartLabel;
  final Color ecartColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: _kBrCard12,
        border: Border.all(
          color: AppColors.borderStrong,
          width: AppDimens.borderThin,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: controller,
            keyboardType:
                const TextInputType.numberWithOptions(decimal: false),
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: AppTextStyles.displayLarge.copyWith(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: AppColors.text,
              letterSpacing: -0.5,
            ),
            decoration: const InputDecoration(
              border: InputBorder.none,
              focusedBorder: InputBorder.none,
              enabledBorder: InputBorder.none,
              isDense: true,
              suffixText: 'kg',
              suffixStyle: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            ecartLabel,
            style: AppTextStyles.bodySmall.copyWith(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: ecartColor,
            ),
          ),
        ],
      ),
    );
  }
}
