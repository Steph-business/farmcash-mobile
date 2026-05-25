import 'package:flutter/material.dart';

import '../../../../theme/app_text_styles.dart';

/// Titre de section local à la page "Ma coopérative".
class TitreSectionCooperative extends StatelessWidget {
  const TitreSectionCooperative(this.titre, {super.key});

  final String titre;

  @override
  Widget build(BuildContext context) {
    return Text(
      titre,
      style: AppTextStyles.titleSmall.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}
