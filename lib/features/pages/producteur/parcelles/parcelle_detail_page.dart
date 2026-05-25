import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../models/parcelle.dart';
import '../../../../models/produit.dart';
import '../../../../services/providers.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../widgets/communs/chargement.dart';
import '../../../widgets/communs/vue_erreur.dart';
import '../../../widgets/producteur/parcelles/parcelle_detail_content.dart';
import '../../../widgets/producteur/parcelles/parcelle_detail_data.dart';
import '../../../widgets/producteur/parcelles/parcelle_detail_header.dart';
import '../../../widgets/producteur/parcelles/parcelle_detail_header_loading.dart';

/// Provider familial : prend l'id de la parcelle, charge les données en
/// parallèle (parcelle + cultures + catalogue produits).
final _parcelleDetailProvider = FutureProvider.autoDispose
    .family<ParcelleDetailData, String>((ref, parcelleId) async {
  final svc = ref.watch(marketplaceServiceProvider);

  final results = await Future.wait<dynamic>([
    // 0 — parcelles (filtrage client-side sur id)
    svc.listParcelles().then<Object?>((v) => v).catchError((_) => <Parcelle>[]),
    // 1 — cultures de cette parcelle
    svc
        .listCultures(parcelleId: parcelleId)
        .then<Object?>((v) => v)
        .catchError((_) => <Culture>[]),
    // 2 — catalogue produits pour résoudre les noms
    svc.listProduits().then<Object?>((v) => v).catchError((_) => <Produit>[]),
  ]);

  final parcelles = (results[0] as List<Parcelle>?) ?? const <Parcelle>[];
  final parcelle = parcelles.where((p) => p.id == parcelleId).firstOrNull;
  final cultures = (results[1] as List<Culture>?) ?? const <Culture>[];
  final produits = (results[2] as List<Produit>?) ?? const <Produit>[];
  final byId = {for (final p in produits) p.id: p};

  return ParcelleDetailData(
    parcelle: parcelle,
    cultures: cultures,
    produitsById: byId,
  );
});

/// Détail d'une parcelle producteur — header + hero card + cultures.
///
/// Branché sur `marketplaceService.listCultures(parcelleId:)` pour récupérer
/// les cultures réelles. Si la parcelle n'est pas trouvée (id inexistant),
/// on affiche un message d'erreur avec retry.
class ParcelleDetailPage extends ConsumerWidget {
  const ParcelleDetailPage({required this.parcelleId, super.key});

  final String parcelleId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(_parcelleDetailProvider(parcelleId));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: async.when(
          loading: () => const Column(
            children: [
              ParcelleDetailHeaderLoading(),
              Expanded(child: Chargement(size: 22)),
            ],
          ),
          error: (e, _) => Column(
            children: [
              const ParcelleDetailHeaderLoading(),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(AppDimens.pagePaddingH),
                  child: VueErreur(
                    message: 'Impossible de charger la parcelle.',
                    onRetry: () =>
                        ref.invalidate(_parcelleDetailProvider(parcelleId)),
                  ),
                ),
              ),
            ],
          ),
          data: (data) {
            if (data.parcelle == null) {
              return Column(
                children: [
                  const ParcelleDetailHeader(titre: 'Parcelle introuvable'),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(AppDimens.pagePaddingH),
                      child: VueErreur(
                        message: 'Cette parcelle n\'existe plus ou tu n\'y as pas accès.',
                        onRetry: () =>
                            ref.invalidate(_parcelleDetailProvider(parcelleId)),
                      ),
                    ),
                  ),
                ],
              );
            }
            return ParcelleDetailContent(
              data: data,
              // Provider est `family<ParcelleDetailData, String>` — on
              // l'invalide avec la même clé (parcelleId) pour qu'il
              // recharge les cultures après ajout via la sheet.
              onCultureAjoutee: () =>
                  ref.invalidate(_parcelleDetailProvider(parcelleId)),
            );
          },
        ),
      ),
    );
  }
}
