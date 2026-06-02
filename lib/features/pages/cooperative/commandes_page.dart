import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../api_client/api_exception.dart';
import '../../../routing/route_names.dart';
import '../../../services/orders_service.dart';
import '../../../services/providers.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_dimens.dart';
import '../../../theme/app_text_styles.dart';
import '../../widgets/communs/profil_settings/entete_profil_settings.dart';
// Réutilise les widgets vendeur du producteur — la coop est vendeuse au
// même titre quand un acheteur commande directement sur ses publications.
import '../../widgets/producteur/commandes/carte_commande_liste.dart';
import '../../widgets/producteur/commandes/commandes_list_constants.dart';
import '../../widgets/producteur/commandes/etats_liste_commandes.dart';
import '../../widgets/producteur/commandes/onglets_commandes.dart';

/// Source de vérité : `GET /orders/my?side=seller`. La coop voit ses
/// VENTES directes (commandes reçues sur ses propres publications). Les
/// jointures backend ramènent buyer + produit pour éviter le N+1.
final _commandesCooperativeProvider =
    FutureProvider.autoDispose<List<OrderListItem>>((ref) async {
  final svc = ref.watch(ordersServiceProvider);
  final page = await svc.listMyOrdersWithJoins(side: 'seller', limit: 50);
  return page.data;
});

/// Page Mes commandes coopérative — suivi des commandes reçues quand un
/// acheteur commande directement chez la coop. Même logique et même
/// design que la page commandes producteur (la coop est aussi vendeuse).
class CommandesCooperativePage extends ConsumerStatefulWidget {
  /// Construit la page Mes commandes coop.
  const CommandesCooperativePage({super.key});

  @override
  ConsumerState<CommandesCooperativePage> createState() =>
      _CommandesCooperativePageState();
}

class _CommandesCooperativePageState
    extends ConsumerState<CommandesCooperativePage> {
  OrderTab _tab = OrderTab.enCours;

  void _ouvrirCommande(OrderListItem item) {
    // Pas encore de route détail commande coop dédiée → on réutilise la
    // route détail producteur qui affiche les mêmes infos côté vendeur.
    context.push(
      RouteNames.producteurCommandeDetailPathFor(item.commande.id),
    );
  }

  Future<void> _refresh() async {
    ref.invalidate(_commandesCooperativeProvider);
    await ref.read(_commandesCooperativeProvider.future);
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(_commandesCooperativeProvider);
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const EnteteProfilSettings(
              fallbackPath: RouteNames.cooperativeProfilPath,
              titre: 'Mes commandes',
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
                  onRetry: _refresh,
                ),
                data: (items) {
                  final filtered = items
                      .where((o) => tabForStatus(o.commande.status) == _tab)
                      .toList(growable: false);
                  if (filtered.isEmpty) {
                    return RefreshIndicator(
                      onRefresh: _refresh,
                      child: ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: const [
                          SizedBox(height: 80),
                          _EmptyMessage(),
                        ],
                      ),
                    );
                  }
                  return RefreshIndicator(
                    onRefresh: _refresh,
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

class _EmptyMessage extends StatelessWidget {
  const _EmptyMessage();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimens.space24),
      child: Column(
        children: [
          const Icon(
            Icons.inventory_2_outlined,
            size: 48,
            color: AppColors.textSubtle,
          ),
          AppDimens.vGap16,
          Text(
            'Aucune commande à suivre',
            style: AppTextStyles.titleMedium.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          AppDimens.vGap8,
          Text(
            'Quand un acheteur commandera sur une publication de la coop, '
            'tu la retrouveras ici.',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
