import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';

/// Carte récapitulative du total estimé (quantité × prix proposé).
///
/// Encadrée en vert pour attirer l'attention sur le montant final.
class DemandeTotalCard extends StatelessWidget {
  const DemandeTotalCard({required this.total, super.key});

  final double total;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primary,
          width: AppDimens.borderMedium,
        ),
      ),
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Total estimé',
              style: AppTextStyles.bodyMedium.copyWith(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            '${_fmt(total)} F',
            style: AppTextStyles.displayLarge.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

String _fmt(double v) => NumberFormat('#,##0', 'fr_FR').format(v.round());
