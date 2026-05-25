import 'package:flutter/material.dart';

import '../../../../theme/app_dimens.dart';
import 'carte_demande_achat.dart';
import 'compteur_demandes_actives.dart';
import 'demande_achat_modeles.dart';
import 'filtres_cultures_chips.dart';

/// Corps principal de la page demandes d'achat : compteur, filtres,
/// cartes. Pas de scaffold ici — c'est la page qui l'apporte.
class CorpsListeDemandesAchat extends StatelessWidget {
  const CorpsListeDemandesAchat({
    super.key,
    required this.items,
    required this.activeFilter,
    required this.onFilterChange,
  });

  final List<MockDemande> items;
  final String activeFilter;
  final ValueChanged<String> onFilterChange;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      children: [
        CompteurDemandesActives(actives: items.length),
        AppDimens.vGap16,
        FiltresCulturesChips(active: activeFilter, onChange: onFilterChange),
        AppDimens.vGap16,
        for (final d in items) ...[
          CarteDemandeAchat(demande: d),
          const SizedBox(height: 12),
        ],
      ],
    );
  }
}
