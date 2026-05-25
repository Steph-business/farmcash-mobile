import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';

/// Saisie visuelle d'un code PIN à 4 caractères. Pour l'instant purement
/// visuel : pas de pavé numérique fonctionnel — les dots sont rendus selon
/// [remplis] (par défaut 2/4 conformément aux maquettes).
class SaisiePin extends StatelessWidget {
  const SaisiePin({
    super.key,
    this.remplis = 2,
    this.total = 4,
  });

  /// Nombre de dots remplis (affichés avec le symbole `●`).
  final int remplis;

  /// Nombre total de dots affichés.
  final int total;

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[];
    for (var i = 0; i < total; i++) {
      if (i > 0) children.add(const SizedBox(width: 14));
      children.add(_PinDot(filled: i < remplis));
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: children,
      ),
    );
  }
}

class _PinDot extends StatelessWidget {
  const _PinDot({required this.filled});

  final bool filled;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 54,
      decoration: BoxDecoration(
        color: filled ? AppColors.background : AppColors.surfaceSoft,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: filled ? AppColors.primary : AppColors.border,
          width: AppDimens.borderThin,
        ),
      ),
      alignment: Alignment.center,
      child: filled
          ? Text(
              '●',
              style: AppTextStyles.displayLarge.copyWith(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppColors.text,
              ),
            )
          : Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.textSubtle.withValues(alpha: 0.4),
              ),
            ),
    );
  }
}
