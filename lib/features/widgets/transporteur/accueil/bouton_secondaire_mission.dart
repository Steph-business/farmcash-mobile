import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';

/// Bouton secondaire compact (hauteur 40) destiné à la carte mission active
/// de l'accueil transporteur.
///
/// Variante locale de [BoutonSecondaire] commun (hauteur 48 + width
/// infinie) : ici on a besoin d'un bouton pensé pour être placé dans un
/// [Expanded] avec un autre bouton — d'où la hauteur plus courte et
/// l'absence de width fixe.
class BoutonSecondaireMission extends StatelessWidget {
  const BoutonSecondaireMission({
    super.key,
    required this.label,
    required this.onTap,
  });

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.text,
          backgroundColor: AppColors.surface,
          side: const BorderSide(
            color: AppColors.borderStrong,
            width: AppDimens.borderThin,
          ),
          shape: const RoundedRectangleBorder(
            borderRadius: AppDimens.brButton,
          ),
          padding: EdgeInsets.zero,
          textStyle: AppTextStyles.button.copyWith(fontSize: 13),
        ),
        child: Text(label),
      ),
    );
  }
}
