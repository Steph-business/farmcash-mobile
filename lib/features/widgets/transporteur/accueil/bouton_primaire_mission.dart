import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';

/// Bouton primaire compact (hauteur 40) destiné à la carte mission active
/// de l'accueil transporteur.
///
/// Variante locale de [BoutonPrincipal] commun (hauteur 48 + width
/// infinie) : pensé pour être placé dans un [Expanded] côte à côte avec
/// un autre bouton.
class BoutonPrimaireMission extends StatelessWidget {
  const BoutonPrimaireMission({
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
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          elevation: 0,
          padding: EdgeInsets.zero,
          shape: const RoundedRectangleBorder(
            borderRadius: AppDimens.brButton,
          ),
          textStyle: AppTextStyles.button.copyWith(fontSize: 13),
        ),
        child: Text(label),
      ),
    );
  }
}
