import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';
import '../../communs/section_titre.dart';

/// Section « Montants » de la page détail commande côté producteur.
/// Affiche la décomposition du calcul du net à recevoir :
///
/// ```
/// Quantité × Prix : 100 kg × 500 F        50 000 F
/// Frais plateforme (3%)                  -1 500 F
/// Total net à recevoir                    48 500 F  ← gros, en vert
/// ```
///
/// Les montants sont passés en paramètres pour que la page parent
/// contrôle le calcul (brut / frais / net) — on évite que ce widget ait
/// la responsabilité de la business logic de pricing.
class SectionMontants extends StatelessWidget {
  const SectionMontants({
    required this.brut,
    required this.frais,
    required this.net,
    required this.qte,
    required this.prixKg,
    super.key,
  });

  final double brut;
  final double frais;
  final double net;
  final double qte;
  final double prixKg;

  @override
  Widget build(BuildContext context) {
    final qteLabel = qte.toStringAsFixed(0);
    final prixLabel = prixKg.toStringAsFixed(0);
    return SectionTitre(
      titre: 'Montants',
      encadre: true,
      child: Column(
        children: [
          _Ligne(
            l: 'Quantité × Prix : $qteLabel kg × $prixLabel F',
            v: '${_fmt(brut)} F',
            isLast: false,
          ),
          _Ligne(
            l: 'Frais plateforme (3%)',
            v: '-${_fmt(frais)} F',
            isLast: false,
          ),
          _Ligne(
            l: 'Total net à recevoir',
            v: '${_fmt(net)} F',
            isLast: true,
            isTotal: true,
          ),
        ],
      ),
    );
  }
}

class _Ligne extends StatelessWidget {
  const _Ligne({
    required this.l,
    required this.v,
    required this.isLast,
    this.isTotal = false,
  });

  final String l;
  final String v;
  final bool isLast;
  final bool isTotal;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: isTotal ? 14 : 10, bottom: 10),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: isLast ? Colors.transparent : AppColors.border,
            width: AppDimens.borderThin,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              l,
              style: AppTextStyles.bodyMedium.copyWith(
                fontSize: 15,
                color: isTotal ? AppColors.text : AppColors.textSecondary,
                fontWeight: isTotal ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
          Text(
            v,
            style: isTotal
                ? AppTextStyles.displayLarge.copyWith(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                    letterSpacing: -0.3,
                  )
                : AppTextStyles.bodyMedium.copyWith(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
          ),
        ],
      ),
    );
  }
}

String _fmt(double v) => NumberFormat('#,##0', 'fr_FR').format(v);
