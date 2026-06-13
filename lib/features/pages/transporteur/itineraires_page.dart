import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../api_client/api_exception.dart';
import '../../../models/livraison.dart';
import '../../../routing/route_names.dart';
import '../../../services/providers.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_dimens.dart';
import '../../../theme/app_text_styles.dart';
import '../../widgets/communs/chargement.dart';
import '../../widgets/communs/entete_page_standard.dart';
import '../../widgets/communs/snackbars.dart';
import '../../widgets/communs/vue_erreur.dart';
import '../../widgets/transporteur/itineraires/carte_itineraire.dart';
import '../../widgets/transporteur/itineraires/etat_vide_itineraires.dart';

final _itinerairesProvider =
    FutureProvider.autoDispose<List<TransporterRoute>>((ref) async {
  return ref.read(logisticsServiceProvider).listMyRoutes();
});

/// Liste des routes (origin → destination) que le transporteur dessert.
/// Le bouton "Ajouter" pousse vers `itineraire_creer_page`.
class ItinerairesTransporteurPage extends ConsumerStatefulWidget {
  const ItinerairesTransporteurPage({super.key});

  @override
  ConsumerState<ItinerairesTransporteurPage> createState() =>
      _ItinerairesTransporteurPageState();
}

class _ItinerairesTransporteurPageState
    extends ConsumerState<ItinerairesTransporteurPage> {
  String? _busyId;

  Future<void> _refresh() async {
    ref.invalidate(_itinerairesProvider);
    await ref.read(_itinerairesProvider.future);
  }

  Future<void> _toggleActif(TransporterRoute r) async {
    if (_busyId != null) return;
    setState(() => _busyId = r.id);
    try {
      await ref
          .read(logisticsServiceProvider)
          .updateRoute(r.id, isActive: !r.isActive);
      await _refresh();
    } on ApiException catch (e) {
      if (mounted) Snackbars.showErreur(context, e.message);
    } finally {
      if (mounted) setState(() => _busyId = null);
    }
  }

  Future<void> _supprimer(TransporterRoute r) async {
    if (_busyId != null) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Désactiver l\'itinéraire ?'),
        content: Text(
          '${r.origineZone} → ${r.destinationZone} sera désactivé. '
          'Tu pourras le réactiver plus tard.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Désactiver'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    if (!mounted) return;
    setState(() => _busyId = r.id);
    try {
      await ref.read(logisticsServiceProvider).deleteRoute(r.id);
      await _refresh();
      if (mounted) Snackbars.showInfo(context, 'Itinéraire désactivé');
    } on ApiException catch (e) {
      if (mounted) Snackbars.showErreur(context, e.message);
    } finally {
      if (mounted) setState(() => _busyId = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(_itinerairesProvider);
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            EntetePageStandard(
              titre: 'Mes itinéraires',
              onBack: () => context.canPop()
                  ? context.pop()
                  : context.go(RouteNames.transporteurMissionsPath),
              actions: [
                // Raccourci « Ajouter » conservé (push form + refresh au retour).
                TextButton(
                  onPressed: () async {
                    await context
                        .push(RouteNames.transporteurVehiculeAjouterPath);
                    _refresh();
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    visualDensity: VisualDensity.compact,
                  ),
                  child: Text(
                    'Ajouter',
                    style: AppTextStyles.labelMedium.copyWith(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
            Expanded(
              child: async.when(
                loading: () => const Padding(
                  padding: EdgeInsets.only(top: 48),
                  child: Chargement(size: 22),
                ),
                error: (e, _) => Padding(
                  padding: const EdgeInsets.all(AppDimens.pagePaddingH),
                  child: VueErreur(
                    message: 'Impossible de charger les itinéraires. $e',
                    onRetry: _refresh,
                  ),
                ),
                data: (routes) => RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: _refresh,
                  child: routes.isEmpty
                      ? const EtatVideItineraires()
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(
                            AppDimens.pagePaddingH,
                            8,
                            AppDimens.pagePaddingH,
                            24,
                          ),
                          itemCount: routes.length,
                          itemBuilder: (_, i) {
                            final r = routes[i];
                            return CarteItineraire(
                              route: r,
                              busy: _busyId == r.id,
                              onToggle: () => _toggleActif(r),
                              onDelete: () => _supprimer(r),
                            );
                          },
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
