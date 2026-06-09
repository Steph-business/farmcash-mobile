import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';

/// Barre sticky en bas de la page détail d'une annonce producteur : bouton
/// « Pause/Réactiver » (outline) + bouton « Modifier » (primary).
class StickyButtonsAnnonce extends StatelessWidget {
  const StickyButtonsAnnonce({
    required this.paused,
    required this.onPause,
    required this.onModifier,
    super.key,
  });

  final bool paused;
  final VoidCallback onPause;
  final VoidCallback onModifier;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        // Shadow soft top → effet plateau flottant qui décolle le sticky du
        // contenu scrollable au-dessus.
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
        border: const Border(
          top: BorderSide(
            color: AppColors.border,
            width: AppDimens.borderThin,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        minimum: const EdgeInsets.only(bottom: 8),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          child: Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: onPause,
                  borderRadius: AppDimens.brButton,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: AppDimens.brButton,
                      border: Border.all(
                        color: AppColors.border,
                        width: AppDimens.borderThin,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      paused ? 'Réactiver' : 'Mettre en pause',
                      style: AppTextStyles.button.copyWith(
                        fontSize: 14,
                        color: AppColors.text,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: InkWell(
                  onTap: onModifier,
                  borderRadius: AppDimens.brButton,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: AppDimens.brButton,
                      border: Border.all(
                        color: AppColors.primary,
                        width: AppDimens.borderThin,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'Modifier',
                      style: AppTextStyles.button.copyWith(
                        fontSize: 14,
                        color: AppColors.onPrimary,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
