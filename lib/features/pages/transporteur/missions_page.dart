import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../models/enums.dart';
import '../../../models/livraison.dart';
import '../../../routing/route_names.dart';
import '../../../services/providers.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_dimens.dart';
import '../../widgets/communs/chargement.dart';
import '../../widgets/communs/header_utilisateur.dart';
import '../../widgets/communs/vue_erreur.dart';
import '../../widgets/transporteur/missions/barre_onglets_missions.dart';
import '../../widgets/transporteur/missions/carte_mission_liste.dart';
import '../../widgets/transporteur/missions/etat_vide_missions.dart';
import '../../widgets/transporteur/missions/mission_tab.dart';
import '../../widgets/transporteur/missions/titre_page_missions.dart';

const Set<ShipmentStatus> _kEnCours = {
  ShipmentStatus.accepted,
  ShipmentStatus.loading,
  ShipmentStatus.inTransit,
};

const Set<ShipmentStatus> _kTerminees = {
  ShipmentStatus.delivered,
  ShipmentStatus.cancelled,
};

/// Bundle missions transporteur : ses missions (statuts confondus) +
/// les missions disponibles à accepter (pour le compteur de l'onglet).
class _MissionsData {
  const _MissionsData({
    required this.mesShipments,
    required this.disponibles,
  });
  final List<Livraison> mesShipments;
  final List<Livraison> disponibles;
}

/// On charge à la fois les missions disponibles (pour le compteur
/// "Disponibles (N)") et celles déjà acceptées par le transporteur
/// (lifecycle en cours/terminées).
///
/// `GET /logistics/missions/available` ne renvoie que les REQUESTED
/// matchant les routes du transporteur. `GET /logistics/shipments/my`
/// retourne les shipments acceptés (tous statuts confondus).
final _missionsTransporteurProvider =
    FutureProvider.autoDispose<_MissionsData>((ref) async {
  final svc = ref.watch(logisticsServiceProvider);
  final results = await Future.wait([
    svc.getMyMissions(),
    svc.getAvailableMissions(),
  ]);
  return _MissionsData(
    mesShipments: results[0],
    disponibles: results[1],
  );
});

class MissionsTransporteurPage extends ConsumerStatefulWidget {
  const MissionsTransporteurPage({super.key});

  @override
  ConsumerState<MissionsTransporteurPage> createState() =>
      _MissionsTransporteurPageState();
}

class _MissionsTransporteurPageState
    extends ConsumerState<MissionsTransporteurPage> {
  MissionTab _tab = MissionTab.enCours;

  Future<void> _refresh() async {
    ref.invalidate(_missionsTransporteurProvider);
    await ref.read(_missionsTransporteurProvider.future);
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(_missionsTransporteurProvider);
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const HeaderUtilisateur(variant: HeaderVariant.transporteur),
            const TitrePageMissions(),
            Expanded(
              child: async.when(
                loading: () => const Padding(
                  padding: EdgeInsets.only(top: 48),
                  child: Chargement(size: 22),
                ),
                error: (e, _) => Padding(
                  padding: const EdgeInsets.all(AppDimens.pagePaddingH),
                  child: VueErreur(
                    message: 'Impossible de charger les missions. $e',
                    onRetry: _refresh,
                  ),
                ),
                data: (data) => _buildContent(data),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(_MissionsData data) {
    final enCours = data.mesShipments
        .where((m) => _kEnCours.contains(m.status))
        .toList();
    final terminees = data.mesShipments
        .where((m) => _kTerminees.contains(m.status))
        .toList();
    final listeFiltree = switch (_tab) {
      MissionTab.enCours => enCours,
      MissionTab.terminees => terminees,
      MissionTab.disponibles => data.disponibles,
    };

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: _refresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          AppDimens.pagePaddingH,
          AppDimens.space8,
          AppDimens.pagePaddingH,
          AppDimens.space16,
        ),
        children: [
          BarreOngletsMissions(
            current: _tab,
            enCoursCount: enCours.length,
            disponiblesCount: data.disponibles.length,
            terminees: terminees.length,
            onSelect: (t) => setState(() => _tab = t),
          ),
          AppDimens.vGap12,
          if (listeFiltree.isEmpty)
            EtatVideMissions(tab: _tab)
          else
            ...listeFiltree.map(
              (m) => CarteMissionListe(
                mission: m,
                onTap: () => context.push(
                  RouteNames.transporteurMissionDetailPathFor(m.id),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
