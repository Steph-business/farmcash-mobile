import 'package:flutter/material.dart';

import '../../../../models/annonce_achat.dart';
import '../../../../theme/app_dimens.dart';
import '_constantes_accueil_coop.dart';
import 'carte_demande_acheteur_coop.dart';
import 'section_head_coop.dart';

/// Section horizontale listant les annonces d'achat ciblant la coop
/// (acheteurs qui cherchent à acheter dans la zone / catégorie de la
/// coopérative). Header avec "Voir tout" vers les offres reçues.
class SectionAcheteursCoop extends StatelessWidget {
  const SectionAcheteursCoop({
    super.key,
    required this.annonces,
    required this.onVoirTout,
  });

  final List<AnnonceAchat> annonces;
  final VoidCallback onVoirTout;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeadCoop(
          titre: 'Acheteurs qui ciblent ma coop',
          lienTexte: 'Voir tout',
          onLien: onVoirTout,
          accentDot: kWarnAccentCoop,
        ),
        SizedBox(
          height: 138,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: annonces.length,
            separatorBuilder: (_, __) => AppDimens.hGap12,
            itemBuilder: (context, i) =>
                CarteDemandeAcheteurCoop(annonce: annonces[i]),
          ),
        ),
      ],
    );
  }
}
