import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';
import 'icone_tuile_profil.dart';

/// Tuile (row) iOS-Settings utilisée dans toutes les pages profil :
/// icône carrée + label + sous-titre optionnel + texte trailing (rare,
/// principalement pour le solde wallet) + chevron.
///
/// Si [trailingWidget] est fourni il remplace le bloc texte-trailing et
/// le chevron (utile pour un `Switch.adaptive`). Si [montrerChevron] est
/// faux, le chevron est masqué même sans `trailingWidget` — utile pour
/// les rows non-interactives.
class TuileProfil extends StatelessWidget {
  /// Construit la tuile profil.
  const TuileProfil({
    super.key,
    required this.icone,
    required this.label,
    this.sousTitre,
    this.trailingTexte,
    this.trailingWidget,
    this.accent = false,
    this.montrerChevron = true,
    this.onTap,
  });

  /// Icône à gauche.
  final IconData icone;

  /// Texte principal de la ligne.
  final String label;

  /// Texte secondaire optionnel (sous le label).
  final String? sousTitre;

  /// Texte à droite (ex : montant wallet). Affiché avant le chevron.
  final String? trailingTexte;

  /// Widget remplaçant le chevron par défaut (ex : `Switch.adaptive`).
  final Widget? trailingWidget;

  /// Si vrai, icône en vert primaire ; sinon en gris.
  final bool accent;

  /// Si vrai (défaut), chevron affiché à droite quand pas de trailingWidget.
  final bool montrerChevron;

  /// Callback de tap sur la ligne. Si null, la ligne reste non-cliquable.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final hasSub = sousTitre != null && sousTitre!.isNotEmpty;
    final hasTexte = trailingTexte != null && trailingTexte!.isNotEmpty;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimens.space16,
          vertical: 14,
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
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.text,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (hasSub) ...[
                    const SizedBox(height: 2),
                    Text(
                      sousTitre!,
                      style: AppTextStyles.bodySmall.copyWith(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            if (trailingWidget != null)
              trailingWidget!
            else ...[
              if (hasTexte) ...[
                AppDimens.hGap8,
                Text(
                  trailingTexte!,
                  style: AppTextStyles.bodySmall.copyWith(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(width: 6),
              ] else
                AppDimens.hGap8,
              if (montrerChevron)
                const Icon(
                  Icons.chevron_right,
                  size: 18,
                  color: AppColors.textSubtle,
                ),
            ],
          ],
        ),
      ),
    );
  }
}
