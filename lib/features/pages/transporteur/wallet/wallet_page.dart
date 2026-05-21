import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../models/transaction.dart';
import '../../../../models/wallet_with_transactions.dart';
import '../../../../routing/route_names.dart';
import '../../../../services/providers.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';
import '../../../widgets/communs/chargement.dart';
import '../../../widgets/communs/vue_erreur.dart';

const Color _kPrimarySoft = Color(0xFFE8F5E9);
const Color _kBgSoftIcon = Color(0xFFF3F4F6);

final _walletTransporteurProvider =
    FutureProvider.autoDispose<WalletWithTransactions>((ref) {
  return ref.watch(financeServiceProvider).getWallet(limit: 20);
});

/// Page Wallet transporteur — solde + escrow, actions Recharger / Retirer,
/// liste de transactions. Branchée sur `/finance/wallet`.
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
            const _Header(),
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
                  child: _Body(
                    balance: bundle.wallet.balance,
                    escrow: bundle.wallet.balanceEscrow,
                    transactions: bundle.transactions.data,
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

class _Header extends StatelessWidget {
  const _Header();
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppDimens.space16,
        AppDimens.space8,
        AppDimens.space16,
        AppDimens.space12,
      ),
      child: Row(
        children: [
          InkWell(
            onTap: () => Navigator.of(context).pop(),
            borderRadius: BorderRadius.circular(20),
            child: const SizedBox(
              width: 40,
              height: 40,
              child: Icon(
                Icons.arrow_back_ios_new,
                size: 20,
                color: AppColors.text,
              ),
            ),
          ),
          Expanded(
            child: Text(
              'Mon wallet',
              style: AppTextStyles.titleSmall.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 40, height: 40),
        ],
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({
    required this.balance,
    required this.escrow,
    required this.transactions,
  });
  final double balance;
  final double escrow;
  final List<Transaction> transactions;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppDimens.pagePaddingH,
        0,
        AppDimens.pagePaddingH,
        AppDimens.space16,
      ),
      children: [
        _Hero(balance: balance, escrow: escrow),
        AppDimens.vGap16,
        _ListCard(transactions: transactions),
      ],
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero({required this.balance, required this.escrow});
  final double balance;
  final double escrow;

  @override
  Widget build(BuildContext context) {
    final formatted = _nf.format(balance.round());
    final formattedEscrow = _nf.format(escrow.round());
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: AppDimens.brCard,
        border: Border.all(
          color: AppColors.border,
          width: AppDimens.borderThin,
        ),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Solde',
            style: AppTextStyles.bodySmall.copyWith(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '$formatted F',
            style: AppTextStyles.displayLarge.copyWith(
              fontSize: 32,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
              letterSpacing: -0.5,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'En attente (transport en escrow) : $formattedEscrow F',
            style: AppTextStyles.bodySmall.copyWith(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _HeroButton(
                  label: 'Recharger',
                  primary: true,
                  onTap: () => context
                      .push(RouteNames.transporteurWalletRechargerPath),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _HeroButton(
                  label: 'Retirer',
                  primary: false,
                  onTap: () =>
                      context.push(RouteNames.transporteurWalletRetirerPath),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeroButton extends StatelessWidget {
  const _HeroButton({
    required this.label,
    required this.primary,
    required this.onTap,
  });
  final String label;
  final bool primary;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bg = primary ? AppColors.primary : AppColors.background;
    final fg = primary ? AppColors.onPrimary : AppColors.primary;
    return InkWell(
      onTap: onTap,
      borderRadius: AppDimens.brButton,
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: AppDimens.brButton,
          border: Border.all(
            color: AppColors.primary,
            width: AppDimens.borderThin,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: AppTextStyles.button.copyWith(
            fontSize: 14,
            color: fg,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _ListCard extends StatelessWidget {
  const _ListCard({required this.transactions});
  final List<Transaction> transactions;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.border,
          width: AppDimens.borderThin,
        ),
      ),
      clipBehavior: Clip.hardEdge,
      child: transactions.isEmpty
          ? Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.history,
                    size: 32,
                    color: AppColors.textSubtle,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Aucune transaction pour le moment',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            )
          : Column(
              children: List.generate(transactions.length, (i) {
                return _TxRow(
                  tx: transactions[i],
                  isLast: i == transactions.length - 1,
                );
              }),
            ),
    );
  }
}

class _TxRow extends StatelessWidget {
  const _TxRow({required this.tx, required this.isLast});
  final Transaction tx;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final isIn = tx.montant >= 0;
    final bubbleBg = isIn ? _kPrimarySoft : _kBgSoftIcon;
    final bubbleFg = isIn ? AppColors.primary : AppColors.textSecondary;
    final amountColor = isIn ? AppColors.primary : AppColors.text;
    final montantFormatted = '${isIn ? '+' : '-'}'
        '${_nf.format(tx.montant.abs().round())} F';
    final titre = (tx.description?.isNotEmpty == true)
        ? tx.description!
        : (tx.reference?.isNotEmpty == true ? tx.reference! : tx.type);
    final dateLabel = tx.createdAt == null
        ? '—'
        : DateFormat('dd/MM', 'fr_FR').format(tx.createdAt!);
    final provider = tx.provider?.apiValue ?? '';
    final sousTitre = provider.isEmpty ? dateLabel : '$dateLabel · $provider';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: isLast ? Colors.transparent : AppColors.border,
            width: AppDimens.borderThin,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(color: bubbleBg, shape: BoxShape.circle),
            alignment: Alignment.center,
            child: Icon(
              isIn ? Icons.arrow_downward : Icons.arrow_upward,
              size: 18,
              color: bubbleFg,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  titre,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  sousTitre,
                  style: AppTextStyles.bodySmall.copyWith(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Text(
            montantFormatted,
            style: AppTextStyles.titleSmall.copyWith(
              fontFamily: 'Poppins',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: amountColor,
            ),
          ),
        ],
      ),
    );
  }
}

final _nf = NumberFormat('#,##0', 'fr_FR');
