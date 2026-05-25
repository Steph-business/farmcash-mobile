import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';

const Color _kPrimarySoft = Color(0xFFE8F5E9);

/// Bouton carré "action rapide" du Centre d'aide — icône colorée + label
/// court. Utilisé en triplet (Chat / Appeler / WhatsApp) en haut de la
/// page.
class BoutonActionRapideAide extends StatelessWidget {
  /// Construit le bouton.
  const BoutonActionRapideAide({
    super.key,
    required this.icone,
    required this.label,
    required this.onTap,
  });

  /// Icône principale.
  final IconData icone;

  /// Label court (1 mot).
  final String label;

  /// Callback de tap.
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppDimens.brCard,
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: AppDimens.space16,
          horizontal: 8,
        ),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: AppDimens.brCard,
          border: Border.all(
            color: AppColors.border,
            width: AppDimens.borderThin,
          ),
        ),
        child: Column(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: _kPrimarySoft,
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: Icon(icone, size: 18, color: AppColors.primary),
            ),
            AppDimens.vGap8,
            Text(
              label,
              style: AppTextStyles.labelMedium.copyWith(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
