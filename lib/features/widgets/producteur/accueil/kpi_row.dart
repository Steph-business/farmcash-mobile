import 'package:flutter/material.dart';

import '../../../../theme/app_dimens.dart';
import 'accueil_helpers.dart';
import 'kpi_card.dart';

/// Trio horizontal de KPI cards en tête de l'accueil producteur : solde
/// wallet, nombre d'annonces actives, nombre de commandes en cours.
class KpiRow extends StatelessWidget {
  const KpiRow({
    super.key,
    required this.solde,
    required this.devise,
    required this.annoncesActives,
    required this.commandesEnCours,
  });

  final double solde;
  final String devise;
  final int annoncesActives;
  final int commandesEnCours;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: KpiCard(
            icon: Icons.account_balance_wallet_outlined,
            valeur: formatMontantAccueil(solde, devise),
            libelle: 'Solde wallet',
          ),
        ),
        AppDimens.hGap8,
        Expanded(
          child: KpiCard(
            icon: Icons.list_alt_outlined,
            valeur: annoncesActives.toString(),
            libelle: 'Annonces',
          ),
        ),
        AppDimens.hGap8,
        Expanded(
          child: KpiCard(
            icon: Icons.description_outlined,
            valeur: commandesEnCours.toString(),
            libelle: 'Commandes',
          ),
        ),
      ],
    );
  }
}
