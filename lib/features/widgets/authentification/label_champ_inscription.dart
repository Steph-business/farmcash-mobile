import 'package:flutter/material.dart';

import '../../../theme/app_dimens.dart';
import '../../../theme/app_text_styles.dart';

/// Wrapper « label au-dessus + champ » utilisé pour uniformiser la
/// composition des inputs du formulaire d'inscription.
///
/// Le [label] est rendu en `labelMedium` et le [child] reçoit l'input
/// effectif (TextField, DropdownButtonFormField, etc.).
class LabelChampInscription extends StatelessWidget {
  const LabelChampInscription({
    required this.label,
    required this.child,
    super.key,
  });

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.labelMedium),
        AppDimens.vGap8,
        child,
      ],
    );
  }
}
