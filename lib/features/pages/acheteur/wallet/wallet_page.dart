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

// ─── Couleurs accent (conformes au mockup) ───────────────────────────────

const Color _kPrimarySoft = Color(0xFFE8F5E9);
const Color _kBgSoftIcon = Color(0xFFF3F4F6);

/// Filtres de la liste de transactions (mock visuel — la maquette HTML n'a
/// pas de filtre fonctionnel sur les chips, juste l'affichage actif/inactif).
enum _FilterChip { tout, achats, recharges, escrow }

/// Charge wallet + transactions paginées (1 seul appel backend).
final _walletProvider = FutureProvider.autoDispose<WalletWithTransactions>(
  (ref) => ref.watch(financeServiceProvider).getWallet(limit: 20),
);

/// Mock fallback fidèle à la maquette HTML — utilisé quand l'endpoint
/// `/finance/wallet` n'est pas joignable ou retourne une erreur.
class _MockTx {
  final IconData icon;
  final bool isIn;
  final String titre;
  final String sousTitre;
  final String montant; // déjà formaté avec préfixe + / -

  const _MockTx({
    required this.icon,
    required this.isIn,
    required this.titre,
    required this.sousTitre,
    required this.montant,
  });
}


/// Page Wallet acheteur — solde + escrow, actions Recharger / Retirer,
/// filtres et liste de transactions. Mock fallback si endpoint indisponible.
class WalletAcheteurPage extends ConsumerStatefulWidget {
  const WalletAcheteurPage({super.key});

  @override
  ConsumerState<WalletAcheteurPage> createState() => _WalletAcheteurPageState();
}

class _WalletAcheteurPageState extends ConsumerState<WalletAcheteurPage> {
  _FilterChip _filter = _FilterChip.tout;

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(_walletProvider);

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
                    onRetry: () => ref.invalidate(_walletProvider),
                  ),
                ),
                data: (bundle) => RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: () async {
                    ref.invalidate(_walletProvider);
                    await ref.read(_walletProvider.future);
                  },
                  child: _Body(
                    balance: bundle.wallet.balance,
                    escrow: bundle.wallet.balanceEscrow,
                    transactions: bundle.transactions.data,
                    filter: _filter,
                    onFilter: (f) => setState(() => _filter = f),
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

// ─── Header ──────────────────────────────────────────────────────────────

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

// ─── Body (hero + chips + liste) ─────────────────────────────────────────

class _Body extends StatelessWidget {
  const _Body({
    required this.balance,
    required this.escrow,
    required this.transactions,
    required this.filter,
    required this.onFilter,
  });

  final double balance;
  final double escrow;
  final List<Transaction> transactions;
  final _FilterChip filter;
  final ValueChanged<_FilterChip> onFilter;

  @override
  Widget build(BuildContext context) {
    final txItems = _buildItems();

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
        _Chips(filter: filter, onChange: onFilter),
        const SizedBox(height: 4),
        _ListCard(items: txItems),
      ],
    );
  }

  /// Mappe les transactions reçues vers la représentation visuelle. Si
  /// l'API n'en renvoie pas, la liste est simplement vide (état vide
  /// affiché par [_ListCard]).
  List<_MockTx> _buildItems() {
    return transactions.map(_mapTx).toList();
  }

  static _MockTx _mapTx(Transaction t) {
    final isIn = t.montant >= 0;
    final titre = (t.description?.isNotEmpty == true)
        ? t.description!
        : (t.reference?.isNotEmpty == true ? t.reference! : t.type);
    final montant = NumberFormat('#,##0', 'fr_FR').format(t.montant.abs());
    final dateLabel = t.createdAt == null
        ? '—'
        : DateFormat('dd/MM', 'fr_FR').format(t.createdAt!);
    final providerLabel = t.provider?.apiValue ?? '';
    final sousTitre =
        providerLabel.isEmpty ? dateLabel : '$dateLabel · $providerLabel';
    return _MockTx(
      icon: isIn ? Icons.arrow_downward : Icons.arrow_upward,
      isIn: isIn,
      titre: titre,
      sousTitre: sousTitre,
      montant: isIn ? '+$montant F' : '-$montant F',
    );
  }
}

// ─── Hero (solde + escrow + 2 boutons) ───────────────────────────────────

class _Hero extends StatelessWidget {
  const _Hero({required this.balance, required this.escrow});

  final double balance;
  final double escrow;

  @override
  Widget build(BuildContext context) {
    final formatted = NumberFormat('#,##0', 'fr_FR').format(balance);
    final formattedEscrow = NumberFormat('#,##0', 'fr_FR').format(escrow);
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: AppDimens.brCard,
        border: Border.all(color: AppColors.border, width: AppDimens.borderThin),
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
            'En escrow : $formattedEscrow F',
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
                  onTap: () =>
                      context.push(RouteNames.acheteurWalletRechargerPath),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _HeroButton(
                  label: 'Retirer',
                  primary: false,
                  onTap: () =>
                      context.push(RouteNames.acheteurWalletRetirerPath),
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
    final borderColor = primary ? AppColors.primary : AppColors.primary;
    return InkWell(
      onTap: onTap,
      borderRadius: AppDimens.brButton,
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: AppDimens.brButton,
          border: Border.all(color: borderColor, width: AppDimens.borderThin),
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

// ─── Chips filtres ───────────────────────────────────────────────────────

class _Chips extends StatelessWidget {
  const _Chips({required this.filter, required this.onChange});

  final _FilterChip filter;
  final ValueChanged<_FilterChip> onChange;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: ListView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        children: [
          _Chip(
            label: 'Tout',
            active: filter == _FilterChip.tout,
            onTap: () => onChange(_FilterChip.tout),
          ),
          const SizedBox(width: 8),
          _Chip(
            label: 'Achats',
            active: filter == _FilterChip.achats,
            onTap: () => onChange(_FilterChip.achats),
          ),
          const SizedBox(width: 8),
          _Chip(
            label: 'Recharges',
            active: filter == _FilterChip.recharges,
            onTap: () => onChange(_FilterChip.recharges),
          ),
          const SizedBox(width: 8),
          _Chip(
            label: 'Escrow',
            active: filter == _FilterChip.escrow,
            onTap: () => onChange(_FilterChip.escrow),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: active ? AppColors.primary : AppColors.background,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: active ? AppColors.primary : AppColors.border,
            width: AppDimens.borderThin,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: AppTextStyles.labelMedium.copyWith(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: active ? AppColors.onPrimary : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

// ─── Liste card ──────────────────────────────────────────────────────────

class _ListCard extends StatelessWidget {
  const _ListCard({required this.items});

  final List<_MockTx> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border, width: AppDimens.borderThin),
      ),
      clipBehavior: Clip.hardEdge,
      child: items.isEmpty
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
              children: List.generate(items.length, (i) {
                return _TxRow(tx: items[i], isLast: i == items.length - 1);
              }),
            ),
    );
  }
}

class _TxRow extends StatelessWidget {
  const _TxRow({required this.tx, required this.isLast});

  final _MockTx tx;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final bubbleBg = tx.isIn ? _kPrimarySoft : _kBgSoftIcon;
    final bubbleFg = tx.isIn ? AppColors.primary : AppColors.textSecondary;
    final amountColor = tx.isIn ? AppColors.primary : AppColors.text;
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
            child: Icon(tx.icon, size: 18, color: bubbleFg),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  tx.titre,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  tx.sousTitre,
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
            tx.montant,
            style: AppTextStyles.titleSmall.copyWith(
              fontFamily: AppTextStyles.displayLarge.fontFamily,
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

