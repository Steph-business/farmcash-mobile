import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';
import 'icone_tuile_profil.dart';

/// Tuile profil avec un `Switch.adaptive` à droite à la place du chevron.
///
/// Utilisée par exemple par la coopérative pour "Distribution automatique"
/// ou par le transporteur pour "Disponible pour livrer".
class TuileToggleProfil extends StatelessWidget {
  /// Construit la tuile toggle.
  const TuileToggleProfil({
    super.key,
    required this.icone,
    required this.label,
    required this.valeur,
    required this.onChanged,
    this.sousTitre,
    this.accent = false,
  });

  /// Icône Material à gauche.
  final IconData icone;

  /// Texte principal de la ligne.
  final String label;

  /// Sous-titre optionnel.
  final String? sousTitre;

  /// État courant du switch.
  final bool valeur;

  /// Callback déclenché au changement de valeur.
  final ValueChanged<bool> onChanged;

  /// Si vrai, icône en vert primaire ; sinon en gris.
  final bool accent;

  @override
  Widget build(BuildContext context) {
    final hasSub = sousTitre != null && sousTitre!.isNotEmpty;
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.space16,
        vertical: 10,
      ),
      child: Row(
        children: [
          IconeTuileProfil(icone: icone, accent: accent),
          AppDimens.hGap12,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.text,
                  ),
                ),
                if (hasSub) ...[
                  const SizedBox(height: 2),
                  Text(
                    sousTitre!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodySmall.copyWith(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          AppDimens.hGap8,
          Switch.adaptive(
            value: valeur,
            onChanged: onChanged,
            activeTrackColor: AppColors.primary,
          ),
        ],
      ),
    );
  }
}
