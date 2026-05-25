import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';

/// Bouton « Enregistrer le membre » figé en bas du formulaire. Affiche
/// un loader pendant l'envoi et un libellé désactivé sinon.
class BoutonStickyEnregistrerManaged extends StatelessWidget {
  const BoutonStickyEnregistrerManaged({
    super.key,
    required this.busy,
    required this.onTap,
  });

  final bool busy;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppDimens.pagePaddingH,
          AppDimens.space8,
          AppDimens.pagePaddingH,
          AppDimens.space16,
        ),
        child: SizedBox(
          width: double.infinity,
          height: AppDimens.buttonHeight,
          child: Material(
            color: busy
                ? AppColors.primary.withValues(alpha: 0.7)
                : AppColors.primary,
            borderRadius: AppDimens.brButton,
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: busy ? null : onTap,
              child: Center(
                child: busy
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        'Enregistrer le membre',
                        style: AppTextStyles.button.copyWith(
                          color: AppColors.onPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
