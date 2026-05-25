import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';

const Color _kPrimarySoft = Color(0xFFE8F5E9);

/// Placeholder vert affiché pendant le chargement de la sollicitation.
///
/// Garde la même hauteur et le même style que la vraie card pour
/// éviter un saut de mise en page au moment de la résolution.
class SollicitationRecapCardLoading extends StatelessWidget {
  const SollicitationRecapCardLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _kPrimarySoft,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.border,
          width: AppDimens.borderThin,
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 14),
      child: const Center(
        child: SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }
}
