import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../models/enums.dart';
import '../../../models/pagination.dart';
import '../../../routing/route_names.dart';
import '../../../services/orders_service.dart';
import '../../../services/providers.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_dimens.dart';
import '../../widgets/acheteur/commandes/carte_commande_acheteur.dart';
import '../../widgets/acheteur/commandes/compteur_commandes.dart';
import '../../widgets/acheteur/commandes/etat_vide_commandes.dart';
import '../../widgets/acheteur/commandes/onglets_commandes.dart';
import '../../widgets/acheteur/commandes/titre_page_commandes.dart';
import '../../widgets/communs/chargement.dart';
import '../../widgets/communs/header_utilisateur.dart';
import '../../widgets/communs/vue_erreur.dart';

// Statuts considérés comme "en cours" pour le filtre côté UI. Les statuts
// "completed" / "delivered" sont considérés comme livrés (avant escrow ou
// après notation).
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

/// Provider qui charge les commandes avec les joins vendeur + produit
/// (`listMyOrdersWithJoins`). On a besoin de `sellerName/Photo` +
/// `produitNom` pour afficher des cartes scannables type marketplace.
final _commandesAcheteurProvider =
    FutureProvider.autoDispose<List<OrderListItem>>((ref) async {
  final svc = ref.read(ordersServiceProvider);
  final Paginated<OrderListItem> page =
      await svc.listMyOrdersWithJoins(side: 'buyer', limit: 50);
  return page.data;
});

class CommandesAcheteurPage extends ConsumerStatefulWidget {
  const CommandesAcheteurPage({super.key});

  @override
  ConsumerState<CommandesAcheteurPage> createState() =>
      _CommandesAcheteurPageState();
}

class _CommandesAcheteurPageState
    extends ConsumerState<CommandesAcheteurPage> {
  OngletCommandes _tab = OngletCommandes.enCours;

  Future<void> _refresh() async {
    ref.invalidate(_commandesAcheteurProvider);
    await ref.read(_commandesAcheteurProvider.future);
  }

  List<OrderListItem> _filter(List<OrderListItem> all) {
    switch (_tab) {
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
    final async = ref.watch(_commandesAcheteurProvider);
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const HeaderUtilisateur(variant: HeaderVariant.acheteur),
            const TitrePageCommandes(),
            Expanded(
              child: async.when(
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
                      .where(
                        (c) => _kEnCoursStatus.contains(c.commande.status),
                      )
                      .length;
                  final livreesCount = all
                      .where(
                        (c) => _kLivreesStatus.contains(c.commande.status),
                      )
                      .length;
                  return RefreshIndicator(
                    color: AppColors.primary,
                    onRefresh: _refresh,
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(
                          20, 0, 20, AppDimens.space16),
                      children: [
                        CompteurCommandes(
                          enCours: enCoursCount,
                          livrees: livreesCount,
                        ),
                        AppDimens.vGap16,
                        OngletsCommandes(
                          current: _tab,
                          enCoursCount: enCoursCount,
                          livreesCount: livreesCount,
                          onSelect: (t) => setState(() => _tab = t),
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}
