import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';

/// Carte « Montants » de la page paiement : sous-total + mention claire
/// "0 % de frais pour toi" + total à payer mis en évidence.
///
/// FarmCash applique son modèle **buyer-side zero fees** : l'acheteur
/// paye strictement le sous-total du produit (+ transport éventuel).
/// Les commissions plateforme (3 %) et coopérative (5 %) sont retenues
/// côté vendeur/transporteur au moment du release d'escrow — invisibles
/// pour l'acheteur. La carte affiche cette transparence pour rassurer.
class CarteMontantsPaiement extends StatelessWidget {
  const CarteMontantsPaiement({
    required this.sousTotal,
    required this.frais,
    required this.total,
    super.key,
  });

  final int sousTotal;

  /// Conservé pour compat API (passé par l'appelant) mais en pratique = 0
  /// dans le modèle FarmCash. Si on devait un jour facturer un service
  /// optionnel à l'acheteur (livraison express, garantie premium…), c'est
  /// ici qu'on l'afficherait.
  final int frais;
  final int total;

  @override
  Widget build(BuildContext context) {
    final nf = NumberFormat('#,##0', 'fr_FR');
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border:
            Border.all(color: AppColors.border, width: AppDimens.borderThin),
      ),
      child: Column(
        children: [
          _ligne('Sous-total', '${nf.format(sousTotal)} F'),
          if (frais > 0) _ligne('Frais service', '${nf.format(frais)} F'),
          const SizedBox(height: 8),
          // Bandeau "0 % de frais" — rassure l'acheteur que le prix
          // affiché EST le prix payé. Pas de mauvaise surprise au total.
          if (frais == 0)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.25),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.verified_outlined,
                    size: 16,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Aucune commission · tu payes uniquement le produit',
                      style: AppTextStyles.bodySmall.copyWith(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.only(top: 10),
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: AppColors.border,
                  width: AppDimens.borderThin,
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Total à payer',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.text,
                  ),
                ),
                Text(
                  '${nf.format(total)} F',
                  style: AppTextStyles.displayLarge.copyWith(
                    fontFamily: 'Poppins',
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _ligne(String label, String valeur) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            valeur,
            style: AppTextStyles.bodyMedium.copyWith(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.text,
            ),
          ),
        ],
      ),
    );
  }
}
