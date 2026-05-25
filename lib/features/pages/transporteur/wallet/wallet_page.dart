import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../models/wallet_with_transactions.dart';
import '../../../../routing/route_names.dart';
import '../../../../services/providers.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../widgets/communs/chargement.dart';
import '../../../widgets/communs/vue_erreur.dart';
import '../../../widgets/communs/wallet/wallet_widgets.dart';

final _walletTransporteurProvider =
    FutureProvider.autoDispose<WalletWithTransactions>((ref) {
  return ref.watch(financeServiceProvider).getWallet(limit: 20);
});

/// Page Wallet transporteur — solde + escrow (transport en cours), actions
/// Recharger / Retirer, liste de transactions. Branchée sur `/finance/wallet`.
class WalletTransporteurPage extends ConsumerWidget {
  const WalletTransporteurPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(_walletTransporteurProvider);
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const EnteteWallet(titre: 'Mon wallet'),
            Expanded(
              child: async.when(
                loading: () => const Padding(
                  padding: EdgeInsets.only(top: AppDimens.space32),
                  child: Chargement(size: 22),
                ),
                error: (e, _) => Padding(
                  padding: const EdgeInsets.all(AppDimens.pagePaddingH),
                  child: VueErreur(
                    message: 'Impossible de charger le wallet. $e',
                    onRetry: () =>
                        ref.invalidate(_walletTransporteurProvider),
                  ),
                ),
                data: (bundle) => RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: () async {
                    ref.invalidate(_walletTransporteurProvider);
                    await ref.read(_walletTransporteurProvider.future);
                  },
                  child: _corps(
                    context,
                    balance: bundle.wallet.balance,
                    escrow: bundle.wallet.balanceEscrow,
                    items: MappingTransaction.depuisListe(
                      bundle.transactions.data,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _corps(
    BuildContext context, {
    required double balance,
    required double escrow,
    required List<ItemTransaction> items,
  }) {
    final escrowFormatted = NumberFormat('#,##0', 'fr_FR').format(escrow);
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppDimens.pagePaddingH,
        0,
        AppDimens.pagePaddingH,
        AppDimens.space16,
      ),
      children: [
        CarteSolde(
          balance: balance,
          labelSolde: 'Solde',
          sousTitre:
              'En attente (transport en escrow) : $escrowFormatted F',
          actions: [
            ActionSolde(
              label: 'Recharger',
              primaire: true,
              onTap: () =>
                  context.push(RouteNames.transporteurWalletRechargerPath),
            ),
            ActionSolde(
              label: 'Retirer',
              primaire: false,
              onTap: () =>
                  context.push(RouteNames.transporteurWalletRetirerPath),
            ),
          ],
        ),
        AppDimens.vGap16,
        ListeTransactionsCard(items: items),
      ],
    );
  }
}
