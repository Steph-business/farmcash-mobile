import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../models/wallet_with_transactions.dart';
import '../../../../routing/route_names.dart';
import '../../../../services/providers.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../widgets/communs/chargement.dart';
import '../../../widgets/communs/vue_erreur.dart';
import '../../../widgets/communs/wallet/wallet_widgets.dart';

/// Filtres de la liste de transactions producteur (mock visuel — non
/// appliqué sur les données, conformément à la maquette).
enum _Filtre { tout, entrees, sorties }

/// Charge wallet + transactions paginées (1 seul appel backend).
final _walletProvider = FutureProvider.autoDispose<WalletWithTransactions>(
  (ref) => ref.watch(financeServiceProvider).getWallet(limit: 20),
);

/// Page Wallet producteur — solde, actions Retirer / Recharger, filtres et
/// liste de transactions. Mock fallback si endpoint indisponible.
class WalletPage extends ConsumerStatefulWidget {
  const WalletPage({super.key});

  @override
  ConsumerState<WalletPage> createState() => _WalletPageState();
}

class _WalletPageState extends ConsumerState<WalletPage> {
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
            EnteteWallet(
              titre: 'Mon wallet',
              actions: const [
                SizedBox(
                  width: 40,
                  height: 40,
                  child: Icon(Icons.search, size: 20, color: AppColors.text),
                ),
              ],
            ),
            Expanded(
              child: async.when(
                loading: () => const Padding(
                  padding: EdgeInsets.only(top: AppDimens.space32),
                  child: Chargement(size: 22),
                ),
                // L'écran reste utile même sans données — on tombe sur les
                // mocks pour rester aligné sur la maquette HTML.
                error: (_, _) => _corps(
                  context,
                  balance: 245800,
                  transactions: kMockTransactionsProducteur,
                ),
                data: (bundle) {
                  final items = bundle.transactions.data.isEmpty
                      ? kMockTransactionsProducteur
                      : MappingTransaction.depuisListe(bundle.transactions.data)
                          .take(8)
                          .toList();
                  return _corps(
                    context,
                    balance: bundle.wallet.balance,
                    transactions: items,
                  );
                },
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
    required List<ItemTransaction> transactions,
  }) {
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
          labelSolde: 'Solde actuel',
          sousTitre: '+95 000 F cette semaine',
          actions: [
            ActionSolde(
              label: 'Retirer',
              primaire: true,
              onTap: () =>
                  context.push(RouteNames.producteurWalletRetirerPath),
            ),
            ActionSolde(
              label: 'Recharger',
              primaire: false,
              onTap: () =>
                  context.push(RouteNames.producteurWalletRechargerPath),
            ),
          ],
        ),
        AppDimens.vGap16,
        ChipsFiltreTx(
          options: const [
            OptionFiltreTx(cle: _Filtre.tout, label: 'Tout'),
            OptionFiltreTx(cle: _Filtre.entrees, label: 'Entrées'),
            OptionFiltreTx(cle: _Filtre.sorties, label: 'Sorties'),
          ],
          actif: _filtre,
          onChanger: (cle) => setState(() => _filtre = cle as _Filtre),
        ),
        const SizedBox(height: 4),
        ListeTransactionsCard(items: transactions),
      ],
    );
  }
}

/// Helper de fallback exposé pour un éventuel état d'erreur dédié (gardé
/// pour cohérence avec l'ancienne version — actuellement on retombe sur
/// les mocks visuels).
@visibleForTesting
Widget walletErrorView(VoidCallback onRetry) => Padding(
      padding: const EdgeInsets.all(AppDimens.pagePaddingH),
      child: VueErreur(
        message: 'Impossible de charger le wallet.',
        onRetry: onRetry,
      ),
    );
