import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../models/livraison.dart';
import '../../../routing/route_names.dart';
import '../../../services/providers.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_dimens.dart';
import '../../widgets/communs/chargement.dart';
import '../../widgets/communs/vue_erreur.dart';
import '../../widgets/transporteur/missions/carte_demande_entrante.dart';
import '../../widgets/transporteur/missions/entete_demandes_entrantes.dart';
import '../../widgets/transporteur/missions/etat_vide_demandes_entrantes.dart';

/// Liste des missions disponibles (REQUESTED) matchant les routes du
/// transporteur. Cible `GET /logistics/missions/available`.
final _demandesProvider =
    FutureProvider.autoDispose<List<Livraison>>((ref) async {
  return ref.read(logisticsServiceProvider).getAvailableMissions();
});

/// Page « Demandes entrantes » — missions à accepter (1er arrivé, 1er servi).
class DemandesEntrantesTransporteurPage extends ConsumerWidget {
  const DemandesEntrantesTransporteurPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(_demandesProvider);
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const EnteteDemandesEntrantes(),
            Expanded(
              child: async.when(
                loading: () => const Padding(
                  padding: EdgeInsets.only(top: 48),
                  child: Chargement(size: 22),
                ),
                error: (e, _) => Padding(
                  padding: const EdgeInsets.all(AppDimens.pagePaddingH),
                  child: VueErreur(
                    message: 'Impossible de charger les demandes. $e',
                    onRetry: () => ref.invalidate(_demandesProvider),
                  ),
                ),
                data: (demandes) => RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: () async {
                    ref.invalidate(_demandesProvider);
                    await ref.read(_demandesProvider.future);
                  },
                  child: demandes.isEmpty
                      ? const EtatVideDemandesEntrantes()
                      : ListView.builder(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(
                            AppDimens.pagePaddingH,
                            12,
                            AppDimens.pagePaddingH,
                            AppDimens.space24,
                          ),
                          itemCount: demandes.length,
                          itemBuilder: (_, i) => CarteDemandeEntrante(
                            mission: demandes[i],
                            onTap: () => context.push(
                              RouteNames.transporteurDemandeDetailPathFor(
                                demandes[i].id,
                              ),
                            ),
                          ),
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
