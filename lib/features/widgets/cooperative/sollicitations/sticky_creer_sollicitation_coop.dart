import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';

/// Barre sticky en bas de la page création sollicitation avec un seul
/// bouton plein « Envoyer la sollicitation (X destinataires) ». Désactivé
/// (opacité 0.6) si aucune audience n'est sélectionnée. Pendant l'envoi,
/// affiche un spinner blanc.
class StickyCreerSollicitationCoop extends StatelessWidget {
  const StickyCreerSollicitationCoop({
    required this.count,
    required this.isSubmitting,
    required this.onTap,
    super.key,
  });

  final int count;
  final bool isSubmitting;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
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
      padding: const EdgeInsets.fromLTRB(24, 14, 24, 12),
      child: SizedBox(
        width: double.infinity,
        child: InkWell(
          onTap: (isSubmitting || count == 0) ? null : onTap,
          borderRadius: BorderRadius.circular(AppDimens.radiusCard),
          child: Opacity(
            opacity: count == 0 ? 0.6 : 1,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(AppDimens.radiusCard),
                border: Border.all(
                  color: AppColors.primary,
                  width: AppDimens.borderThin,
                ),
              ),
              alignment: Alignment.center,
              child: isSubmitting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      'Envoyer la sollicitation ($count destinataires)',
                      style: AppTextStyles.button.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
