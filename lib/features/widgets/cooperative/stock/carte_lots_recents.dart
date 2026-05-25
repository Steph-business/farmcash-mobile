import 'package:flutter/material.dart';

import '../../../../models/lot.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import 'ligne_lot_stock.dart';

/// Carte regroupant les lots récents avec séparateurs.
class CarteLotsRecents extends StatelessWidget {
  const CarteLotsRecents({super.key, required this.lots});

  /// Lots à afficher (déjà triés).
  final List<Lot> lots;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.border,
          width: AppDimens.borderThin,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (var i = 0; i < lots.length; i++) ...[
            LigneLotStock(lot: lots[i]),
            if (i < lots.length - 1)
              const Divider(
                height: 1,
                thickness: 1,
                color: AppColors.border,
              ),
          ],
        ],
      ),
    );
  }
}
