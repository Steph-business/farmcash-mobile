import 'package:flutter/material.dart';

import '../../../../theme/app_text_styles.dart';

/// Titre de section bold utilisé dans la page « Profil vendeur ».
class TitreSectionVendeur extends StatelessWidget {
  const TitreSectionVendeur(this.titre, {super.key});

  /// Texte du titre.
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
