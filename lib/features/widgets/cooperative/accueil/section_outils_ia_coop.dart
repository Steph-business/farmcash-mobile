import 'package:flutter/material.dart';

import '../../../../theme/app_dimens.dart';
import '_constantes_accueil_coop.dart';
import 'carte_outil_ia_coop.dart';
import 'section_head_coop.dart';

/// Section "Outils intelligents" : grille 2 colonnes de cards photo
/// (assistant gestion, conseils saison). Cards V1 sans navigation réelle
/// (snackbars "à venir" depuis la page parente).
class SectionOutilsIaCoop extends StatelessWidget {
  const SectionOutilsIaCoop({
    super.key,
    required this.onAssistant,
    required this.onConseils,
  });

  final VoidCallback onAssistant;
  final VoidCallback onConseils;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionHeadCoop(titre: 'Outils intelligents'),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: CarteOutilIaCoop(
                photoUrl: kPhotoAssistantGestionCoop,
                badgeIcon: Icons.chat_bubble_outline,
                titre: 'Assistant gestion',
                sousTitre: 'Pose tes questions sur la gestion coop',
                onTap: onAssistant,
              ),
            ),
            AppDimens.hGap12,
            Expanded(
              child: CarteOutilIaCoop(
                photoUrl: kPhotoConseilsSaisonCoop,
                badgeIcon: Icons.trending_up,
                titre: 'Conseils saison',
                sousTitre: 'Quels produits valoriser ce mois-ci',
                onTap: onConseils,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
