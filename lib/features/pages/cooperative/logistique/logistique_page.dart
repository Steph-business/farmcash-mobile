import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../api_client/api_exception.dart';
import '../../../../models/coop_collection.dart';
import '../../../../models/coop_vehicle.dart';
import '../../../../services/providers.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../widgets/communs/chargement.dart';
import '../../../widgets/communs/snackbars.dart';
import '../../../widgets/communs/vue_erreur.dart';
import '../../../widgets/cooperative/logistique/barre_onglets_logistique.dart';
import '../../../widgets/cooperative/logistique/boutons_actions_logistique.dart';
import '../../../widgets/cooperative/logistique/entete_logistique.dart';
import '../../../widgets/cooperative/logistique/liste_collectes.dart';
import '../../../widgets/cooperative/logistique/liste_parc_vehicules.dart';
import '../../../widgets/cooperative/logistique/onglet_logistique.dart';

/// Bundle parc + collectes actives (PLANNED + IN_PROGRESS).
class _LogiData {
  const _LogiData({required this.vehicles, required this.collections});
  final List<CoopVehicle> vehicles;
  final List<CoopCollection> collections;
}

final _logiProvider = FutureProvider.autoDispose<_LogiData>((ref) async {
  final svc = ref.read(coopLogisticsServiceProvider);
  final results = await Future.wait([
    svc.listVehicles(),
    svc.listCollections(),
  ]);
  final vehicles = results[0] as List<CoopVehicle>;
  final allCollections = results[1] as List<CoopCollection>;
  // Filtre côté client : on garde PLANNED + IN_PROGRESS (les collectes
  // terminées et annulées sont consultables depuis l'historique).
  final actives = allCollections
      .where((c) => c.status == 'PLANNED' || c.status == 'IN_PROGRESS')
      .toList();
  return _LogiData(vehicles: vehicles, collections: actives);
});

/// Page Logistique côté coopérative : 2 onglets (Parc + Collectes).
class LogistiqueCooperativePage extends ConsumerStatefulWidget {
  const LogistiqueCooperativePage({super.key});

  @override
  ConsumerState<LogistiqueCooperativePage> createState() =>
      _LogistiqueCooperativePageState();
}

class _LogistiqueCooperativePageState
    extends ConsumerState<LogistiqueCooperativePage> {
  OngletLogistique _tab = OngletLogistique.parc;

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(_logiProvider);
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const EnteteLogistique(),
            Expanded(
              child: async.when(
                loading: () => const Padding(
                  padding: EdgeInsets.only(top: 48),
                  child: Chargement(size: 22),
                ),
                error: (e, _) => Padding(
                  padding: const EdgeInsets.all(AppDimens.pagePaddingH),
                  child: VueErreur(
                    message: 'Impossible de charger la logistique. $e',
                    onRetry: () => ref.invalidate(_logiProvider),
                  ),
                ),
                data: _build,
              ),
            ),
            const BoutonsActionsLogistique(),
          ],
        ),
      ),
    );
  }

  Widget _build(_LogiData data) {
    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () async => ref.invalidate(_logiProvider),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          AppDimens.pagePaddingH,
          AppDimens.space12,
          AppDimens.pagePaddingH,
          AppDimens.space24,
        ),
        children: [
          BarreOngletsLogistique(
            current: _tab,
            parcCount: data.vehicles.length,
            collectesCount: data.collections.length,
            onSelect: (t) => setState(() => _tab = t),
          ),
          AppDimens.vGap12,
          if (_tab == OngletLogistique.parc)
            ListeParcVehicules(vehicles: data.vehicles)
          else
            ListeCollectes(
              collections: data.collections,
              onAction: (c) => _showActions(c),
            ),
        ],
      ),
    );
  }

  Future<void> _showActions(CoopCollection c) async {
    final action = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(Icons.check_circle_outline,
                  color: AppColors.primary),
              title: const Text('Marquer comme complétée'),
              onTap: () => Navigator.of(ctx).pop('complete'),
            ),
            ListTile(
              leading: const Icon(Icons.cancel_outlined,
                  color: AppColors.error),
              title: const Text('Annuler la collecte'),
              onTap: () => Navigator.of(ctx).pop('cancel'),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
    if (action == null || !mounted) return;
    final svc = ref.read(coopLogisticsServiceProvider);
    try {
      if (action == 'complete') {
        await svc.completeCollection(c.id);
        if (!mounted) return;
        Snackbars.showSucces(context, 'Collecte marquée complétée');
      } else if (action == 'cancel') {
        await svc.cancelCollection(c.id);
        if (!mounted) return;
        Snackbars.showSucces(context, 'Collecte annulée');
      }
      ref.invalidate(_logiProvider);
    } on ApiException catch (e) {
      if (!mounted) return;
      Snackbars.showErreur(context, e.message);
    }
  }
}
