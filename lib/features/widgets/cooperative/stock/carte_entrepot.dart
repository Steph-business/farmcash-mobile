import 'package:flutter/material.dart';

import '../../../../models/lot.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';

const Color _kPrimarySoft = Color(0xFFE8F5E9);

/// Carte présentant un entrepôt (nom, ville, capacité).
class CarteEntrepot extends StatelessWidget {
  const CarteEntrepot({
    super.key,
    required this.entrepot,
    required this.onTap,
  });

  /// Entrepôt à afficher.
  final Entrepot entrepot;

  /// Action déclenchée au tap sur la carte.
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    // Pas d'info "usage actuel" sans relation Lot→Entrepôt — on n'affiche
    // que la capacité totale en t/kg.
    final capacite = entrepot.capaciteKg;
    final capaciteLabel = capacite >= 1000
        ? '${(capacite / 1000).toStringAsFixed(1)} t'
        : '${capacite.round()} kg';
    final ville = entrepot.location ?? '';
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(AppDimens.space16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: AppColors.border,
              width: AppDimens.borderThin,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: _kPrimarySoft,
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.warehouse_outlined,
                  size: 22,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      entrepot.nom,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.text,
                      ),
                    ),
                    if (ville.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        ville,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.bodySmall.copyWith(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                    const SizedBox(height: 6),
                    Text(
                      'Capacité $capaciteLabel${entrepot.isRefrigere ? ' · Réfrigéré' : ''}',
                      style: AppTextStyles.labelSmall.copyWith(
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
        ),
      ),
    );
  }
}
