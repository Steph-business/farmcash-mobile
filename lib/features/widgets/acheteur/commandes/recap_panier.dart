import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';

final NumberFormat _nf = NumberFormat('#,##0', 'fr_FR');

/// Récapitulatif des montants du panier acheteur : sous-total, frais de
/// service, mention « Livraison calculée au paiement » et total estimé en
/// gros caractères Poppins.
class RecapPanier extends StatelessWidget {
  const RecapPanier({
    required this.sousTotal,
    required this.fraisService,
    required this.total,
    super.key,
  });

  final int sousTotal;
  final int fraisService;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: AppDimens.borderThin),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _row('Sous-total', '${_nf.format(sousTotal)} F', divider: true),
          _row(
            'Frais service (1%)',
            '${_nf.format(fraisService)} F',
            divider: true,
          ),
          _row(
            'Livraison',
            'Calculée au paiement',
            divider: true,
            italic: true,
          ),
          _row('Total estimé', '${_nf.format(total)} F', isTotal: true),
        ],
      ),
    );
  }

  Widget _row(
    String label,
    String value, {
    bool divider = false,
    bool isTotal = false,
    bool italic = false,
  }) {
    final labelStyle = isTotal
        ? AppTextStyles.bodyMedium.copyWith(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColors.text,
          )
        : AppTextStyles.bodySmall.copyWith(
            fontSize: 13,
            color: AppColors.textSecondary,
            fontStyle: italic ? FontStyle.italic : FontStyle.normal,
          );
    final valueStyle = isTotal
        ? AppTextStyles.headlineMedium.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
            fontFamily: 'Poppins',
          )
        : AppTextStyles.bodyMedium.copyWith(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.text,
          );
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: divider ? AppColors.border : Colors.transparent,
            width: AppDimens.borderThin,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(child: Text(label, style: labelStyle)),
          const SizedBox(width: 12),
          Text(value, style: valueStyle),
        ],
      ),
    );
  }
}
