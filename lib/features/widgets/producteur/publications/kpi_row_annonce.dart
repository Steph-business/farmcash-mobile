import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';

/// Ligne de 3 KPIs (vues, messages, commandes) affichée sous le hero de la
/// page détail d'une annonce producteur.
class KpiRowAnnonce extends StatelessWidget {
  const KpiRowAnnonce({
    required this.vues,
    required this.messages,
    required this.commandes,
    super.key,
  });

  final int vues;
  final int messages;
  final int commandes;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(
          bottom: BorderSide(
            color: AppColors.border,
            width: AppDimens.borderThin,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(child: _KpiCol(value: vues.toString(), label: 'Vues')),
          const _KpiDivider(),
          Expanded(
            child: _KpiCol(value: messages.toString(), label: 'Messages'),
          ),
          const _KpiDivider(),
          Expanded(
            child: _KpiCol(value: commandes.toString(), label: 'Commandes'),
          ),
        ],
      ),
    );
  }
}

class _KpiCol extends StatelessWidget {
  const _KpiCol({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: AppTextStyles.titleLarge.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: AppTextStyles.labelSmall.copyWith(
            fontSize: 11,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _KpiDivider extends StatelessWidget {
  const _KpiDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppDimens.borderThin,
      height: 32,
      color: AppColors.border,
    );
  }
}
