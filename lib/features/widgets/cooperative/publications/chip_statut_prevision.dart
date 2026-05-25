import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';
import 'groupe_prevision_card_model.dart';

const Color _kPrimarySoft = Color(0xFFE8F5E9);
const Color _kOrangeSoft = Color(0xFFFFF3E0);
const Color _kOrange = Color(0xFFE65100);

/// Chip de statut affiche en bas d'une carte de groupe de prevision.
/// Trois etats : agregeable (vert), delai court (orange) ou minimum
/// fournisseurs non atteint (gris avec contour).
class ChipStatutPrevision extends StatelessWidget {
  const ChipStatutPrevision({required this.status, super.key});

  final StatutChipPrevision status;

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    String label;
    BoxBorder? border;
    switch (status) {
      case StatutChipPrevision.agregeable:
        bg = _kPrimarySoft;
        fg = AppColors.primary;
        label = 'Agrégeable';
        border = null;
        break;
      case StatutChipPrevision.delaiCourt:
        bg = _kOrangeSoft;
        fg = _kOrange;
        label = 'Délai court';
        border = null;
        break;
      case StatutChipPrevision.minFournisseurs:
        bg = AppColors.surfaceSoft;
        fg = AppColors.textSecondary;
        label = 'Min 2 fournisseurs';
        border = Border.all(
          color: AppColors.border,
          width: AppDimens.borderThin,
        );
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: border,
      ),
      child: Text(
        label,
        style: AppTextStyles.labelSmall.copyWith(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: fg,
        ),
      ),
    );
  }
}
