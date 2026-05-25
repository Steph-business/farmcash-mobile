import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';

/// Barre d'action collée en bas de la page paiement : bouton primaire
/// « Payer X F · escrow sécurisé », passant à « Solde wallet
/// insuffisant » + désactivé quand le wallet est sélectionné mais
/// insuffisant. Spinner pendant l'appel API.
class StickyBottomPaiement extends StatelessWidget {
  const StickyBottomPaiement({
    required this.total,
    required this.occupe,
    required this.active,
    required this.onPayer,
    super.key,
  });

  final int total;
  final bool occupe;
  final bool active;
  final VoidCallback onPayer;

  @override
  Widget build(BuildContext context) {
    final nf = NumberFormat('#,##0', 'fr_FR');
    final actif = active && !occupe;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(
          top:
              BorderSide(color: AppColors.border, width: AppDimens.borderThin),
        ),
      ),
      child: SafeArea(
        top: false,
        child: InkWell(
          onTap: actif ? onPayer : null,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            height: 50,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: actif ? AppColors.primary : AppColors.borderStrong,
              borderRadius: BorderRadius.circular(12),
            ),
            child: occupe
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Colors.white,
                    ),
                  )
                : Text(
                    active
                        ? 'Payer ${nf.format(total)} F · escrow sécurisé'
                        : 'Solde wallet insuffisant',
                    style: AppTextStyles.button.copyWith(
                      fontSize: 14,
                      color: AppColors.onPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
