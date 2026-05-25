import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';
import 'modele_sollicitation_suivi_coop.dart';

/// Petit badge coloré qualifiant l'origine d'un destinataire dans la liste
/// des réponses : « Membre » vert, « Coop » bleu, « Indépendant » gris,
/// fallback « Destinataire ».
class RoleTagSuiviSollicitationCoop extends StatelessWidget {
  const RoleTagSuiviSollicitationCoop({
    required this.role,
    super.key,
  });

  final ReplyRoleSollicitationCoop role;

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    String label;
    BoxBorder? border;
    switch (role) {
      case ReplyRoleSollicitationCoop.membre:
        bg = kPrimarySoftSollicitationCoop;
        fg = AppColors.primary;
        label = 'Membre';
        border = null;
        break;
      case ReplyRoleSollicitationCoop.coop:
        bg = kBlueSoftSollicitationCoop;
        fg = kBlueSollicitationCoop;
        label = 'Coop';
        border = null;
        break;
      case ReplyRoleSollicitationCoop.indep:
        bg = AppColors.surfaceSoft;
        fg = AppColors.textSecondary;
        label = 'Indépendant';
        border = Border.all(
          color: AppColors.border,
          width: AppDimens.borderThin,
        );
        break;
      case ReplyRoleSollicitationCoop.unknown:
        bg = AppColors.surfaceSoft;
        fg = AppColors.textSecondary;
        label = 'Destinataire';
        border = Border.all(
          color: AppColors.border,
          width: AppDimens.borderThin,
        );
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
        border: border,
      ),
      child: Text(
        label,
        style: AppTextStyles.labelSmall.copyWith(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: fg,
        ),
      ),
    );
  }
}
