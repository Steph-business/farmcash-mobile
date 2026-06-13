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
import '../../widgets/producteur/commandes/contenu_reservations_recues.dart';
import '../../widgets/producteur/commandes/etats_liste_commandes.dart';
import '../../widgets/producteur/commandes/onglets_commandes.dart';
import '../../widgets/producteur/commandes/onglets_principal_commandes_producteur.dart';
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

/// Page « Commandes » du producteur — 2 onglets principaux symétriques
/// à la page acheteur :
///
///   1. **Mes ventes** — commandes payées par les acheteurs (côté seller)
///      avec 3 sous-onglets : En cours / Livrées / Annulées
///   2. **Réservations** — réservations faites par les acheteurs sur les
///      prévisions de récolte du producteur (acompte versé)
///
/// Refactor 2026-06-04 : avant, seul Mes ventes existait. L'utilisateur
/// a explicitement demandé la symétrie avec l'acheteur pour que les
/// réservations soient visibles depuis la même page.
class CommandesProducteurPage extends ConsumerStatefulWidget {
  const CommandesProducteurPage({
    this.initialTab = OngletPrincipalCommandesProducteur.ventes,
    super.key,
  });

  /// Onglet à sélectionner au montage — pour les deep-links / raccourcis.
  final OngletPrincipalCommandesProducteur initialTab;

  /// Convertit la valeur d'un query param `?tab=...` en enum.
  static OngletPrincipalCommandesProducteur parseTabParam(String? value) {
    switch (value) {
      case 'reservations':
        return OngletPrincipalCommandesProducteur.reservations;
      case 'ventes':
      default:
        return OngletPrincipalCommandesProducteur.ventes;
    }
  }

  @override
  ConsumerState<CommandesProducteurPage> createState() =>
      _CommandesProducteurPageState();
}

class _CommandesProducteurPageState
    extends ConsumerState<CommandesProducteurPage> {
  late OngletPrincipalCommandesProducteur _topTab = widget.initialTab;

  int get _topIndex {
    switch (_topTab) {
      case OngletPrincipalCommandesProducteur.ventes:
        return 0;
      case OngletPrincipalCommandesProducteur.reservations:
        return 1;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Badge sur l'onglet Réservations : compte les réservations en
    // attente d'action (PENDING/CONFIRMED non encore livrées).
    final reservationsAsync = ref.watch(reservationsRecuesProducteurProvider);
    final reservationsBadge = reservationsAsync.maybeWhen(
      data: (items) => items
          .where(
            (it) =>
                it.reservation.status.toUpperCase() == 'PENDING' ||
                it.reservation.status.toUpperCase() == 'CONFIRMED',
          )
          .length,
      orElse: () => 0,
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const HeaderUtilisateur(variant: HeaderVariant.producteur),
            const TitrePageCommandes(),
            OngletsPrincipalCommandesProducteur(
              current: _topTab,
              reservationsBadge: reservationsBadge,
              onSelect: (t) => setState(() => _topTab = t),
            ),
            Expanded(
              child: IndexedStack(
                index: _topIndex,
                children: const [
                  _ContenuMesVentes(),
                  ContenuReservationsRecues(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Onglet « Mes ventes » (contenu seulement) ─────────────────────

/// Contenu de l'onglet « Mes ventes » : sous-onglets En cours / Livrées /
/// Annulées + liste de cartes commande. Extrait de l'ancienne
/// `CommandesProducteurPage` (avant refactor 2 onglets top-level).
class _ContenuMesVentes extends ConsumerStatefulWidget {
  const _ContenuMesVentes();

  @override
  ConsumerState<_ContenuMesVentes> createState() => _ContenuMesVentesState();
}

class _ContenuMesVentesState extends ConsumerState<_ContenuMesVentes> {
  OrderTab _tab = OrderTab.enCours;

  void _ouvrirCommande(OrderListItem item) {
    context.push(RouteNames.producteurCommandeDetailPathFor(item.commande.id));
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(_commandesProducteurProvider);
    return Column(
      children: [
        OngletsCommandes(
          current: _tab,
          enCoursCount: async.maybeWhen(
            data: (items) => items
                .where(
                  (o) => tabForStatus(o.commande.status) == OrderTab.enCours,
                )
                .length,
            orElse: () => 0,
          ),
          onSelect: (t) => setState(() => _tab = t),
        ),
        Expanded(
          child: async.when(
            loading: () =>
                const Center(child: CircularProgressIndicator(strokeWidth: 2)),
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
    );
  }
}
