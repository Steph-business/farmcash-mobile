import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../communs/tile_raccourci.dart';
import '_constantes_accueil_coop.dart';

/// Grille 2×2 de raccourcis de l'accueil coopérative : Collecte (ou Voir
/// membres si le hero Collecte est déjà affiché), Inviter farmer, Verser
/// avance, Publier marché. Chaque tile a une couleur d'accent dédiée.
class GrilleRaccourcisCoop extends StatelessWidget {
  const GrilleRaccourcisCoop({
    super.key,
    required this.nbAValider,
    required this.nbMembres,
    required this.heroAffiche,
    required this.onPremiere,
    required this.onInviter,
    required this.onVerserAvance,
    required this.onPublierMarche,
  });

  /// Combine annonces vente PENDING + prévisions PENDING.
  final int nbAValider;
  final int nbMembres;

  /// Si le CTA hero "Collecte" est affiché, la tile "Collecte" est
  /// remplacée par "Voir les membres" pour éviter la redondance.
  final bool heroAffiche;

  /// Callback de la première tile (Voir les membres si heroAffiche, sinon
  /// Collecte du jour).
  final VoidCallback onPremiere;
  final VoidCallback onInviter;
  final VoidCallback onVerserAvance;
  final VoidCallback onPublierMarche;

  @override
  Widget build(BuildContext context) {
    final TileRaccourci tilePremiere = heroAffiche
        ? TileRaccourci(
            icon: Icons.groups_outlined,
            titre: 'Voir les membres',
            sousTitre: nbMembres > 0
                ? '$nbMembres ${nbMembres > 1 ? "membres actifs" : "membre actif"}'
                : 'aucun membre',
            accentColor: AppColors.primary,
            onTap: onPremiere,
          )
        : TileRaccourci(
            icon: Icons.assignment_outlined,
            titre: 'Collecte du jour',
            sousTitre: nbAValider > 0
                ? '$nbAValider produits à peser'
                : 'rien à peser',
            badge: nbAValider > 0 ? '$nbAValider' : null,
            accentColor: AppColors.primary,
            onTap: onPremiere,
          );

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 1.25,
      children: [
        tilePremiere,
        TileRaccourci(
          icon: Icons.person_add_outlined,
          titre: 'Inviter un farmer',
          sousTitre: 'par téléphone',
          accentColor: kInfoAccentCoop,
          onTap: onInviter,
        ),
        TileRaccourci(
          icon: Icons.payments_outlined,
          titre: 'Verser une avance',
          sousTitre: 'à un membre',
          accentColor: kWarnAccentCoop,
          onTap: onVerserAvance,
        ),
        TileRaccourci(
          icon: Icons.storefront_outlined,
          titre: 'Publier sur marché',
          sousTitre: 'stock direct',
          accentColor: kHighlightAccentCoop,
          onTap: onPublierMarche,
        ),
      ],
    );
  }
}
