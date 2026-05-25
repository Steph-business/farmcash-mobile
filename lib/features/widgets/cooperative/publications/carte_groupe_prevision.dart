import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';
import 'cellule_stat_prevision.dart';
import 'chip_statut_prevision.dart';
import 'groupe_prevision_card_model.dart';

const Color _kPrimarySoft = Color(0xFFE8F5E9);

/// Carte de groupe de prevision : icone produit + nom + meta-stats (nombre
/// de previsions, cumul, fenetre de livraison), 2 cellules statistiques
/// "Cumule" et "Fenetre", puis footer avec chip de statut et lien "Voir
/// detail".
class CarteGroupePrevision extends StatelessWidget {
  const CarteGroupePrevision({required this.group, super.key});

  final GroupePrevisionCardModel group;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppDimens.radiusCard),
        border: Border.all(
          color: AppColors.border,
          width: AppDimens.borderThin,
        ),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top : icone + texte + chevron
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _kPrimarySoft,
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: Icon(
                  group.icon,
                  size: 22,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      group.produit,
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${group.nbPrev} prévisions · ${formatNombrePrevision(group.cumulKg)} kg cumulé · livraison ${group.fenetreLivraison}',
                      style: AppTextStyles.bodySmall.copyWith(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.chevron_right,
                size: 18,
                color: AppColors.textSubtle,
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Stats : Cumule + Fenetre
          Row(
            children: [
              Expanded(
                child: CelluleStatPrevision(
                  label: 'Cumulé',
                  value: '${formatNombrePrevision(group.cumulKg)} kg',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: CelluleStatPrevision(
                  label: 'Fenêtre',
                  value: group.fenetreLivraison,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            height: 1,
            color: AppColors.border,
          ),
          const SizedBox(height: 12),
          // Footer : chip status + lien "Voir detail"
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ChipStatutPrevision(status: group.chipStatus),
              Text(
                'Voir détail',
                style: AppTextStyles.bodySmall.copyWith(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Formate un entier avec espaces fines comme separateur de milliers
/// (ex : 12345 -> "12 345"). Utilise dans la carte de groupe de prevision.
String formatNombrePrevision(int v) {
  final s = v.toString();
  final buf = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buf.write(' ');
    buf.write(s[i]);
  }
  return buf.toString();
}
