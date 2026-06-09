import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';

/// Bouton sticky en bas de la page de creation de publication. Spinner en
/// mode busy, bouton primaire "Publier la publication" sinon.
class BoutonStickyPublication extends StatelessWidget {
  const BoutonStickyPublication({
    required this.busy,
    required this.onTap,
    this.label,
    super.key,
  });

  final bool busy;
  final VoidCallback onTap;

  /// Libellé du bouton. Défaut : « Publier la publication ». Le flow
  /// 2-étapes (refonte 2026-06-06) override avec « Suivant · X annonce(s) »
  /// ou « Publier sur le marché ».
  final String? label;

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
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
          child: SizedBox(
            width: double.infinity,
            child: InkWell(
              onTap: busy ? null : onTap,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(12),
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
                        label ?? 'Publier la publication',
                        style: AppTextStyles.button.copyWith(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.onPrimary,
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
