import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import 'need_line_creer_sollicitation_coop.dart';

final NumberFormat _nf = NumberFormat('#,##0', 'fr_FR');

/// Card « Besoin à combler » : encadré blanc affichant l'écart entre le
/// stock coop actuel et la quantité demandée. Deux lignes empilées —
/// stock OK (vert) puis manque à combler (orange souligné).
///
/// Quand l'offre n'est pas connue (sollicitation libre depuis le FAB),
/// on cache la 2e ligne et on affiche juste le stock — sinon les chiffres
/// seraient menteurs.
class NeedCardCreerSollicitationCoop extends StatelessWidget {
  const NeedCardCreerSollicitationCoop({
    super.key,
    this.stockKg,
    this.quantiteDemandeeKg,
  });

  /// Stock coop actuel (kg). `null` = inconnu/non chargé.
  final double? stockKg;

  /// Quantité demandée par l'offre source (kg). `null` = pas d'offre.
  final double? quantiteDemandeeKg;

  @override
  Widget build(BuildContext context) {
    final stockLabel = stockKg != null
        ? '${_nf.format(stockKg!.round())} kg'
        : '— kg';
    final manque = (stockKg != null && quantiteDemandeeKg != null)
        ? (quantiteDemandeeKg! - stockKg!).clamp(0, double.infinity)
        : null;
    final hasManque = manque != null && manque > 0;
    final stockOk = stockKg != null && quantiteDemandeeKg != null && !hasManque;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimens.radiusCard),
        border: Border.all(
          color: AppColors.border,
          width: AppDimens.borderThin,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          NeedLineCreerSollicitationCoop(
            label: 'Stock coop actuel',
            value: stockLabel,
            ok: stockOk,
            isLast: !hasManque,
          ),
          if (hasManque)
            NeedLineCreerSollicitationCoop(
              label: 'Manque à compléter',
              value: '${_nf.format(manque.round())} kg',
              ok: false,
              isLast: true,
            ),
        ],
      ),
    );
  }
}
