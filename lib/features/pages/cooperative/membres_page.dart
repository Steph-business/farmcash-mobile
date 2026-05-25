import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../models/membre_coop.dart';
import '../../../routing/route_names.dart';
import '../../../services/providers.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_dimens.dart';
import '../../widgets/communs/chargement.dart';
import '../../widgets/communs/header_utilisateur.dart';
import '../../widgets/communs/vue_erreur.dart';
import '../../widgets/cooperative/membres/banniere_adhesions.dart';
import '../../widgets/cooperative/membres/carte_liste_membres.dart';
import '../../widgets/cooperative/membres/etat_vide_membres.dart';
import '../../widgets/cooperative/membres/fab_enregistrer_managed.dart';
import '../../widgets/cooperative/membres/fab_inviter_membre.dart';
import '../../widgets/cooperative/membres/resume_membres.dart';
import '../../widgets/cooperative/membres/titre_membres.dart';

/// Bundle membres + nombre de demandes d'adhésion en attente.
class _MembresData {
  const _MembresData({required this.membres, required this.adhesionsCount});
  final List<MembreCoop> membres;
  final int adhesionsCount;
}

final _membresProvider =
    FutureProvider.autoDispose<_MembresData>((ref) async {
  final svc = ref.read(cooperativesServiceProvider);
  final results = await Future.wait<dynamic>([
    svc.listMembers(limit: 100).then<Object?>((v) => v),
    svc
        .listJoinRequests()
        .then<Object?>((v) => v)
        .catchError((_) => const <CoopJoinRequest>[]),
  ]);
  final page = results[0] as dynamic;
  final adhesions = results[1] as List<CoopJoinRequest>;
  return _MembresData(
    membres: page.data as List<MembreCoop>,
    adhesionsCount:
        adhesions.where((a) => a.status.toUpperCase() == 'PENDING').length,
  );
});

/// Liste des membres de la coopérative — branchée sur `listMembers`.
class MembresCooperativePage extends ConsumerWidget {
  const MembresCooperativePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(_membresProvider);
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            Column(
              children: [
                const HeaderUtilisateur(variant: HeaderVariant.cooperative),
                const TitreMembres(),
                Expanded(
                  child: async.when(
                    loading: () => const Padding(
                      padding: EdgeInsets.only(top: 48),
                      child: Chargement(size: 22),
                    ),
                    error: (e, _) => Padding(
                      padding: const EdgeInsets.all(AppDimens.pagePaddingH),
                      child: VueErreur(
                        message: 'Impossible de charger les membres. $e',
                        onRetry: () => ref.invalidate(_membresProvider),
                      ),
                    ),
                    data: (data) => RefreshIndicator(
                      color: AppColors.primary,
                      onRefresh: () async {
                        ref.invalidate(_membresProvider);
                        await ref.read(_membresProvider.future);
                      },
                      child: ListView(
                        padding: const EdgeInsets.fromLTRB(
                          AppDimens.pagePaddingH,
                          AppDimens.space8,
                          AppDimens.pagePaddingH,
                          AppDimens.space48 + AppDimens.space24,
                        ),
                        children: [
                          ResumeMembres(total: data.membres.length),
                          AppDimens.vGap16,
                          if (data.adhesionsCount > 0) ...[
                            BanniereAdhesions(
                              count: data.adhesionsCount,
                              onTap: () => context.push(
                                RouteNames.cooperativeAdhesionsPath,
                              ),
                            ),
                            AppDimens.vGap16,
                          ],
                          if (data.membres.isEmpty)
                            const EtatVideMembres()
                          else
                            CarteListeMembres(
                              members: data.membres,
                              onTap: (m) => context.push(
                                RouteNames.cooperativeMembreDetailPathFor(m.userId),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Positioned(
              right: AppDimens.pagePaddingH,
              bottom: AppDimens.space24,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  FabEnregistrerManaged(
                    onTap: () => context.push(
                      RouteNames.cooperativeMembreEnregistrerPath,
                    ),
                  ),
                  const SizedBox(height: 10),
                  FabInviterMembre(
                    onTap: () => context
                        .push(RouteNames.cooperativeInviterFarmerPath),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
