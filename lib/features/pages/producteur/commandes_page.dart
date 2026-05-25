import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../api_client/api_exception.dart';
import '../../../routing/route_names.dart';
import '../../../services/orders_service.dart';
import '../../../services/providers.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_dimens.dart';
import '../../widgets/communs/header_utilisateur.dart';
import '../../widgets/producteur/commandes/carte_commande_liste.dart';
import '../../widgets/producteur/commandes/commandes_list_constants.dart';
import '../../widgets/producteur/commandes/etats_liste_commandes.dart';
import '../../widgets/producteur/commandes/onglets_commandes.dart';
import '../../widgets/producteur/commandes/recap_commandes.dart';
import '../../widgets/producteur/commandes/titre_page_commandes.dart';

/// Source de vérité : `GET /orders/my?side=seller&limit=50`. Le FARMER
/// voit ses VENTES (côté seller). Les jointures backend ramènent le nom
/// du buyer + le produit pour éviter un N+1 côté UI. Pull-to-refresh
/// invalide ce provider.
final _commandesProducteurProvider =
    FutureProvider.autoDispose<List<OrderListItem>>((ref) async {
  final svc = ref.watch(ordersServiceProvider);
  final page = await svc.listMyOrdersWithJoins(side: 'seller', limit: 50);
  return page.data;
});

/// Onglet Commandes du producteur — accessible via le bottom-nav (shell).
///
/// La page récupère les commandes côté **seller** (= le FARMER qui vend),
/// les regroupe par statut dans 3 onglets, et propose une action
/// contextuelle adaptée à chaque statut.
class CommandesProducteurPage extends ConsumerStatefulWidget {
  const CommandesProducteurPage({super.key});

  @override
  ConsumerState<CommandesProducteurPage> createState() =>
      _CommandesProducteurPageState();
}

class _CommandesProducteurPageState
    extends ConsumerState<CommandesProducteurPage> {
  OrderTab _tab = OrderTab.enCours;

  void _ouvrirCommande(OrderListItem item) {
    context.push(
      RouteNames.producteurCommandeDetailPathFor(item.commande.id),
    );
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(_commandesProducteurProvider);
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const HeaderUtilisateur(variant: HeaderVariant.producteur),
            const TitrePageCommandes(),
            async.when(
              loading: () => const RecapCommandes(enCours: 0, livreesCeMois: 0),
              error: (_, _) =>
                  const RecapCommandes(enCours: 0, livreesCeMois: 0),
              data: (items) {
                final enCours = items
                    .where((o) => tabForStatus(o.commande.status) == OrderTab.enCours)
                    .length;
                // « Livrées ce mois » : on prend DELIVERED + COMPLETED dont
                // `updatedAt` est sur le mois courant (côté UI car le backend
                // ne renvoie pas ce compteur). Fallback `createdAt` si pas
                // d'updatedAt — la commande n'a probablement jamais changé.
                final now = DateTime.now();
                final livreesCeMois = items.where((o) {
                  final t = tabForStatus(o.commande.status);
                  if (t != OrderTab.livrees) return false;
                  final d = o.commande.updatedAt ?? o.commande.createdAt;
                  return d != null && d.year == now.year && d.month == now.month;
                }).length;
                return RecapCommandes(
                  enCours: enCours,
                  livreesCeMois: livreesCeMois,
                );
              },
            ),
            OngletsCommandes(
              current: _tab,
              enCoursCount: async.maybeWhen(
                data: (items) => items
                    .where((o) =>
                        tabForStatus(o.commande.status) == OrderTab.enCours)
                    .length,
                orElse: () => 0,
              ),
              onSelect: (t) => setState(() => _tab = t),
            ),
            Expanded(
              child: async.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                error: (err, _) => EtatErreurListeCommandes(
                  message: err is ApiException
                      ? err.message
                      : 'Erreur de chargement.',
                  onRetry: () => ref.invalidate(_commandesProducteurProvider),
                ),
                data: (items) {
                  final filtered = items
                      .where((o) => tabForStatus(o.commande.status) == _tab)
                      .toList(growable: false);
                  if (filtered.isEmpty) {
                    return RefreshIndicator(
                      onRefresh: () async {
                        ref.invalidate(_commandesProducteurProvider);
                        await ref.read(_commandesProducteurProvider.future);
                      },
                      child: const EtatVideListeCommandes(),
                    );
                  }
                  return RefreshIndicator(
                    onRefresh: () async {
                      ref.invalidate(_commandesProducteurProvider);
                      await ref.read(_commandesProducteurProvider.future);
                    },
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(
                        AppDimens.pagePaddingH,
                        AppDimens.space12,
                        AppDimens.pagePaddingH,
                        AppDimens.space16,
                      ),
                      itemCount: filtered.length,
                      itemBuilder: (_, i) => CarteCommandeListe(
                        item: filtered[i],
                        onTap: () => _ouvrirCommande(filtered[i]),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
