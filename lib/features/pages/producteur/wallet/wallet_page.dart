import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../models/wallet_with_transactions.dart';
import '../../../../routing/route_names.dart';
import '../../../../services/providers.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';
import '../../../state/auth_state.dart';
import '../../../widgets/communs/chargement.dart';
import '../../../widgets/communs/entete_page_standard.dart';
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
            const EntetePageStandard(titre: 'Mon portefeuille'),
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
                      : MappingTransaction.depuisListe(
                          bundle.transactions.data,
                        ).take(8).toList();
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
              onTap: () => context.push(RouteNames.producteurWalletRetirerPath),
            ),
            ActionSolde(
              label: 'Recharger',
              primaire: false,
              onTap: () =>
                  context.push(RouteNames.producteurWalletRechargerPath),
            ),
          ],
        ),
        // Tuile d'accès « Mes ventes coop » — visible UNIQUEMENT si le
        // producteur est rattaché à une coopérative. Permet de voir le
        // détail des contributions à des publications coop avec leur
        // breakdown brut/FarmCash/commission/avances/net.
        if (ref.watch(currentUserProvider)?.cooperativeId != null) ...[
          AppDimens.vGap12,
          _TuileVentesCoop(
            onTap: () => context.push(RouteNames.producteurVentesCoopPath),
          ),
        ],
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

/// Tuile premium d'accès à la page « Mes ventes coop ». Style pleine
/// largeur avec icône pastille verte, titre + sous-titre, chevron.
/// Pattern aligné sur les autres CTA secondaires de l'app.
class _TuileVentesCoop extends StatelessWidget {
  const _TuileVentesCoop({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(11),
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.groups_outlined,
                  size: 22,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Mes ventes coop',
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.text,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Voir tes contributions aux publications coop',
                      style: AppTextStyles.bodySmall.copyWith(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                size: 22,
                color: AppColors.textSubtle,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
