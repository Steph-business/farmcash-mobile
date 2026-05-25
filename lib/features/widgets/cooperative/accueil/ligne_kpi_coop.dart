import 'package:flutter/material.dart';

import '_constantes_accueil_coop.dart';
import '../../../../theme/app_colors.dart';
import 'carte_kpi_coop.dart';

/// Ligne de 4 cards KPI de l'accueil coopérative : Membres / Stock / Solde
/// / Payouts. Hauteur intrinsèque alignée pour homogénéiser la rangée même
/// si les libellés varient.
class LigneKpiCoop extends StatelessWidget {
  const LigneKpiCoop({
    super.key,
    required this.nbMembres,
    required this.stockKg,
    required this.solde,
    this.nbPayouts = 0,
  });

  final int nbMembres;
  final double stockKg;
  final double solde;

  /// V1 — pas d'endpoint payouts coop pour l'instant ; reste à 0.
  final int nbPayouts;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: CarteKpiCoop(
              icon: Icons.groups_outlined,
              value: '$nbMembres',
              label: 'Membres',
              background: kPrimarySoftCoop,
              accent: AppColors.primary,
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: CarteKpiCoop(
              icon: Icons.inventory_2_outlined,
              value: _formatStock(stockKg),
              label: 'Stock',
              background: kInfoSoftCoop,
              accent: kInfoAccentCoop,
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: CarteKpiCoop(
              icon: Icons.account_balance_wallet_outlined,
              value: _formatCourt(solde),
              label: 'Solde',
              background: kWarnSoftCoop,
              accent: kWarnAccentCoop,
            ),
          ),
          const SizedBox(width: 6),
          // V1 — pas d'endpoint payouts coop pour l'instant.
          // TODO(payouts) : brancher quand l'API expose le compteur de payouts coop.
          Expanded(
            child: CarteKpiCoop(
              icon: Icons.payments_outlined,
              value: '$nbPayouts',
              label: 'Payouts',
              background: kHighlightSoftCoop,
              accent: kHighlightAccentCoop,
            ),
          ),
        ],
      ),
    );
  }
}

/// Formate un montant en F CFA "court" : 84500 → "84,5K", 1200000 → "1,2M",
/// inférieur à 1000 → "[v] F".
String _formatCourt(double v) {
  if (v.isNaN || v.isInfinite) return '0 F';
  final abs = v.abs();
  if (abs >= 1000000) {
    return '${_formatDecimal(v / 1000000)}M';
  }
  if (abs >= 1000) {
    return '${_formatDecimal(v / 1000)}K';
  }
  return '${v.toInt()} F';
}

/// Formate une quantité en kg : au-dessus de 1000 → "12,5 t", sinon "[n] kg".
String _formatStock(double kg) {
  if (kg <= 0) return '0 kg';
  if (kg >= 1000) {
    return '${_formatDecimal(kg / 1000)} t';
  }
  return '${kg.toInt()} kg';
}

/// Une décimale, séparateur virgule à la française, sans zéro inutile.
String _formatDecimal(double v) {
  final rounded = (v * 10).round() / 10;
  final isInt = rounded == rounded.roundToDouble();
  if (isInt) return rounded.toInt().toString();
  return rounded.toString().replaceAll('.', ',');
}
