import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_text_styles.dart';

const Color _kPrimarySoft = Color(0xFFE8F5E9);
final NumberFormat _nf = NumberFormat('#,##0', 'fr_FR');

/// Bannière de récap en tête de l'historique des missions : nombre de
/// missions livrées et total des gains cumulés.
class BanniereRecapHistorique extends StatelessWidget {
  const BanniereRecapHistorique({
    required this.totalLivrees,
    required this.totalGains,
    super.key,
  });

  final int totalLivrees;
  final double totalGains;

  @override
  Widget build(BuildContext context) {
    final gains = _nf.format(totalGains.round());
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: _kPrimarySoft,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.check_circle_outline,
              size: 18,
              color: AppColors.onPrimary,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$totalLivrees mission${totalLivrees > 1 ? 's' : ''} livrée${totalLivrees > 1 ? 's' : ''}',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  totalGains > 0
                      ? '+$gains F au total'
                      : 'Aucun gain enregistré',
                  style: AppTextStyles.labelSmall.copyWith(
                    fontSize: 11,
                    color: AppColors.textSecondary,
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
