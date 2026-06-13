import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../models/enums.dart';
import '../../../../models/livraison.dart';
import '../../../../routing/route_names.dart';
import '../../../../services/providers.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../widgets/communs/chargement.dart';
import '../../../widgets/communs/entete_page_standard.dart';
import '../../../widgets/communs/vue_erreur.dart';
import '../../../widgets/transporteur/missions/banniere_recap_historique.dart';
import '../../../widgets/transporteur/missions/barre_onglets_historique.dart';
import '../../../widgets/transporteur/missions/carte_mission_historique.dart';
import '../../../widgets/transporteur/missions/etat_vide_historique.dart';
import '../../../widgets/transporteur/missions/onglet_historique.dart';

/// Bundle missions terminées (livrées + annulées) du TRANSPORTER connecté.
class _HistoriqueData {
  const _HistoriqueData({required this.livrees, required this.annulees});
  final List<Livraison> livrees;
  final List<Livraison> annulees;
}

final _historiqueProvider =
    FutureProvider.autoDispose<_HistoriqueData>((ref) async {
  final svc = ref.watch(logisticsServiceProvider);
  final results = await Future.wait([
    svc.getMyMissions(status: ShipmentStatus.delivered),
    svc.getMyMissions(status: ShipmentStatus.cancelled),
  ]);
  return _HistoriqueData(livrees: results[0], annulees: results[1]);
});

/// Page « Historique des missions » — onglets Livrées / Annulées avec
/// récap total gains pour les missions livrées.
class MissionsHistoriquePage extends ConsumerStatefulWidget {
  const MissionsHistoriquePage({super.key});

  @override
  ConsumerState<MissionsHistoriquePage> createState() =>
      _MissionsHistoriquePageState();
}

class _MissionsHistoriquePageState
    extends ConsumerState<MissionsHistoriquePage> {
  OngletHistorique _tab = OngletHistorique.livrees;

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(_historiqueProvider);
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const EntetePageStandard(titre: 'Historique des missions'),
            Expanded(
              child: async.when(
                loading: () => const Padding(
                  padding: EdgeInsets.only(top: 48),
                  child: Chargement(size: 22),
                ),
                error: (e, _) => Padding(
                  padding: const EdgeInsets.all(AppDimens.pagePaddingH),
                  child: VueErreur(
                    message: 'Impossible de charger l\'historique. $e',
                    onRetry: () => ref.invalidate(_historiqueProvider),
                  ),
                ),
                data: (data) => _build(data),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _build(_HistoriqueData data) {
    final items =
        _tab == OngletHistorique.livrees ? data.livrees : data.annulees;
    final totalGains = data.livrees.fold<double>(
      0,
      (acc, m) => acc + (m.prixFinal ?? m.prixDevis ?? 0),
    );

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () async => ref.invalidate(_historiqueProvider),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          AppDimens.pagePaddingH,
          AppDimens.space12,
          AppDimens.pagePaddingH,
          AppDimens.space16,
        ),
        children: [
          BanniereRecapHistorique(
            totalLivrees: data.livrees.length,
            totalGains: totalGains,
          ),
          AppDimens.vGap12,
          BarreOngletsHistorique(
            current: _tab,
            livreesCount: data.livrees.length,
            annuleesCount: data.annulees.length,
            onSelect: (t) => setState(() => _tab = t),
          ),
          AppDimens.vGap12,
          if (items.isEmpty)
            EtatVideHistorique(tab: _tab)
          else
            for (final m in items) ...[
              CarteMissionHistorique(
                mission: m,
                onTap: () => context.push(
                  RouteNames.transporteurMissionDetailPathFor(m.id),
                ),
              ),
              const SizedBox(height: 10),
            ],
        ],
      ),
    );
  }
}
