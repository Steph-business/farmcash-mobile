import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../models/wallet_with_transactions.dart';
import '../../../../routing/route_names.dart';
import '../../../../services/providers.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';
import '../../../widgets/communs/chargement.dart';
import '../../../widgets/communs/vue_erreur.dart';
import '../../../widgets/communs/wallet/wallet_widgets.dart';

/// Filtres affichés sur la liste des transactions wallet coop — purement
/// visuel comme côté producteur, sans filtrage backend.
enum _Filtre { tout, entrees, sorties, avances }

/// Charge wallet + transactions paginées (1 seul appel backend).
final _walletProvider = FutureProvider.autoDispose<WalletWithTransactions>(
  (ref) => ref.watch(financeServiceProvider).getWallet(limit: 20),
);

/// Page Wallet coopérative — solde + escrow, actions Retirer / Recharger
/// (mock pour l'instant), filtres et liste de transactions. Reproduction
/// fidèle de `mockups/cooperative/wallet.html`.
class WalletCooperativePage extends ConsumerStatefulWidget {
  const WalletCooperativePage({super.key});

  @override
  ConsumerState<WalletCooperativePage> createState() =>
      _WalletCooperativePageState();
}

class _WalletCooperativePageState extends ConsumerState<WalletCooperativePage> {
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
              titre: 'Finance · Wallet',
              onRetour: () => context.canPop()
                  ? context.pop()
                  : context.go(RouteNames.accueilCooperativePath),
              actions: [
                const SizedBox(
                  width: 40,
                  height: 40,
                  child: Icon(Icons.search, size: 20, color: AppColors.text),
                ),
                _BoutonNotifs(
                  onTap: () => context.push(
                    RouteNames.cooperativeNotificationsPath,
                  ),
                ),
              ],
            ),
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
          labelSolde: 'Solde actuel',
          sousTitre: 'En escrow : $escrowFormatted F',
          actions: [
            ActionSolde(
              label: 'Retirer',
              primaire: true,
              onTap: () => _snack(context, 'Retrait — à venir'),
            ),
            ActionSolde(
              label: 'Recharger',
              primaire: false,
              onTap: () => _snack(context, 'Recharge — à venir'),
            ),
          ],
        ),
        AppDimens.vGap16,
        ChipsFiltreTx(
          options: const [
            OptionFiltreTx(cle: _Filtre.tout, label: 'Tout'),
            OptionFiltreTx(cle: _Filtre.entrees, label: 'Entrées'),
            OptionFiltreTx(cle: _Filtre.sorties, label: 'Sorties'),
            OptionFiltreTx(cle: _Filtre.avances, label: 'Avances'),
          ],
          actif: _filtre,
          onChanger: (cle) => setState(() => _filtre = cle as _Filtre),
        ),
        const _EnteteSection(titre: 'Transactions récentes'),
        ListeTransactionsCard(
          items: items,
          afficherEtatVide: false,
        ),
      ],
    );
  }
}

/// En-tête de section coopérative-spécifique (titre + lien Filtrer à droite).
class _EnteteSection extends StatelessWidget {
  const _EnteteSection({required this.titre});

  final String titre;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              titre,
              style: AppTextStyles.titleSmall.copyWith(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            'Filtrer',
            style: AppTextStyles.link.copyWith(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

/// Bouton de notifications avec badge — spécifique à l'entête coopérative.
class _BoutonNotifs extends StatelessWidget {
  const _BoutonNotifs({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: SizedBox(
        width: 40,
        height: 40,
        child: Stack(
          children: [
            const Center(
              child: Icon(
                Icons.notifications_none,
                size: 22,
                color: AppColors.text,
              ),
            ),
            Positioned(
              top: 6,
              right: 6,
              child: Container(
                constraints:
                    const BoxConstraints(minWidth: 16, minHeight: 16),
                padding: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: AppColors.error,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.background,
                    width: 1.5,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  '5',
                  style: AppTextStyles.labelSmall.copyWith(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AppColors.onPrimary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void _snack(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
}
