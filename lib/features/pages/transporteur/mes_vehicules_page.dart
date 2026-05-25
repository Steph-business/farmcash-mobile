import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../api_client/api_exception.dart';
import '../../../models/vehicle.dart';
import '../../../routing/route_names.dart';
import '../../../services/providers.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_dimens.dart';
import '../../widgets/communs/chargement.dart';
import '../../widgets/communs/snackbars.dart';
import '../../widgets/communs/vue_erreur.dart';
import '../../widgets/transporteur/profil/bouton_ajouter_vehicule.dart';
import '../../widgets/transporteur/profil/carte_vehicule.dart';
import '../../widgets/transporteur/profil/entete_mes_vehicules.dart';
import '../../widgets/transporteur/profil/etat_vide_vehicules.dart';

/// Provider liste des véhicules du transporteur connecté.
final _mesVehiculesProvider =
    FutureProvider.autoDispose<List<Vehicle>>((ref) async {
  return ref.watch(logisticsServiceProvider).listMyVehicles();
});

/// Page « Mes véhicules » — liste de la flotte du transporteur avec CTA
/// pour en ajouter un nouveau. Branché sur `/logistics/vehicles/my`.
class MesVehiculesPage extends ConsumerWidget {
  const MesVehiculesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(_mesVehiculesProvider);
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const EnteteMesVehicules(),
            Expanded(
              child: async.when(
                loading: () => const Padding(
                  padding: EdgeInsets.only(top: 48),
                  child: Chargement(size: 22),
                ),
                error: (e, _) => Padding(
                  padding: const EdgeInsets.all(AppDimens.pagePaddingH),
                  child: VueErreur(
                    message: 'Impossible de charger tes véhicules. $e',
                    onRetry: () => ref.invalidate(_mesVehiculesProvider),
                  ),
                ),
                data: (items) => RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: () async => ref.invalidate(_mesVehiculesProvider),
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(
                      AppDimens.pagePaddingH,
                      AppDimens.space8,
                      AppDimens.pagePaddingH,
                      AppDimens.space16,
                    ),
                    children: [
                      if (items.isEmpty)
                        const EtatVideVehicules()
                      else ...[
                        for (final v in items) ...[
                          CarteVehicule(
                            v: v,
                            onDelete: () => _confirmerSuppression(
                              context,
                              ref,
                              v,
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],
                      ],
                      const SizedBox(height: 4),
                      BoutonAjouterVehicule(
                        onTap: () => context.push(
                          RouteNames.transporteurVehiculeCreerPath,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmerSuppression(
    BuildContext context,
    WidgetRef ref,
    Vehicle v,
  ) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Supprimer ce véhicule ?'),
        content: Text(
          'Le véhicule "${v.marque ?? v.type}" sera retiré de ta flotte.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text(
              'Supprimer',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
    if (ok != true) return;
    if (!context.mounted) return;
    try {
      await ref.read(logisticsServiceProvider).deleteVehicle(v.id);
      if (!context.mounted) return;
      Snackbars.showSucces(context, 'Véhicule supprimé');
      ref.invalidate(_mesVehiculesProvider);
    } on ApiException catch (e) {
      if (context.mounted) Snackbars.showErreur(context, e.message);
    }
  }
}
