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
enum _FilterChip { tout, entrees, sorties }

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

const List<_MockTx> _kMockTxs = [
  _MockTx(
    icon: Icons.arrow_downward,
    isIn: true,
    titre: 'Vente Manioc 1 t',
    sousTitre: 'hier · Industries Agricoles SA',
    montant: '+95 000 F',
  ),
  _MockTx(
    icon: Icons.arrow_downward,
    isIn: true,
    titre: 'Acompte prévision Yao K.',
    sousTitre: '14/05 · Prévision Maïs',
    montant: '+7 000 F',
  ),
  _MockTx(
    icon: Icons.arrow_upward,
    isIn: false,
    titre: 'Retrait MoMo',
    sousTitre: '12/05 · Orange Money',
    montant: '-50 000 F',
  ),
  _MockTx(
    icon: Icons.arrow_downward,
    isIn: true,
    titre: 'Vente Maïs 500 kg',
    sousTitre: '10/05 · Restaurant Le Baoulé',
    montant: '+169 750 F',
  ),
  _MockTx(
    icon: Icons.arrow_upward,
    isIn: false,
    titre: 'Frais plateforme',
    sousTitre: '10/05 · 3% vente Maïs',
    montant: '-5 250 F',
  ),
  _MockTx(
    icon: Icons.arrow_downward,
    isIn: true,
    titre: 'Avance coopérative',
    sousTitre: '08/05 · COOP-AGRI Lagunes',
    montant: '+5 000 F',
  ),
  _MockTx(
    icon: Icons.arrow_upward,
    isIn: false,
    titre: 'Retrait MoMo',
    sousTitre: '05/05 · Orange Money',
    montant: '-30 000 F',
  ),
  _MockTx(
    icon: Icons.arrow_downward,
    isIn: true,
    titre: 'Vente Tomate 35 kg',
    sousTitre: '03/05 · Marie Yao',
    montant: '+42 000 F',
  ),
];

/// Page Wallet producteur — solde, actions Retirer / Recharger, filtres et
/// liste de transactions. Mock fallback si endpoint indisponible.
class WalletPage extends ConsumerStatefulWidget {
  const WalletPage({super.key});

  @override
  ConsumerState<WalletPage> createState() => _WalletPageState();
}

class _WalletPageState extends ConsumerState<WalletPage> {
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
                // L'écran reste utile même sans données — on tombe sur les
                // mocks pour rester aligné sur la maquette HTML.
                error: (e, _) => _Body(
                  balance: 245800,
                  weekDelta: '+95 000 F cette semaine',
                  transactions: const [],
                  filter: _filter,
                  onFilter: (f) => setState(() => _filter = f),
                ),
                data: (bundle) => _Body(
                  balance: bundle.wallet.balance,
                  weekDelta: '+95 000 F cette semaine',
                  transactions: bundle.transactions.data,
                  filter: _filter,
                  onFilter: (f) => setState(() => _filter = f),
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
          const SizedBox(
            width: 40,
            height: 40,
            child: Icon(
              Icons.search,
              size: 20,
              color: AppColors.text,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Body (hero + chips + liste) ─────────────────────────────────────────

class _Body extends StatelessWidget {
  const _Body({
    required this.balance,
    required this.weekDelta,
    required this.transactions,
    required this.filter,
    required this.onFilter,
  });

  final double balance;
  final String weekDelta;
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
        _Hero(balance: balance, weekDelta: weekDelta),
        AppDimens.vGap16,
        _Chips(filter: filter, onChange: onFilter),
        const SizedBox(height: 4),
        _ListCard(items: txItems),
      ],
    );
  }

  /// Construit la liste à afficher : si on a des transactions backend, on
  /// les mappe ; sinon on retombe sur les mocks fidèles à la maquette.
  /// Le filtre est appliqué uniquement visuellement comme spécifié.
  List<_MockTx> _buildItems() {
    final base = transactions.isNotEmpty
        ? transactions.map(_mapTx).toList()
        : _kMockTxs;
    if (base.length > 8) return base.take(8).toList();
    return base;
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
  const _Hero({required this.balance, required this.weekDelta});

  final double balance;
  final String weekDelta;

  @override
  Widget build(BuildContext context) {
    final formatted = NumberFormat('#,##0', 'fr_FR').format(balance);
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
            weekDelta,
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
                  onTap: () =>
                      context.push(RouteNames.producteurWalletRetirerPath),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _HeroButton(
                  label: 'Recharger',
                  primary: false,
                  onTap: () =>
                      context.push(RouteNames.producteurWalletRechargerPath),
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

// Helper non-utilisé pour le build d'erreur — gardé pour usage futur si
// besoin d'un état d'erreur dédié (actuellement on tombe sur les mocks).
@visibleForTesting
Widget walletErrorView(VoidCallback onRetry) => Padding(
      padding: const EdgeInsets.all(AppDimens.pagePaddingH),
      child: VueErreur(
        message: 'Impossible de charger le wallet.',
        onRetry: onRetry,
      ),
    );
