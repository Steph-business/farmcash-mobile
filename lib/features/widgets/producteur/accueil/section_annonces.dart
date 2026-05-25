import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../models/annonce_vente.dart';
import '../../../../routing/route_names.dart';
import '../../../../theme/app_dimens.dart';
import 'annonce_card.dart';
import 'section_head.dart';

/// Section "Mes annonces" de l'accueil producteur : carrousel horizontal
/// des annonces de vente du farmer (jusqu'à 5). Tappable pour ouvrir
/// l'écran "Mes publications" complet.
class SectionAnnonces extends StatelessWidget {
  const SectionAnnonces({super.key, required this.annonces});

  final List<AnnonceVente> annonces;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHead(
          titre: 'Mes annonces',
          lienTexte: 'Voir tout',
          onLien: () =>
              context.push(RouteNames.producteurMesPublicationsPath),
        ),
        SizedBox(
          height: 256,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: annonces.length,
            separatorBuilder: (_, __) => AppDimens.hGap12,
            itemBuilder: (context, i) => AnnonceCard(annonce: annonces[i]),
          ),
        ),
      ],
    );
  }
}
