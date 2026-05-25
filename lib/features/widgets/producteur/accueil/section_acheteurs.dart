import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../models/annonce_achat.dart';
import '../../../../routing/route_names.dart';
import '../../../../theme/app_dimens.dart';
import 'carte_demande_acheteur.dart';
import 'section_head.dart';

/// Section "Acheteurs qui cherchent" de l'accueil producteur : carrousel
/// horizontal des annonces d'achat ouvertes (filtrées côté client sur les
/// produits que le farmer cultive).
class SectionAcheteurs extends StatelessWidget {
  const SectionAcheteurs({super.key, required this.annonces});

  final List<AnnonceAchat> annonces;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHead(
          titre: 'Acheteurs qui cherchent',
          lienTexte: 'Voir tout',
          onLien: () =>
              context.push(RouteNames.producteurDemandesAchatPath),
        ),
        SizedBox(
          height: 130,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: annonces.length,
            separatorBuilder: (_, __) => AppDimens.hGap12,
            itemBuilder: (context, i) => CarteDemandeAcheteur(annonce: annonces[i]),
          ),
        ),
      ],
    );
  }
}
