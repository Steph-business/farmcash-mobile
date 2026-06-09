import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';

/// Bouton sticky en bas de page pour les actions wallet (Recharger / Retirer).
///
/// Inclut un conteneur avec bordure supérieure (séparateur visuel) et
/// remplace le label par un `CircularProgressIndicator` quand [busy] est vrai.
class BoutonStickyAction extends StatelessWidget {
  const BoutonStickyAction({
    super.key,
    required this.label,
    required this.onTap,
    this.busy = false,
  });

  /// Libellé affiché.
  final String label;

  /// Callback déclenché au tap (désactivé si [busy] est vrai).
  final VoidCallback onTap;

  /// État chargement — désactive le bouton et affiche un loader centré.
  final bool busy;

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
          child: SizedBox(
            height: AppDimens.buttonHeight,
            width: double.infinity,
            child: ElevatedButton(
              onPressed: busy ? null : onTap,
              child: busy
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.2,
                        color: AppColors.onPrimary,
                      ),
                    )
                  : Text(label, style: AppTextStyles.button),
            ),
          ),
        ),
      ),
    );
  }
}
