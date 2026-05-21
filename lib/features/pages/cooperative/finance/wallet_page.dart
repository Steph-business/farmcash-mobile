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

/// Filtres affichés sur la liste des transactions wallet coop.
/// Comme côté producteur, le filtre est purement visuel — la maquette
/// HTML ne fait pas de filtrage réel sur les chips.
enum _FilterChip { tout, entrees, sorties, avances }

/// Charge wallet + transactions paginées (1 seul appel backend).
final _walletProvider = FutureProvider.autoDispose<WalletWithTransactions>(
  (ref) => ref.watch(financeServiceProvider).getWallet(limit: 20),
);

/// Modèle mock fidèle à la maquette HTML — utilisé quand l'endpoint
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

/// Page Wallet coopérative — solde, actions Retirer / Recharger, filtres
/// et liste de transactions. Mock fallback si endpoint indisponible.
/// Reproduction fidèle de `mockups/cooperative/wallet.html`.
class WalletCooperativePage extends ConsumerStatefulWidget {
  const WalletCooperativePage({super.key});

  @override
  ConsumerState<WalletCooperativePage> createState() =>
      _WalletCooperativePageState();
}

class _WalletCooperativePageState extends ConsumerState<WalletCooperativePage> {
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
            onTap: () => context.canPop()
                ? context.pop()
                : context.go(RouteNames.accueilCooperativePath),
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
              'Finance · Wallet',
              style: AppTextStyles.titleSmall.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(
            width: 40,
            height: 40,
            child: Icon(Icons.search, size: 20, color: AppColors.text),
          ),
          _NotifsButton(
            onTap: () => context.push(RouteNames.cooperativeNotificationsPath),
          ),
        ],
      ),
    );
  }
}

class _NotifsButton extends StatelessWidget {
  const _NotifsButton({required this.onTap});

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
                constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
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
    final txItems = transactions.map(_mapTx).toList();

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
        const _SectionHead(titre: 'Transactions récentes'),
        _ListCard(items: txItems),
      ],
    );
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

// ─── Hero (solde + 2 boutons) ────────────────────────────────────────────

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
            'Solde actuel',
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
                  label: 'Retirer',
                  primary: true,
                  onTap: () => _snack(context, 'Retrait — à venir'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _HeroButton(
                  label: 'Recharger',
                  primary: false,
                  onTap: () => _snack(context, 'Recharge — à venir'),
                ),
              ),
            ],
          ),
        ],
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
    final borderColor = AppColors.primary;
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
            label: 'Entrées',
            active: filter == _FilterChip.entrees,
            onTap: () => onChange(_FilterChip.entrees),
          ),
          const SizedBox(width: 8),
          _Chip(
            label: 'Sorties',
            active: filter == _FilterChip.sorties,
            onTap: () => onChange(_FilterChip.sorties),
          ),
          const SizedBox(width: 8),
          _Chip(
            label: 'Avances',
            active: filter == _FilterChip.avances,
            onTap: () => onChange(_FilterChip.avances),
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

// ─── Section head + Liste card ───────────────────────────────────────────

class _SectionHead extends StatelessWidget {
  const _SectionHead({required this.titre});

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

class _ListCard extends StatelessWidget {
  const _ListCard({required this.items});

  final List<_MockTx> items;

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
      child: Column(
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

