import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';
import 'hero_identite.dart' show kHeroPrimarySoft;

/// Tuile de paramètres : icône carrée + label + sous-label optionnel +
/// chevron de droite (style iOS Settings).
///
/// Si [iconGreen] est vrai, l'icône utilise la palette verte primaire
/// (fond `kHeroPrimarySoft`, icône `AppColors.primary`) — utilisé pour
/// les actions liées au compte / au profil. Sinon, fond gris doux et
/// icône `textSecondary` (paramètres applicatifs / support).
///
/// [trailing] remplace le chevron par défaut (utile pour un texte "Voir"
/// ou un Switch).
class TuileSettings extends StatelessWidget {
  /// Construit la tuile.
  const TuileSettings({
    super.key,
    required this.icon,
    required this.label,
    this.sub,
    this.iconGreen = false,
    required this.onTap,
    this.trailing,
  });

  /// Icône affichée à gauche dans le carré coloré.
  final IconData icon;

  /// Texte principal de la ligne.
  final String label;

  /// Texte secondaire optionnel (sous le label).
  final String? sub;

  /// Style vert (true) ou gris (false) pour le carré d'icône.
  final bool iconGreen;

  /// Callback de tap sur la ligne entière.
  final VoidCallback onTap;

  /// Widget à droite remplaçant le chevron par défaut.
  final Widget? trailing;

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
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: iconGreen ? kHeroPrimarySoft : AppColors.surfaceSoft,
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: Icon(
                icon,
                size: 18,
                color: iconGreen
                    ? AppColors.primary
                    : AppColors.textSecondary,
              ),
            ),
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
                      fontWeight: FontWeight.w600,
                      color: AppColors.text,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (sub != null && sub!.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      sub!,
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
            const SizedBox(width: 6),
            trailing ??
                const Icon(
                  Icons.chevron_right,
                  size: 18,
                  color: AppColors.textSubtle,
                ),
          ],
        ),
      ),
    );
  }
}
