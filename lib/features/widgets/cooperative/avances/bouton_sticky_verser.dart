import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';

final NumberFormat _nf = NumberFormat('#,##0', 'fr_FR');

/// Barre figée en bas de la page « Verser une avance » : CTA principal
/// désactivé tant qu'aucun membre + montant valide ne sont saisis,
/// indicateur de chargement pendant l'appel API.
class BoutonStickyVerser extends StatelessWidget {
  const BoutonStickyVerser({
    required this.montant,
    required this.busy,
    required this.enabled,
    required this.onTap,
    super.key,
  });
  final int montant;
  final bool busy;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final actif = enabled && !busy;
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(
          top: BorderSide(
            color: AppColors.border,
            width: AppDimens.borderThin,
          ),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 12),
      child: SizedBox(
        width: double.infinity,
        child: InkWell(
          onTap: actif ? onTap : null,
          borderRadius: AppDimens.brCard,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: actif ? AppColors.primary : AppColors.borderStrong,
              borderRadius: AppDimens.brCard,
            ),
            alignment: Alignment.center,
            child: busy
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Colors.white,
                    ),
                  )
                : Text(
                    montant > 0
                        ? 'Verser ${_nf.format(montant)} F maintenant'
                        : 'Saisir un montant',
                    style: AppTextStyles.labelLarge.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.onPrimary,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
