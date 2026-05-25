import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';

/// Couleur primary-soft commune aux écrans wallet (cohérence maquette).
const Color _kPrimarySoft = Color(0xFFE8F5E9);

/// Bandeau compact affichant le solde — variante primary-soft utilisée sur
/// les pages Recharger / Retirer (en tête du formulaire).
class BandeauSoldeCompact extends StatelessWidget {
  const BandeauSoldeCompact({
    super.key,
    required this.balance,
    required this.label,
  });

  /// Solde à afficher (formaté #,##0 fr_FR).
  final double balance;

  /// Libellé au-dessus du montant (ex : « Solde actuel », « Solde disponible »).
  final String label;

  @override
  Widget build(BuildContext context) {
    final formatted = NumberFormat('#,##0', 'fr_FR').format(balance);
    return Container(
      decoration: BoxDecoration(
        color: _kPrimarySoft,
        borderRadius: BorderRadius.circular(14),
        border:
            Border.all(color: AppColors.border, width: AppDimens.borderThin),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        children: [
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$formatted F',
            style: AppTextStyles.displayLarge.copyWith(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
              letterSpacing: -0.3,
            ),
          ),
        ],
      ),
    );
  }
}
