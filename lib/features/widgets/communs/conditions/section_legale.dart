import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';

/// Section d'un document légal (CGU, politique de confidentialité).
///
/// Affiche un titre numéroté en gras suivi de paragraphes. Chaque
/// paragraphe est espacé de 8px et utilise `bodySmall` avec interligne 1.6
/// pour une lecture confortable sur mobile.
class SectionLegale extends StatelessWidget {
  /// Construit une section.
  const SectionLegale({
    super.key,
    required this.numero,
    required this.titre,
    required this.paragraphes,
  });

  /// Numéro de la section (ex. "1", "2.1").
  final String numero;

  /// Titre de la section.
  final String titre;

  /// Liste de paragraphes de texte plein.
  final List<String> paragraphes;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: AppDimens.space16),
      padding: const EdgeInsets.all(AppDimens.space16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: AppDimens.brCard,
        border: Border.all(
          color: AppColors.border,
          width: AppDimens.borderThin,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$numero. $titre',
            style: AppTextStyles.titleSmall.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.text,
            ),
          ),
          AppDimens.vGap8,
          for (var i = 0; i < paragraphes.length; i++) ...[
            Text(
              paragraphes[i],
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
                height: 1.6,
              ),
            ),
            if (i < paragraphes.length - 1) const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }
}
