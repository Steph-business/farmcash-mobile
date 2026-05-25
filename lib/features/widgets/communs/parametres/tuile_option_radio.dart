import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';

/// Ligne d'option style "single-choice" : icône optionnelle + label + sous-
/// titre + indicateur de sélection (cercle plein vert si sélectionné).
///
/// Utilisée par la page Langue, et plus largement par toute page de
/// sélection unique (devise, thème, etc.). Le tap déclenche [onTap]
/// uniquement si non déjà sélectionné — pas de re-sélection inutile.
class TuileOptionRadio extends StatelessWidget {
  /// Construit la ligne d'option radio.
  const TuileOptionRadio({
    super.key,
    required this.label,
    this.sousTitre,
    this.icone,
    required this.selectionnee,
    required this.onTap,
  });

  /// Texte principal affiché à gauche.
  final String label;

  /// Texte secondaire optionnel sous le label.
  final String? sousTitre;

  /// Icône optionnelle (drapeau, etc.) — si null, pas de carré à gauche.
  final IconData? icone;

  /// Vrai si cette option est l'option courante.
  final bool selectionnee;

  /// Callback appelé seulement si non déjà sélectionnée.
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: selectionnee ? null : onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimens.space16,
          vertical: 14,
        ),
        child: Row(
          children: [
            if (icone != null) ...[
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.surfaceSoft,
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: Icon(
                  icone,
                  size: 18,
                  color: AppColors.textSecondary,
                ),
              ),
              AppDimens.hGap12,
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.text,
                    ),
                  ),
                  if (sousTitre != null && sousTitre!.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      sousTitre!,
                      style: AppTextStyles.bodySmall.copyWith(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 6),
            _PastilleSelection(selectionnee: selectionnee),
          ],
        ),
      ),
    );
  }
}

class _PastilleSelection extends StatelessWidget {
  const _PastilleSelection({required this.selectionnee});

  final bool selectionnee;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: selectionnee ? AppColors.primary : AppColors.background,
        border: Border.all(
          color: selectionnee
              ? AppColors.primary
              : AppColors.borderStrong,
          width: selectionnee ? 0 : 1.5,
        ),
      ),
      alignment: Alignment.center,
      child: selectionnee
          ? const Icon(Icons.check, size: 13, color: AppColors.onPrimary)
          : null,
    );
  }
}
