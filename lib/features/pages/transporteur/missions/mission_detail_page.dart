import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

import '../../../../api_client/api_exception.dart';
import '../../../../models/enums.dart';
import '../../../../models/livraison.dart';
import '../../../../services/providers.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../widgets/communs/chargement.dart';
import '../../../widgets/communs/snackbars.dart';
import '../../../widgets/communs/vue_erreur.dart';
import '../../../widgets/transporteur/missions/actions_sticky_mission.dart';
import '../../../widgets/transporteur/missions/carte_marchandise_mission.dart';
import '../../../widgets/transporteur/missions/carte_montant_mission.dart';
import '../../../widgets/transporteur/missions/carte_statut_mission.dart';
import '../../../widgets/transporteur/missions/carte_timeline_mission.dart';
import '../../../widgets/transporteur/missions/carte_trajet_mission.dart';
import '../../../widgets/transporteur/missions/entete_mission_detail.dart';
import '../../../widgets/transporteur/missions/titre_section_mission.dart';
import '../scanner_page.dart';

/// Bundle mission + tracking events pour la timeline.
class _MissionBundle {
  const _MissionBundle({required this.mission, required this.tracking});
  final Livraison mission;
  final List<TrackingEvent> tracking;
}

/// Le backend n'expose pas de `GET /shipments/:id` direct (V1). On parcourt
/// les missions du transporteur (acceptées) PUIS les disponibles, et on
/// attaque le tracking pour la timeline.
final _missionBundleProvider = FutureProvider.autoDispose
    .family<_MissionBundle?, String>((ref, id) async {
  final svc = ref.read(logisticsServiceProvider);
  // 1. tracking (toujours dispo dès qu'on a l'id).
  final tracking = await svc.getTracking(id).catchError(
        (_) => const <TrackingEvent>[],
      );
  // 2. on cherche dans les missions acceptées du transporteur d'abord
  //    (cas le plus fréquent quand on rentre dans le détail), puis dans
  //    les missions disponibles si elle n'a pas encore été acceptée.
  Livraison? mission;
  try {
    final mine = await svc.getMyMissions();
    for (final m in mine) {
      if (m.id == id) {
        mission = m;
        break;
      }
    }
  } catch (_) {}
  if (mission == null) {
    try {
      final list = await svc.getAvailableMissions();
      for (final m in list) {
        if (m.id == id) {
          mission = m;
          break;
        }
      }
    } catch (_) {}
  }
  mission ??= Livraison(id: id, commandeId: id);
  return _MissionBundle(mission: mission, tracking: tracking);
});

/// Détail d'une mission transporteur — afficher l'état courant + actions
/// (Démarrer chargement, Marquer en route, Marquer livrée, Annuler).
class MissionDetailPage extends ConsumerStatefulWidget {
  const MissionDetailPage({required this.missionId, super.key});

  final String missionId;

  @override
  ConsumerState<MissionDetailPage> createState() => _MissionDetailPageState();
}

class _MissionDetailPageState extends ConsumerState<MissionDetailPage> {
  bool _busy = false;

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(_missionBundleProvider(widget.missionId));
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: async.when(
          loading: () => const Column(
            children: [
              EnteteMissionDetail(),
              Expanded(child: Chargement(size: 22)),
            ],
          ),
          error: (e, _) => Column(
            children: [
              const EnteteMissionDetail(),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(AppDimens.pagePaddingH),
                  child: VueErreur(
                    message: 'Impossible de charger la mission. $e',
                    onRetry: () =>
                        ref.invalidate(_missionBundleProvider(widget.missionId)),
                  ),
                ),
              ),
            ],
          ),
          data: (bundle) {
            if (bundle == null) {
              return const Column(
                children: [
                  EnteteMissionDetail(),
                  Expanded(
                    child: Center(
                      child: Text('Mission introuvable'),
                    ),
                  ),
                ],
              );
            }
            return _build(bundle);
          },
        ),
      ),
    );
  }

  Widget _build(_MissionBundle bundle) {
    final m = bundle.mission;
    return Column(
      children: [
        const EnteteMissionDetail(),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
            children: [
              CarteStatutMission(status: m.status),
              AppDimens.vGap16,
              const TitreSectionMission('Trajet'),
              AppDimens.vGap8,
              CarteTrajetMission(mission: m),
              AppDimens.vGap16,
              const TitreSectionMission('Marchandise'),
              AppDimens.vGap8,
              CarteMarchandiseMission(mission: m),
              AppDimens.vGap16,
              const TitreSectionMission('Montant'),
              AppDimens.vGap8,
              CarteMontantMission(mission: m),
              AppDimens.vGap16,
              const TitreSectionMission('Suivi'),
              AppDimens.vGap8,
              CarteTimelineMission(
                status: m.status,
                tracking: bundle.tracking,
              ),
            ],
          ),
        ),
        ActionsStickyMission(
          mission: m,
          busy: _busy,
          onAction: (next) => _transitionner(m, next),
        ),
      ],
    );
  }

  Future<void> _transitionner(
    Livraison mission,
    ShipmentStatus next,
  ) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final svc = ref.read(logisticsServiceProvider);
      switch (next) {
        case ShipmentStatus.accepted:
          await svc.acceptShipment(mission.id);
          break;
        case ShipmentStatus.loading:
          // Capture la position GPS au démarrage du chargement (audit
          // pickup côté coop). Optionnel côté backend : on envoie en
          // best-effort, l'absence ne bloque pas la transition.
          final pos = await _getCurrentPosition();
          await svc.startLoading(
            id: mission.id,
            lat: pos?.latitude,
            lng: pos?.longitude,
          );
          break;
        case ShipmentStatus.inTransit:
          // GPS obligatoire côté backend pour `trackPosition` : refuse la
          // transition si on n'arrive pas à le capturer (anti-fraude).
          final pos = await _getCurrentPosition();
          if (pos == null) {
            if (mounted) {
              Snackbars.showErreur(
                context,
                'Position GPS indisponible — active la géoloc pour démarrer le transit.',
              );
            }
            return;
          }
          await svc.trackPosition(
            id: mission.id,
            lat: pos.latitude,
            lng: pos.longitude,
            status: ShipmentStatus.inTransit,
          );
          break;
        case ShipmentStatus.delivered:
          // Nouveau flow : on ouvre le scanner en mode delivery pour
          // que le transporteur scanne le QR de l'acheteur. Le scan
          // déclenchera DELIVERED + libération escrow TRANSPORT +
          // commande COMPLETED côté backend. Plus de "Confirmer la
          // réception" manuelle nécessaire côté acheteur.
          await Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => ScannerPage(
                missionId: mission.id,
                mode: ScannerMode.delivery,
              ),
            ),
          );
          if (mounted) {
            ref.invalidate(_missionBundleProvider(widget.missionId));
            setState(() => _busy = false);
          }
          return;
        case ShipmentStatus.cancelled:
          await svc.cancelShipment(mission.id);
          break;
        case ShipmentStatus.requested:
        case ShipmentStatus.unknown:
          break;
      }
      ref.invalidate(_missionBundleProvider(widget.missionId));
      if (!mounted) return;
      Snackbars.showSucces(context, 'Mission mise à jour');
    } on ApiException catch (e) {
      if (mounted) Snackbars.showErreur(context, e.message);
    } catch (e) {
      if (mounted) Snackbars.showErreurInattendue(context, e);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  /// Récupère la position GPS du device en demandant la permission si
  /// besoin. Retourne `null` si géoloc désactivée ou permission refusée
  /// — l'appelant décide si c'est bloquant.
  Future<Position?> _getCurrentPosition() async {
    try {
      final enabled = await Geolocator.isLocationServiceEnabled();
      if (!enabled) return null;
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return null;
      }
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
    } catch (_) {
      return null;
    }
  }
}
