import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_text_styles.dart';

/// Étiquette d'un champ de formulaire dans la création de sollicitation
/// (« Prix minimum offert », « Date limite de réponse »…). Texte fin
/// gris au-dessus de l'input correspondant.
class FieldLabelCreerSollicitationCoop extends StatelessWidget {
  const FieldLabelCreerSollicitationCoop({
    required this.label,
    super.key,
  });

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: AppTextStyles.labelSmall.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: AppColors.textSecondary,
      ),
    );
  }
}
