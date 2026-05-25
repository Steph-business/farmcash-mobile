import 'package:flutter/material.dart';

import '../../../../theme/app_text_styles.dart';

/// Titre de section dans le formulaire de reception d'un lot
/// ("Source du lot", "Details du lot").
class TitreSectionLot extends StatelessWidget {
  const TitreSectionLot(this.label, {super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: AppTextStyles.titleSmall.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}
