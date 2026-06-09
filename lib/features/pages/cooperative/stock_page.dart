import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../models/lot.dart';
import '../../../routing/route_names.dart';
import '../../../services/providers.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_dimens.dart';
import '../../../theme/app_text_styles.dart';
import '../../state/auth_state.dart';
import '../../widgets/communs/chargement.dart';
import '../../widgets/communs/entete_page_compacte_coop.dart';
import '../../widgets/communs/vue_erreur.dart';
import '../../widgets/cooperative/publications/contenu_publications_coop.dart';
import '../../widgets/cooperative/stock/carte_entrepot.dart';
import '../../widgets/cooperative/stock/carte_lots_recents.dart';
import '../../widgets/cooperative/stock/onglets_stock_coop.dart';
import '../../widgets/cooperative/stock/resume_stock.dart';
import '../../widgets/cooperative/stock/titre_section_stock.dart';

/// Bundle entrepôts + lots récents pour l'onglet « Inventaire ».
class _StockBundle {
  const _StockBundle({required this.entrepots, required this.lots});
  final List<Entrepot> entrepots;
  final List<Lot> lots;
}

final _stockBundleProvider =
    FutureProvider.autoDispose<_StockBundle>((ref) async {
  final svc = ref.read(marketplaceServiceProvider);
  final results = await Future.wait<dynamic>([
    svc.listEntrepots(),
    svc.listLots(),
  ]);
  return _StockBundle(
    entrepots: results[0] as List<Entrepot>,
    lots: results[1] as List<Lot>,
  );
});

/// Page « Stock » coopérative refondue 2026-06-05 — 2 onglets toggle :
///
///   • **Inventaire** : entrepôts + lots physiques (existant)
///   • **Publications** : lots mis en vente sur le marché (déplacé
///     depuis l'ancien onglet « Marché », car « Marché » coop affiche
///     maintenant les opportunités acheteurs)
///
/// Stock = tout ce qui concerne la marchandise, qu'elle soit dans
/// l'entrepôt OU exposée au marché. UX cohérente : 1 endroit pour la
/// vue côté vendeur.
class StockCooperativePage extends ConsumerStatefulWidget {
  const StockCooperativePage({super.key});

  @override
  ConsumerState<StockCooperativePage> createState() =>
      _StockCooperativePageState();
}

class _StockCooperativePageState
    extends ConsumerState<StockCooperativePage> {
  OngletStockCoop _tab = OngletStockCoop.inventaire;

  @override
  Widget build(BuildContext context) {
    // Compteur publications actives pour le badge sur l'onglet
    // « Publications ». Best-effort : si la coop n'a pas d'id, badge 0.
    final user = ref.watch(currentUserProvider);
    final coopId = user?.cooperativeId;
    final pubBadge = coopId == null
        ? 0
        : ref.watch(publicationsCoopProvider(coopId)).maybeWhen(
              data: (list) => list
                  .where((p) =>
                      p.status.apiValue == 'ACTIVE' ||
                      p.status.apiValue == 'UNKNOWN')
                  .length,
              orElse: () => 0,
            );

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const EntetePageCompacteCoop(
              title: 'Stock',
              showBack: false,
            ),
            OngletsStockCoop(
              current: _tab,
              publicationsBadge: pubBadge,
              onSelect: (t) => setState(() => _tab = t),
            ),
            Expanded(
              child: IndexedStack(
                index: _tab == OngletStockCoop.inventaire ? 0 : 1,
                children: const [
                  _ContenuInventaire(),
                  ContenuPublicationsCoop(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Onglet « Inventaire » — entrepôts + lots récents (vue physique).
/// Extrait de l'ancienne `StockCooperativePage` (avant refonte 2 onglets).
class _ContenuInventaire extends ConsumerWidget {
  const _ContenuInventaire();

  void _ouvrirEntrepot(BuildContext context, Entrepot e) {
    context.push(RouteNames.cooperativeStockEntrepotPathFor(e.id));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(_stockBundleProvider);
    return async.when(
      loading: () => const Padding(
        padding: EdgeInsets.only(top: 48),
        child: Chargement(size: 22),
      ),
      error: (e, _) => Padding(
        padding: const EdgeInsets.all(AppDimens.pagePaddingH),
        child: VueErreur(
          message: 'Impossible de charger le stock. $e',
          onRetry: () => ref.invalidate(_stockBundleProvider),
        ),
      ),
      data: (bundle) {
        final entrepots = bundle.entrepots;
        final lots = bundle.lots;
        final stockTotalKg = lots.fold<double>(0, (acc, l) => acc + l.quantiteKg);
        final lotsRecents = [...lots]..sort((a, b) {
            final aDate = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
            final bDate = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
            return bDate.compareTo(aDate);
          });
        return Column(
          children: [
            ResumeStock(
              stockLabel: _formatStock(stockTotalKg),
              nbEntrepots: entrepots.length,
            ),
            Expanded(
              child: RefreshIndicator(
                color: AppColors.primary,
                onRefresh: () async {
                  ref.invalidate(_stockBundleProvider);
                  await ref.read(_stockBundleProvider.future);
                },
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(
                    AppDimens.pagePaddingH,
                    AppDimens.space8,
                    AppDimens.pagePaddingH,
                    AppDimens.space24,
                  ),
                  children: [
                    const TitreSectionStock(label: 'Entrepôts'),
                    AppDimens.vGap12,
                    if (entrepots.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Text(
                          'Aucun entrepôt enregistré.',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      )
                    else
                      for (final e in entrepots) ...[
                        CarteEntrepot(
                          entrepot: e,
                          onTap: () => _ouvrirEntrepot(context, e),
                        ),
                        AppDimens.vGap12,
                      ],
                    AppDimens.vGap12,
                    const TitreSectionStock(label: 'Lots récents'),
                    AppDimens.vGap12,
                    if (lotsRecents.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Text(
                          'Aucun lot pour le moment.',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      )
                    else
                      CarteLotsRecents(
                        lots: lotsRecents.take(8).toList(),
                      ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

String _formatStock(double kg) {
  if (kg < 1000) return '${kg.round()} kg stockés';
  final tonnes = kg / 1000;
  if (tonnes >= 10) return '${tonnes.toStringAsFixed(0)} t stockées';
  return '${tonnes.toStringAsFixed(1)} t stockées';
}
