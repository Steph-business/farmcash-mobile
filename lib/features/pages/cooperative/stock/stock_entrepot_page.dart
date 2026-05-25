import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../models/lot.dart';
import '../../../../routing/route_names.dart';
import '../../../../services/providers.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';
import '../../../widgets/communs/chargement.dart';
import '../../../widgets/communs/vue_erreur.dart';
import '../../../widgets/cooperative/stock/bouton_sticky_reception_lot.dart';
import '../../../widgets/cooperative/stock/entete_stock_entrepot.dart';
import '../../../widgets/cooperative/stock/kpi_row_entrepot.dart';
import '../../../widgets/cooperative/stock/liste_lots_entrepot.dart';

/// Bundle entrepôt + lots stockés physiquement dans cet entrepôt.
class _EntrepotBundle {
  const _EntrepotBundle({required this.entrepot, required this.lots});
  final Entrepot? entrepot;
  final List<Lot> lots;
}

final _entrepotBundleProvider = FutureProvider.autoDispose
    .family<_EntrepotBundle, String>((ref, entrepotId) async {
  final svc = ref.read(marketplaceServiceProvider);
  // Charge la liste des entrepôts pour récupérer le détail (nom + capacité)
  // et la liste des lots présents dans CET entrepôt (via table `stock`).
  final results = await Future.wait<dynamic>([
    svc.listEntrepots(),
    svc.listLotsByEntrepot(entrepotId),
  ]);
  final entrepots = results[0] as List<Entrepot>;
  final lots = results[1] as List<Lot>;
  Entrepot? entrepot;
  for (final e in entrepots) {
    if (e.id == entrepotId) {
      entrepot = e;
      break;
    }
  }
  return _EntrepotBundle(entrepot: entrepot, lots: lots);
});

/// Détail d'un entrepôt coopérative — capacité + lots stockés.
class StockEntrepotPage extends ConsumerWidget {
  const StockEntrepotPage({super.key, required this.entrepotId});

  final String entrepotId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(_entrepotBundleProvider(entrepotId));
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            EnteteStockEntrepot(
              titre: async.maybeWhen(
                data: (b) => b.entrepot?.nom ?? 'Entrepôt',
                orElse: () => 'Entrepôt',
              ),
            ),
            Expanded(
              child: async.when(
                loading: () => const Padding(
                  padding: EdgeInsets.only(top: 48),
                  child: Chargement(size: 22),
                ),
                error: (e, _) => Padding(
                  padding: const EdgeInsets.all(AppDimens.pagePaddingH),
                  child: VueErreur(
                    message: 'Impossible de charger cet entrepôt. $e',
                    onRetry: () =>
                        ref.invalidate(_entrepotBundleProvider(entrepotId)),
                  ),
                ),
                data: (bundle) {
                  final entrepot = bundle.entrepot;
                  if (entrepot == null) {
                    return Padding(
                      padding: const EdgeInsets.all(AppDimens.pagePaddingH),
                      child: Text(
                        'Entrepôt introuvable.',
                        style: AppTextStyles.bodyMedium,
                      ),
                    );
                  }
                  return _Body(entrepot: entrepot, lots: bundle.lots);
                },
              ),
            ),
            BoutonStickyReceptionLot(
              onTap: () =>
                  context.push(RouteNames.cooperativeStockReceptionPath),
            ),
          ],
        ),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.entrepot, required this.lots});

  final Entrepot entrepot;
  final List<Lot> lots;

  @override
  Widget build(BuildContext context) {
    final utilise = lots.fold<double>(0, (acc, l) => acc + l.quantiteKg);
    final capacite = entrepot.capaciteKg;
    final dispoPct = capacite > 0
        ? ((capacite - utilise).clamp(0, capacite) / capacite * 100).round()
        : 0;
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppDimens.pagePaddingH,
        0,
        AppDimens.pagePaddingH,
        AppDimens.space16,
      ),
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 12, bottom: 8),
          child: KpiRowEntrepot(
            capacite: capacite,
            utilise: utilise,
            dispoPct: dispoPct,
          ),
        ),
        AppDimens.vGap12,
        Text(
          'Lots dans cet entrepôt',
          style: AppTextStyles.titleSmall.copyWith(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
        AppDimens.vGap12,
        if (lots.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Text(
              'Cet entrepôt est vide.',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          )
        else
          ListeLotsEntrepot(lots: lots),
      ],
    );
  }
}
