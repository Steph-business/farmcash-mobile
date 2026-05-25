import 'package:flutter/material.dart';

import '../../../../theme/app_text_styles.dart';

/// Titre de section dans la fiche publication coop (« Quantite agregee »,
/// « Prix », « Statut », « Ma contribution »).
class SectionTitlePublicationCoop extends StatelessWidget {
  const SectionTitlePublicationCoop(this.titre, {super.key});

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
