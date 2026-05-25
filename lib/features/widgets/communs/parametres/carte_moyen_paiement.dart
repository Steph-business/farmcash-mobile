import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';

/// Carte représentant un moyen de paiement enregistré (Mobile Money, carte
/// bancaire, virement). Couleurs et icône varient selon le type.
class CarteMoyenPaiement extends StatelessWidget {
  /// Construit la carte.
  const CarteMoyenPaiement({
    super.key,
    required this.icone,
    required this.nom,
    required this.sousLigne,
    required this.parDefaut,
    required this.onDefinirParDefaut,
    required this.onSupprimer,
  });

  /// Icône représentant l'opérateur ou type (orange_money, mtn, visa…).
  final IconData icone;

  /// Label affiché en gras (ex. "Orange Money · 07 ** ** 12").
  final String nom;

  /// Sous-ligne (ex. "Ajouté le 12 mai 2026").
  final String sousLigne;

  /// Vrai si c'est le moyen de paiement par défaut.
  final bool parDefaut;

  /// Définir ce moyen comme défaut (no-op si déjà défaut).
  final VoidCallback onDefinirParDefaut;

  /// Supprimer ce moyen de paiement (confirmation à la charge du parent).
  final VoidCallback onSupprimer;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(AppDimens.space16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: AppDimens.brCard,
        border: Border.all(
          color: parDefaut
              ? AppColors.primary.withValues(alpha: 0.5)
              : AppColors.border,
          width: parDefaut ? 1.5 : AppDimens.borderThin,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.surfaceSoft,
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: Icon(icone, color: AppColors.text, size: 22),
              ),
              AppDimens.hGap12,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            nom,
                            style: AppTextStyles.bodyMedium.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (parDefaut) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8F5E9),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              'Par défaut',
                              style: AppTextStyles.labelSmall.copyWith(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      sousLigne,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          AppDimens.vGap12,
          Row(
            children: [
              if (!parDefaut)
                Expanded(
                  child: OutlinedButton(
                    onPressed: onDefinirParDefaut,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: BorderSide(
                        color: AppColors.primary.withValues(alpha: 0.4),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Définir par défaut',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              if (!parDefaut) const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton(
                  onPressed: onSupprimer,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side: BorderSide(
                      color: AppColors.error.withValues(alpha: 0.4),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Supprimer',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
