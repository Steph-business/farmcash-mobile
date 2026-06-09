import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../routing/route_names.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';

/// Bouton sticky bas-de-page : Confirmer la distribution d'un payout.
/// Pousse vers `cooperativePayoutConfirmationPathFor(payoutId)`.
class BoutonStickyConfirmerDistribution extends StatelessWidget {
  const BoutonStickyConfirmerDistribution({
    required this.payoutId,
    super.key,
  });

  final String payoutId;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        // Shadow soft top → effet plateau flottant qui décolle le sticky du
        // contenu scrollable au-dessus.
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
        border: const Border(
          top: BorderSide(
            color: AppColors.border,
            width: AppDimens.borderThin,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        minimum: const EdgeInsets.only(bottom: 8),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 12),
          child: SizedBox(
            width: double.infinity,
            child: InkWell(
              onTap: () => context.push(
                RouteNames.cooperativePayoutConfirmationPathFor(payoutId),
              ),
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: AppColors.primary,
                    width: AppDimens.borderThin,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  'Confirmer la distribution',
                  style: AppTextStyles.labelLarge.copyWith(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.onPrimary,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
