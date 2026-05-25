import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';

/// Bandeau d'avertissement affiché sous la grille des moyens quand le
/// wallet est sélectionné mais que le solde est inférieur au total à
/// payer. Propose une action « Recharger » qui ouvre la page de
/// rechargement wallet.
class BandeauSoldeInsuffisant extends StatelessWidget {
  const BandeauSoldeInsuffisant({
    required this.manquant,
    required this.onRecharger,
    super.key,
  });

  final int manquant;
  final VoidCallback onRecharger;

  @override
  Widget build(BuildContext context) {
    final nf = NumberFormat('#,##0', 'fr_FR');
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: const Color(0xFFFFE082),
          width: AppDimens.borderThin,
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, size: 18, color: Color(0xFFB45309)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Solde insuffisant. Recharge ${nf.format(manquant)} F pour payer avec le wallet.',
              style: AppTextStyles.bodySmall.copyWith(
                fontSize: 12,
                color: AppColors.text,
              ),
            ),
          ),
          const SizedBox(width: 8),
          InkWell(
            onTap: onRecharger,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: Text(
                'Recharger',
                style: AppTextStyles.labelMedium.copyWith(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
