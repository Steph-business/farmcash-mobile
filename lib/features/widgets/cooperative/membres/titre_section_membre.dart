import 'package:flutter/material.dart';

import '../../../../theme/app_text_styles.dart';

/// Titre de section dans la fiche membre.
class TitreSectionMembre extends StatelessWidget {
  const TitreSectionMembre({super.key, required this.titre});

  /// Libellé du titre.
  final String titre;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        titre,
        style: AppTextStyles.titleSmall.copyWith(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
