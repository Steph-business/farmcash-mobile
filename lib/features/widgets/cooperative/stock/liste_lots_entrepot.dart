import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../models/lot.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';
import 'format_kg_entrepot.dart';

const Color _kPrimarySoft = Color(0xFFE8F5E9);
const BorderRadius _kBrCard14 = BorderRadius.all(Radius.circular(14));
const BorderRadius _kBrThumb = BorderRadius.all(Radius.circular(8));

/// Carte listant les lots presents dans un entrepot avec separateurs
/// internes entre les tuiles.
class ListeLotsEntrepot extends StatelessWidget {
  const ListeLotsEntrepot({required this.lots, super.key});

  final List<Lot> lots;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: _kBrCard14,
        border: Border.all(
          color: AppColors.border,
          width: AppDimens.borderThin,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (int i = 0; i < lots.length; i++) ...[
            _TuileLot(lot: lots[i]),
            if (i != lots.length - 1)
              const Divider(
                height: 1,
                thickness: AppDimens.borderThin,
                color: AppColors.border,
              ),
          ],
        ],
      ),
    );
  }
}

class _TuileLot extends StatelessWidget {
  const _TuileLot({required this.lot});

  final Lot lot;

  @override
  Widget build(BuildContext context) {
    final qteLabel = '${formatKgEspaces(lot.quantiteKg)} kg';
    final dateLabel = lot.createdAt != null
        ? DateFormat('dd/MM').format(lot.createdAt!.toLocal())
        : '—';
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: _kBrThumb,
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: _kPrimarySoft,
                border: Border.all(
                  color: AppColors.border,
                  width: AppDimens.borderThin,
                ),
                borderRadius: _kBrThumb,
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.inventory_2_outlined,
                color: AppColors.primary,
                size: 22,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${lot.lotCode} · $qteLabel',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.titleSmall.copyWith(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$dateLabel · ${qualiteLabelLong(lot.qualite)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodySmall.copyWith(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            qualiteLabelCourt(lot.qualite),
            style: AppTextStyles.labelMedium.copyWith(
              fontFamily: 'Poppins',
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.text,
            ),
          ),
        ],
      ),
    );
  }
}
