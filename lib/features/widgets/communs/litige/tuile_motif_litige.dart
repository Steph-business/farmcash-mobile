import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';

/// Ligne radio d'un motif de litige : label à gauche + pastille
/// de sélection à droite. Visuel cohérent avec `TuileOptionRadio` du
/// dossier paramètres mais simplifié (pas d'icône, pas de sous-titre).
class TuileMotifLitige extends StatelessWidget {
  /// Construit la ligne.
  const TuileMotifLitige({
    super.key,
    required this.label,
    required this.selectionne,
    required this.onTap,
  });

  /// Libellé du motif.
  final String label;

  /// Vrai si c'est le motif courant.
  final bool selectionne;

  /// Callback de tap.
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimens.space16,
          vertical: 14,
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontSize: 14,
                  fontWeight:
                      selectionne ? FontWeight.w700 : FontWeight.w500,
                  color: AppColors.text,
                ),
              ),
            ),
            const SizedBox(width: 8),
            _Pastille(selectionne: selectionne),
          ],
        ),
      ),
    );
  }
}

class _Pastille extends StatelessWidget {
  const _Pastille({required this.selectionne});
  final bool selectionne;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color:
            selectionne ? AppColors.primary : AppColors.background,
        border: Border.all(
          color: selectionne
              ? AppColors.primary
              : AppColors.borderStrong,
          width: selectionne ? 0 : 1.5,
        ),
      ),
      alignment: Alignment.center,
      child: selectionne
          ? const Icon(Icons.check, size: 14, color: AppColors.onPrimary)
          : null,
    );
  }
}
