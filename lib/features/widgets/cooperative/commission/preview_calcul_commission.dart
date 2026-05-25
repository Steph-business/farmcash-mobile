import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';

final _nf = NumberFormat('#,##0', 'fr_FR');

/// Preview du calcul de commission : pour un montant de référence (ex.
/// 100 000 F), affiche le montant prélevé par la coop et le net membre.
class PreviewCalculCommission extends StatelessWidget {
  /// Construit le bloc preview.
  const PreviewCalculCommission({
    super.key,
    required this.montantReference,
    required this.tauxPourcent,
  });

  /// Montant fictif sur lequel calculer la commission (par défaut 100 000).
  final double montantReference;

  /// Taux de commission appliqué (entre 0 et 100).
  final double tauxPourcent;

  @override
  Widget build(BuildContext context) {
    final commission = montantReference * tauxPourcent / 100;
    final netMembre = montantReference - commission;

    return Container(
      padding: const EdgeInsets.all(AppDimens.space16),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: AppDimens.brCard,
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Sur une vente de ${_nf.format(montantReference.round())} F :',
            style: AppTextStyles.labelMedium.copyWith(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
          AppDimens.vGap12,
          _LigneRepartition(
            label: 'Commission coopérative',
            valeur: '${_nf.format(commission.round())} F',
            taux: tauxPourcent,
            estCommission: true,
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Divider(height: 1, color: AppColors.border),
          ),
          _LigneRepartition(
            label: 'Net versé au membre',
            valeur: '${_nf.format(netMembre.round())} F',
            taux: 100 - tauxPourcent,
            estCommission: false,
          ),
        ],
      ),
    );
  }
}

class _LigneRepartition extends StatelessWidget {
  const _LigneRepartition({
    required this.label,
    required this.valeur,
    required this.taux,
    required this.estCommission,
  });

  final String label;
  final String valeur;
  final double taux;
  final bool estCommission;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: estCommission
                ? AppColors.primary
                : AppColors.text,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Text(
          '${taux.toStringAsFixed(1)} %',
          style: AppTextStyles.labelSmall.copyWith(
            fontSize: 11,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: 10),
        Text(
          valeur,
          style: AppTextStyles.titleSmall.copyWith(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: estCommission ? AppColors.primary : AppColors.text,
          ),
        ),
      ],
    );
  }
}
