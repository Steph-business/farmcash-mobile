import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../theme/app_colors.dart';
import '../../../widgets/communs/entete_page_standard.dart';
import '../../../widgets/transporteur/missions/bande_cargo_mission.dart';
import '../../../widgets/transporteur/missions/bandeau_info_trajet.dart';
import '../../../widgets/transporteur/missions/barre_action_scan_arrivee.dart';
import '../../../widgets/transporteur/missions/carte_destination_producteur.dart';
import '../../../widgets/transporteur/missions/carte_placeholder_trajet.dart';

/// Vue "en route" pendant qu'un transporteur se rend chez le producteur :
/// carte placeholder, cargo strip, info distance/ETA, destination, CTA
/// scan QR à l'arrivée.
class MissionEnRoutePage extends ConsumerWidget {
  const MissionEnRoutePage({required this.missionId, super.key});

  final String missionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const EntetePageStandard(titre: 'En route vers producteur'),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: const [
                  CartePlaceholderTrajet(),
                  BandeauInfoTrajet(),
                  Padding(
                    padding: EdgeInsets.fromLTRB(20, 12, 20, 0),
                    child: BandeCargoMission(),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(20, 12, 20, 16),
                    child: CarteDestinationProducteur(),
                  ),
                ],
              ),
            ),
            BarreActionScanArrivee(missionId: missionId),
          ],
        ),
      ),
    );
  }
}
