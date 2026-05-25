import 'package:flutter/material.dart';

import '../../../../models/livraison.dart';
import 'carte_mission.dart';
import 'section_head_transporteur.dart';

/// Bloc générique réutilisé pour "Missions disponibles" et "Prochains
/// chargements" — en-tête optionnel + liste verticale de [CarteMission].
///
/// [avecBoutonAccepter] détermine si chaque carte propose un CTA "Accepter"
/// (cas missions ouvertes) ou pas (cas missions déjà acceptées).
class SectionMissions extends StatelessWidget {
  const SectionMissions({
    super.key,
    required this.titre,
    required this.missions,
    required this.avecBoutonAccepter,
    this.lienTexte,
    this.onLienTap,
  });

  final String titre;
  final String? lienTexte;
  final VoidCallback? onLienTap;
  final List<Livraison> missions;
  final bool avecBoutonAccepter;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeadTransporteur(
          titre: titre,
          lienTexte: lienTexte,
          onLienTap: onLienTap,
        ),
        for (var i = 0; i < missions.length; i++) ...[
          CarteMission(
            mission: missions[i],
            avecBoutonAccepter: avecBoutonAccepter,
          ),
          if (i < missions.length - 1) const SizedBox(height: 10),
        ],
      ],
    );
  }
}
