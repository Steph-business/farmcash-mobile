import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../models/enums.dart';
import '../../../../models/pagination.dart';
import '../../../../routing/route_names.dart';
import '../../../../services/orders_service.dart';
import '../../../../services/providers.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../communs/chargement.dart';
import '../../communs/vue_erreur.dart';
import 'carte_commande_acheteur.dart';
import 'etat_vide_commandes.dart';
import 'onglets_commandes.dart';

// ─── Statuts pour le sous-filtre (En cours / Livrées / Toutes) ───────

const Set<OrderStatus> _kEnCoursStatus = {
  OrderStatus.sent,
  OrderStatus.accepted,
  OrderStatus.inProgress,
  OrderStatus.disputed,
};

const Set<OrderStatus> _kLivreesStatus = {
  OrderStatus.delivered,
  OrderStatus.completed,
};

// ─── Provider ────────────────────────────────────────────────────────

/// Charge les commandes acheteur avec les joints (vendeur + produit) —
/// `listMyOrdersWithJoins` permet d'afficher des cartes scannables sans
/// faire de fetch annonce par carte.
final commandesAcheteurDirectesProvider =
    FutureProvider.autoDispose<List<OrderListItem>>((ref) async {
  final svc = ref.read(ordersServiceProvider);
  final Paginated<OrderListItem> page = await svc.listMyOrdersWithJoins(
    side: 'buyer',
    limit: 50,
  );
  return page.data;
});

/// Contenu de l'onglet « Commandes » de la page Mes commandes acheteur.
/// Sous-filtre interne (En cours / Livrées / Toutes) conservé tel quel —
/// c'est le flux que l'utilisateur consulte le plus souvent.
class OngletCommandesDirectes extends ConsumerStatefulWidget {
  const OngletCommandesDirectes({super.key});

  @override
  ConsumerState<OngletCommandesDirectes> createState() =>
      _OngletCommandesDirectesState();
}

class _OngletCommandesDirectesState
    extends ConsumerState<OngletCommandesDirectes> {
  OngletCommandes _sousFiltre = OngletCommandes.enCours;

  Future<void> _refresh() async {
    ref.invalidate(commandesAcheteurDirectesProvider);
    await ref.read(commandesAcheteurDirectesProvider.future);
  }

  List<OrderListItem> _filter(List<OrderListItem> all) {
    switch (_sousFiltre) {
      case OngletCommandes.enCours:
        return all
            .where((c) => _kEnCoursStatus.contains(c.commande.status))
            .toList();
      case OngletCommandes.livrees:
        return all
            .where((c) => _kLivreesStatus.contains(c.commande.status))
            .toList();
      case OngletCommandes.toutes:
        return all;
    }
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(commandesAcheteurDirectesProvider);
    return async.when(
      loading: () => const Padding(
        padding: EdgeInsets.only(top: 48),
        child: Chargement(size: 22),
      ),
      error: (e, _) => Padding(
        padding: const EdgeInsets.all(AppDimens.pagePaddingH),
        child: VueErreur(
          message: 'Impossible de charger les commandes. $e',
          onRetry: _refresh,
        ),
      ),
      data: (all) {
        final orders = _filter(all);
        final enCoursCount = all
            .where((c) => _kEnCoursStatus.contains(c.commande.status))
            .length;
        final livreesCount = all
            .where((c) => _kLivreesStatus.contains(c.commande.status))
            .length;
        return RefreshIndicator(
          color: AppColors.primary,
          onRefresh: _refresh,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              20,
              AppDimens.space8,
              20,
              AppDimens.space16,
            ),
            children: [
              OngletsCommandes(
                current: _sousFiltre,
                enCoursCount: enCoursCount,
                livreesCount: livreesCount,
                onSelect: (t) => setState(() => _sousFiltre = t),
              ),
              AppDimens.vGap16,
              if (orders.isEmpty)
                const EtatVideCommandes()
              else
                ...orders.map(
                  (item) => CarteCommandeAcheteur(
                    item: item,
                    onTap: () => context.push(
                      RouteNames.acheteurCommandeDetailPathFor(
                        item.commande.id,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
