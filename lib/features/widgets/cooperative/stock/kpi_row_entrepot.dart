import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';
import 'format_kg_entrepot.dart';

const BorderRadius _kBrCard12 = BorderRadius.all(Radius.circular(12));

/// Rangee KPI de la page entrepot : 3 cartes Capacite / Utilisee / Dispo.
class KpiRowEntrepot extends StatelessWidget {
  const KpiRowEntrepot({
    required this.capacite,
    required this.utilise,
    required this.dispoPct,
    super.key,
  });

  /// Capacite totale de l'entrepot (en kg).
  final double capacite;

  /// Quantite utilisee (en kg).
  final double utilise;

  /// Pourcentage de capacite disponible (0-100).
  final int dispoPct;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _KpiCardEntrepot(
            value: formatTonnage(capacite),
            label: 'Capacité',
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _KpiCardEntrepot(
            value: formatTonnage(utilise),
            label: 'Utilisée',
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _KpiCardEntrepot(value: '$dispoPct%', label: 'Dispo'),
        ),
      ],
    );
  }
}

class _KpiCardEntrepot extends StatelessWidget {
  const _KpiCardEntrepot({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: _kBrCard12,
        border: Border.all(
          color: AppColors.border,
          width: AppDimens.borderThin,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: AppTextStyles.titleSmall.copyWith(
              fontFamily: 'Poppins',
              fontSize: 15,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.2,
              height: 1.1,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(
              fontSize: 10,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
