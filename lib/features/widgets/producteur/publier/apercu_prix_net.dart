import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';

final NumberFormat _nf = NumberFormat('#,##0', 'fr_FR');

/// Aperçu en direct du prix net que le producteur touchera vraiment
/// après la commission FarmCash (3 % par défaut). Affiché juste sous
/// le champ "Prix par kg" dès qu'un montant valide est saisi.
///
/// Objectif UX : que le producteur réfléchisse à son prix d'affichage
/// avec le bon mental model — il sait combien il va vraiment toucher
/// sans surprise au moment du paiement.
///
/// Compact, fond pastel vert, sans bordure agressive — c'est une info,
/// pas une alerte.
class ApercuPrixNet extends StatelessWidget {
  /// Construit l'aperçu.
  const ApercuPrixNet({
    super.key,
    required this.prixBrutKg,
    required this.tauxFarmcash,
  });

  /// Prix brut/kg saisi par le producteur (F CFA).
  final double prixBrutKg;

  /// Taux FarmCash appliqué (ex. 0.03 = 3 %).
  final double tauxFarmcash;

  @override
  Widget build(BuildContext context) {
    final fraisKg = prixBrutKg * tauxFarmcash;
    final netKg = prixBrutKg - fraisKg;
    final pourcent = (tauxFarmcash * 100).toStringAsFixed(0);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.25),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.account_balance_wallet_outlined,
            size: 18,
            color: AppColors.primary,
          ),
          AppDimens.hGap8,
          Expanded(
            child: RichText(
              text: TextSpan(
                style: AppTextStyles.bodySmall.copyWith(
                  fontSize: 13,
                  color: AppColors.text,
                  height: 1.4,
                ),
                children: [
                  const TextSpan(text: 'Tu toucheras '),
                  TextSpan(
                    text: '${_nf.format(netKg.round())} F/kg net',
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                    ),
                  ),
                  TextSpan(text: ' (commission FarmCash $pourcent %)'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
