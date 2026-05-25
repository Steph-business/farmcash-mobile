import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';

/// Gros bouton vert "Lancer l'analyse" en bas de la phase saisie. Affiche
/// un spinner blanc tant que l'upload est en cours ; le tap reste inerte
/// pendant l'analyse pour éviter une double soumission.
class BtnLancerAnalyse extends StatelessWidget {
  const BtnLancerAnalyse({
    required this.isAnalyzing,
    required this.onTap,
    super.key,
  });

  final bool isAnalyzing;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppDimens.buttonHeight,
      child: ElevatedButton(
        onPressed: isAnalyzing ? null : onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.5),
          elevation: 0,
          shape: const RoundedRectangleBorder(
            borderRadius: AppDimens.brButton,
          ),
        ),
        child: isAnalyzing
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.onPrimary,
                ),
              )
            : Text("Lancer l'analyse", style: AppTextStyles.button),
      ),
    );
  }
}
