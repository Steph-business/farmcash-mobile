import 'package:flutter/material.dart';

import '../../../../theme/app_text_styles.dart';

/// Titre de section dans la page Stock (« Entrepôts », « Lots récents »).
class TitreSectionStock extends StatelessWidget {
  const TitreSectionStock({super.key, required this.label});

  /// Libellé de la section.
  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: AppTextStyles.titleSmall.copyWith(
        fontSize: 15,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
