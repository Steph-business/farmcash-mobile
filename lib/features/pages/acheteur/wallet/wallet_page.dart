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

/// Filtres de la liste de transactions acheteur (mock visuel — non appliqué
/// sur les données, conformément à la maquette HTML).
enum _Filtre { tout, achats, recharges, escrow }

/// Charge wallet + transactions paginées (1 seul appel backend).
final _walletProvider = FutureProvider.autoDispose<WalletWithTransactions>(
  (ref) => ref.watch(financeServiceProvider).getWallet(limit: 20),
);

/// Page Wallet acheteur — solde + escrow, actions Recharger / Retirer,
/// filtres et liste de transactions. Affiche une erreur si l'endpoint est
/// indisponible (avec retry).
class WalletAcheteurPage extends ConsumerStatefulWidget {
  const WalletAcheteurPage({super.key});

  @override
  ConsumerState<WalletAcheteurPage> createState() =>
      _WalletAcheteurPageState();
}

class _WalletAcheteurPageState extends ConsumerState<WalletAcheteurPage> {
  _Filtre _filtre = _Filtre.tout;

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(_walletProvider);

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
                    onRetry: () => ref.invalidate(_walletProvider),
                  ),
                ),
                data: (bundle) => RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: () async {
                    ref.invalidate(_walletProvider);
                    await ref.read(_walletProvider.future);
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
          sousTitre: 'En escrow : $escrowFormatted F',
          actions: [
            ActionSolde(
              label: 'Recharger',
              primaire: true,
              onTap: () =>
                  context.push(RouteNames.acheteurWalletRechargerPath),
            ),
            ActionSolde(
              label: 'Retirer',
              primaire: false,
              onTap: () => context.push(RouteNames.acheteurWalletRetirerPath),
            ),
          ],
        ),
        AppDimens.vGap16,
        ChipsFiltreTx(
          options: const [
            OptionFiltreTx(cle: _Filtre.tout, label: 'Tout'),
            OptionFiltreTx(cle: _Filtre.achats, label: 'Achats'),
            OptionFiltreTx(cle: _Filtre.recharges, label: 'Recharges'),
            OptionFiltreTx(cle: _Filtre.escrow, label: 'Escrow'),
          ],
          actif: _filtre,
          onChanger: (cle) => setState(() => _filtre = cle as _Filtre),
        ),
        const SizedBox(height: 4),
        ListeTransactionsCard(items: items),
      ],
    );
  }
}
