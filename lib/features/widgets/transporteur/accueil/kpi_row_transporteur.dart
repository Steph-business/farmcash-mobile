import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';
import '_constantes_accueil_transporteur.dart';

/// Ligne de 3 KPI compacts pour l'accueil transporteur : gains 7j, missions
/// livrées, note moyenne.
class KpiRowTransporteur extends StatelessWidget {
  const KpiRowTransporteur({
    super.key,
    required this.gains,
    required this.devise,
    required this.livrees,
    required this.note,
  });

  final double gains;
  final String devise;
  final int livrees;
  final double note;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: CarteKpiTransporteur(
            icon: Icons.payments_outlined,
            valeur: formatMontantTransporteur(gains, devise),
            libelle: 'Gains 7 jours',
          ),
        ),
        AppDimens.hGap8,
        Expanded(
          child: CarteKpiTransporteur(
            icon: Icons.local_shipping_outlined,
            valeur: livrees.toString(),
            libelle: 'Livrées',
          ),
        ),
        AppDimens.hGap8,
        Expanded(
          child: CarteKpiTransporteur(
            icon: Icons.star_border,
            valeur: note > 0
                ? '★ ${note.toStringAsFixed(1).replaceAll('.', ',')}'
                : '—',
            libelle: 'Note',
          ),
        ),
      ],
    );
  }
}

/// Cellule KPI unitaire — icône grise + valeur en gros + libellé secondaire.
class CarteKpiTransporteur extends StatelessWidget {
  const CarteKpiTransporteur({
    super.key,
    required this.icon,
    required this.valeur,
    required this.libelle,
  });

  final IconData icon;
  final String valeur;
  final String libelle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimens.space12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppDimens.brCard,
        border:
            Border.all(color: AppColors.border, width: AppDimens.borderThin),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: AppDimens.iconS,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: 6),
          Text(
            valeur,
            style: AppTextStyles.titleLarge.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.3,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            libelle,
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w400,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
