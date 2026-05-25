import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/livraison.dart';
import '../../../models/portefeuille.dart';
import '../../../services/providers.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_dimens.dart';
import '../../state/auth_state.dart';
import '../../widgets/communs/chargement.dart';
import '../../widgets/communs/header_utilisateur.dart';
import '../../widgets/communs/vue_erreur.dart';
import '../../widgets/transporteur/accueil/_constantes_accueil_transporteur.dart';
import '../../widgets/transporteur/accueil/contenu_accueil.dart';

/// Charge en parallèle les données nécessaires à l'accueil transporteur.
///
/// **3 sources distinctes** : `getMyMissions()` pour les shipments acceptés
/// (compteur livrées, mission active, prochains chargements),
/// `getAvailableMissions()` pour les missions à accepter, et `getWallet()`
/// pour le solde affiché en KPI.
final accueilTransporteurDataProvider =
    FutureProvider.autoDispose<AccueilTransporteurData>((ref) async {
  final logistics = ref.watch(logisticsServiceProvider);
  final finance = ref.watch(financeServiceProvider);

  final results = await Future.wait<dynamic>([
    logistics
        .getMyMissions()
        .then<Object?>((v) => v)
        .catchError((_) => <Livraison>[]),
    logistics
        .getAvailableMissions()
        .then<Object?>((v) => v)
        .catchError((_) => <Livraison>[]),
    logistics
        .listMyRoutes()
        .then<Object?>((v) => v)
        .catchError((_) => <TransporterRoute>[]),
    finance.getWallet().then<Object?>((v) => v).catchError((_) => null),
  ]);

  final mesShipments = (results[0] as List<Livraison>?) ?? const [];
  final disponibles = (results[1] as List<Livraison>?) ?? const [];
  final routes = (results[2] as List<TransporterRoute>?) ?? const [];
  final walletBundle = results[3];
  final Portefeuille? wallet =
      walletBundle == null ? null : (walletBundle as dynamic).wallet as Portefeuille;

  return AccueilTransporteurData(
    wallet: wallet,
    mesShipments: mesShipments,
    disponibles: disponibles,
    routes: routes,
  );
});

/// Accueil transporteur — mission active, KPI, missions disponibles,
/// prochains chargements.
///
/// Conforme à `mockups/transporteur_accueil.html`. Pas de mock data : tous
/// les blocs consomment les services Riverpod (`logistics`, `finance`).
/// Les sections sans donnée se masquent silencieusement.
class AccueilPage extends ConsumerWidget {
  const AccueilPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(accueilTransporteurDataProvider);
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            HeaderUtilisateur(
              variant: HeaderVariant.transporteur,
              subtitleOverride: _sousTitreHeader(async, user?.rating),
            ),
            Expanded(
              child: async.when(
                loading: () => const Padding(
                  padding: EdgeInsets.only(top: AppDimens.space32),
                  child: Chargement(size: 22),
                ),
                error: (e, _) => Padding(
                  padding: const EdgeInsets.all(AppDimens.pagePaddingH),
                  child: VueErreur(
                    message: 'Impossible de charger l\'accueil.',
                    onRetry: () =>
                        ref.invalidate(accueilTransporteurDataProvider),
                  ),
                ),
                data: (data) => RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: () async =>
                      ref.invalidate(accueilTransporteurDataProvider),
                  child: ContenuAccueilTransporteur(
                    data: data,
                    rating: user?.rating ?? 0,
                    prenom:
                        (user?.fullName ?? '').split(' ').first,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _sousTitreHeader(
    AsyncValue<AccueilTransporteurData> async,
    double? rating,
  ) {
    final data = async.value;
    final nb = data?.missionsDisponibles.length ?? 0;
    final missionsTxt = nb == 0
        ? 'Aucune mission disponible'
        : '$nb mission${nb > 1 ? 's' : ''} disponible${nb > 1 ? 's' : ''}';
    return missionsTxt;
  }
}
