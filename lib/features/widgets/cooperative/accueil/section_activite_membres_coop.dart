import 'package:flutter/material.dart';

import '../../../../models/annonce_vente.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '_constantes_accueil_coop.dart';
import 'ligne_activite_membre_coop.dart';
import 'section_head_coop.dart';

/// Section "Activité récente des membres" : liste verticale d'annonces de
/// vente publiées par les membres (en attente de validation). Header avec
/// "Voir tout" pointant vers la liste complète du marché coop.
class SectionActiviteMembresCoop extends StatelessWidget {
  const SectionActiviteMembresCoop({
    super.key,
    required this.annonces,
    required this.onVoirTout,
  });

  final List<AnnonceVente> annonces;
  final VoidCallback onVoirTout;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeadCoop(
          titre: 'Activité récente des membres',
          lienTexte: 'Voir tout',
          onLien: onVoirTout,
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: kBrCardCoop,
            border: Border.all(
              color: AppColors.border,
              width: AppDimens.borderThin,
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              for (var i = 0; i < annonces.length; i++) ...[
                LigneActiviteMembreCoop(annonce: annonces[i]),
                if (i < annonces.length - 1)
                  const Divider(
                    height: 1,
                    thickness: 1,
                    color: AppColors.border,
                  ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
