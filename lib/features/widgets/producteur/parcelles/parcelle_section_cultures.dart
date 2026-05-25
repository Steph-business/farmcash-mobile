import 'package:flutter/material.dart';

import '../../../../models/parcelle.dart';
import '../../../../models/produit.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';
import 'parcelle_bouton_secondaire.dart';
import 'parcelle_culture_card.dart';

/// Section "Cultures sur cette parcelle" : titre + liste de cartes
/// `ParcelleCultureCard` + bouton "Ajouter une culture".
///
/// Affiche un message gris si la liste est vide.
class ParcelleSectionCultures extends StatelessWidget {
  const ParcelleSectionCultures({
    required this.cultures,
    required this.produitsById,
    required this.onAjouter,
    super.key,
  });

  final List<Culture> cultures;
  final Map<String, Produit> produitsById;
  final VoidCallback onAjouter;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: AppDimens.space12),
          child: Text(
            'Cultures sur cette parcelle',
            style: AppTextStyles.titleSmall.copyWith(
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        if (cultures.isEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: AppDimens.space12),
            child: Text(
              'Aucune culture enregistrée sur cette parcelle.',
              style: AppTextStyles.bodySmall,
            ),
          )
        else
          for (final c in cultures)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: ParcelleCultureCard(
                culture: c,
                produit: c.produitId.isNotEmpty
                    ? produitsById[c.produitId]
                    : null,
              ),
            ),
        const SizedBox(height: 6),
        ParcelleBoutonSecondaire(
          label: '+ Ajouter une culture',
          onTap: onAjouter,
        ),
      ],
    );
  }
}
