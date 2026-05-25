import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_text_styles.dart';

/// Titre de section en MAJUSCULES utilisé dans la page de confirmation
/// de livraison (typiquement « Étapes complétées »). Style allégé par
/// rapport au titre des sections d'une mission active.
class TitreSectionConfirme extends StatelessWidget {
  const TitreSectionConfirme(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: AppTextStyles.labelSmall.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: AppColors.textSecondary,
        letterSpacing: 0.3,
      ),
    );
  }
}
