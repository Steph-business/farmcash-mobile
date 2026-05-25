import 'package:flutter/material.dart';

import '../../../../theme/app_dimens.dart';
import '../../communs/profil/carte_stat_profil.dart';

/// Ligne de 3 stats du profil coopérative : ventes cumulées, distributions,
/// avances actives. Utilise [CarteStatProfil] (commun) pour chaque cellule.
class LigneStatsCooperative extends StatelessWidget {
  /// Construit la ligne.
  const LigneStatsCooperative({
    super.key,
    required this.ventesCumulees,
    required this.nbDistributions,
    required this.nbAvancesActives,
  });

  /// Valeur formatée des ventes cumulées (ex : "—" si non disponible).
  final String ventesCumulees;

  /// Nombre de distributions effectuées (payout batches).
  final int nbDistributions;

  /// Nombre d'avances actives (statut paid).
  final int nbAvancesActives;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: CarteStatProfil(
              valeur: ventesCumulees,
              libelle: 'Ventes cumulées',
            ),
          ),
          AppDimens.hGap8,
          Expanded(
            child: CarteStatProfil(
              valeur: '$nbDistributions',
              libelle: 'Distributions',
            ),
          ),
          AppDimens.hGap8,
          Expanded(
            child: CarteStatProfil(
              valeur: '$nbAvancesActives',
              libelle: 'Avances actives',
            ),
          ),
        ],
      ),
    );
  }
}
