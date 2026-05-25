import 'package:flutter/material.dart';

import '../../../../theme/app_text_styles.dart';

/// Titre de section sur la page de réponse à une sollicitation.
///
/// 14px gras, sans padding (le caller gère l'espacement vertical).
class SollicitationSectionTitle extends StatelessWidget {
  const SollicitationSectionTitle({required this.title, super.key});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: AppTextStyles.titleSmall.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}
