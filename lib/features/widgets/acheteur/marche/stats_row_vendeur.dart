import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';

const BorderRadius _kBrCard = BorderRadius.all(Radius.circular(12));

/// Ligne de 2 cartes de stats (note + nombre d'annonces actives) pour la
/// page « Profil vendeur » côté acheteur.
class StatsRowVendeur extends StatelessWidget {
  const StatsRowVendeur({
    required this.note,
    required this.annoncesActives,
    super.key,
  });

  /// Note moyenne du vendeur (déjà formatée, ex: « 4.3 » ou « — »).
  final String note;

  /// Nombre d'annonces actives du vendeur (déjà formaté).
  final String annoncesActives;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _StatCard(value: '$note★', label: 'Note')),
        const SizedBox(width: 8),
        Expanded(
          child: _StatCard(value: annoncesActives, label: 'Annonces'),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: _kBrCard,
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
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.titleSmall.copyWith(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.2,
              color: AppColors.text,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
