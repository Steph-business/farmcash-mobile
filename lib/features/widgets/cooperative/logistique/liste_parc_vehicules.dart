import 'package:flutter/material.dart';

import '../../../../models/coop_vehicle.dart';
import 'etat_vide_logistique.dart';
import 'ligne_vehicule.dart';

/// Liste du parc de vehicules de la coop. Affiche un etat vide si aucun
/// vehicule n'a ete enregistre, sinon une colonne de `LigneVehicule`
/// espacees verticalement.
class ListeParcVehicules extends StatelessWidget {
  const ListeParcVehicules({required this.vehicles, super.key});

  final List<CoopVehicle> vehicles;

  @override
  Widget build(BuildContext context) {
    if (vehicles.isEmpty) {
      return const EtatVideLogistique(
        icon: Icons.local_shipping_outlined,
        message: 'Aucun véhicule dans votre parc',
        hint: 'Ajoutez un premier véhicule pour planifier vos collectes.',
      );
    }
    return Column(
      children: [
        for (final v in vehicles) ...[
          LigneVehicule(vehicle: v),
          const SizedBox(height: 10),
        ],
      ],
    );
  }
}
