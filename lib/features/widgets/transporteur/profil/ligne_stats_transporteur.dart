import 'package:flutter/material.dart';

import '../../../../theme/app_dimens.dart';
import '../../communs/profil/carte_stat_profil.dart';

/// Ligne de 3 stats du profil transporteur : livraisons, gains 30j, taux
/// de succès. Chaque cellule utilise une [CarteStatProfil] (commune).
class LigneStatsTransporteur extends StatelessWidget {
  /// Construit la ligne.
  const LigneStatsTransporteur({
    super.key,
    required this.livrees,
    required this.gainsFormates,
    required this.tauxSucces,
  });

  /// Nombre de missions livrées.
  final int livrees;

  /// Gains sur 30 jours déjà formatés (ex : "456 K").
  final String gainsFormates;

  /// Taux de succès formaté (ex : "98 %").
  final String tauxSucces;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: CarteStatProfil(
            valeur: livrees.toString(),
            libelle: 'Livraisons',
          ),
        ),
        AppDimens.hGap8,
        Expanded(
          child: CarteStatProfil(
            valeur: gainsFormates,
            libelle: 'Gains 30 j',
          ),
        ),
        AppDimens.hGap8,
        Expanded(
          child: CarteStatProfil(
            valeur: tauxSucces,
            libelle: 'Taux succès',
          ),
        ),
      ],
    );
  }
}
