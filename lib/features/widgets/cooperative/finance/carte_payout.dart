import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../models/payout.dart';
import '../../../../routing/route_names.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';
import 'chip_statut_payout.dart';
import 'format_montant_fcfa.dart';

/// Carte d'un PayoutBatch dans la liste des distributions :
/// memo + nb lignes + montant + date + chip statut + bouton Detail.
class CartePayout extends StatelessWidget {
  const CartePayout({required this.payout, super.key});

  final PayoutBatch payout;

  @override
  Widget build(BuildContext context) {
    final memo =
        'Distribution #${payout.id.substring(0, payout.id.length.clamp(0, 8))}';
    final sousTitre = '${payout.items.length} ligne(s) · '
        '${formatMontantFcfa(payout.totalAmount)} F';
    final dateLabel = payout.createdAt != null
        ? 'Créé le ${DateFormat('dd/MM').format(payout.createdAt!.toLocal())}'
        : '';
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: AppDimens.brCard,
        border: Border.all(
          color: AppColors.border,
          width: AppDimens.borderThin,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            memo,
            style: AppTextStyles.titleSmall.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            sousTitre,
            style: AppTextStyles.bodySmall.copyWith(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          if (dateLabel.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              dateLabel,
              style: AppTextStyles.labelSmall.copyWith(
                fontSize: 11,
                color: AppColors.textSubtle,
              ),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              ChipStatutPayout(status: payout.status),
              const Spacer(),
              _MiniBoutonDetail(
                label: 'Détail',
                onTap: () => context.push(
                  RouteNames.cooperativePayoutDetailPathFor(payout.id),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniBoutonDetail extends StatelessWidget {
  const _MiniBoutonDetail({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: AppColors.primary,
            width: AppDimens.borderThin,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.labelMedium.copyWith(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.onPrimary,
          ),
        ),
      ),
    );
  }
}
