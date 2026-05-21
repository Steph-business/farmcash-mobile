import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../models/commande.dart';
import '../../../models/enums.dart';
import '../../../models/pagination.dart';
import '../../../routing/route_names.dart';
import '../../../services/providers.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_dimens.dart';
import '../../../theme/app_text_styles.dart';
import '../../widgets/communs/chargement.dart';
import '../../widgets/communs/header_utilisateur.dart';
import '../../widgets/communs/vue_erreur.dart';

// ─── Couleurs locales ─────────────────────────────────────────────────

const Color _kPrimarySoft = Color(0xFFE8F5E9);
const Color _kWarnSoft = Color(0xFFFFF8E1);
const Color _kWarn = Color(0xFFB45309);

enum _OrderTab { enCours, livrees, toutes }

// Statuts considérés comme "en cours" pour le filtre côté UI. Les statuts
// "completed" / "delivered" sont considérés comme livrés (avant escrow ou
// après notation).
const Set<OrderStatus> _kEnCoursStatus = {
  OrderStatus.sent,
  OrderStatus.accepted,
  OrderStatus.inProgress,
  OrderStatus.disputed,
};

const Set<OrderStatus> _kLivreesStatus = {
  OrderStatus.delivered,
  OrderStatus.completed,
};

final _commandesAcheteurProvider =
    FutureProvider.autoDispose<List<Commande>>((ref) async {
  final svc = ref.read(ordersServiceProvider);
  final Paginated<Commande> page =
      await svc.listMyOrders(role: 'BUYER', limit: 50);
  return page.data;
});

class CommandesAcheteurPage extends ConsumerStatefulWidget {
  const CommandesAcheteurPage({super.key});

  @override
  ConsumerState<CommandesAcheteurPage> createState() =>
      _CommandesAcheteurPageState();
}

class _CommandesAcheteurPageState
    extends ConsumerState<CommandesAcheteurPage> {
  _OrderTab _tab = _OrderTab.enCours;

  Future<void> _refresh() async {
    ref.invalidate(_commandesAcheteurProvider);
    await ref.read(_commandesAcheteurProvider.future);
  }

  List<Commande> _filter(List<Commande> all) {
    switch (_tab) {
      case _OrderTab.enCours:
        return all.where((c) => _kEnCoursStatus.contains(c.status)).toList();
      case _OrderTab.livrees:
        return all.where((c) => _kLivreesStatus.contains(c.status)).toList();
      case _OrderTab.toutes:
        return all;
    }
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(_commandesAcheteurProvider);
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const HeaderUtilisateur(variant: HeaderVariant.acheteur),
            const _PageTitle(),
            Expanded(
              child: async.when(
                loading: () => const Padding(
                  padding: EdgeInsets.only(top: 48),
                  child: Chargement(size: 22),
                ),
                error: (e, _) => Padding(
                  padding: const EdgeInsets.all(AppDimens.pagePaddingH),
                  child: VueErreur(
                    message: 'Impossible de charger les commandes. $e',
                    onRetry: _refresh,
                  ),
                ),
                data: (all) {
                  final orders = _filter(all);
                  final enCoursCount =
                      all.where((c) => _kEnCoursStatus.contains(c.status))
                          .length;
                  final livreesCount =
                      all.where((c) => _kLivreesStatus.contains(c.status))
                          .length;
                  return RefreshIndicator(
                    color: AppColors.primary,
                    onRefresh: _refresh,
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(
                          20, 0, 20, AppDimens.space16),
                      children: [
                        _CounterBox(
                          valeur: '$enCoursCount en cours',
                          sousTexte: '$livreesCount livrées',
                        ),
                        AppDimens.vGap16,
                        _Tabs(
                          current: _tab,
                          enCoursCount: enCoursCount,
                          livreesCount: livreesCount,
                          onSelect: (t) => setState(() => _tab = t),
                        ),
                        AppDimens.vGap16,
                        if (orders.isEmpty)
                          const _EmptyState()
                        else
                          ...orders.map(
                            (c) => _OrderCard(
                              commande: c,
                              onTap: () => context.push(
                                RouteNames.acheteurCommandeDetailPathFor(c.id),
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Page title ──────────────────────────────────────────────────────

class _PageTitle extends StatelessWidget {
  const _PageTitle();
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          20, AppDimens.space8, 20, AppDimens.space12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Mes commandes',
              style: AppTextStyles.headlineSmall.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Counter box ─────────────────────────────────────────────────────

class _CounterBox extends StatelessWidget {
  const _CounterBox({required this.valeur, required this.sousTexte});
  final String valeur;
  final String sousTexte;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: _kPrimarySoft,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: AppDimens.borderThin),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            valeur,
            style: AppTextStyles.headlineMedium.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            sousTexte,
            style: AppTextStyles.bodySmall.copyWith(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Tabs ─────────────────────────────────────────────────────────────

class _Tabs extends StatelessWidget {
  const _Tabs({
    required this.current,
    required this.enCoursCount,
    required this.livreesCount,
    required this.onSelect,
  });
  final _OrderTab current;
  final int enCoursCount;
  final int livreesCount;
  final ValueChanged<_OrderTab> onSelect;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
              color: AppColors.border, width: AppDimens.borderThin),
        ),
      ),
      child: Row(
        children: [
          _tab(_OrderTab.enCours, 'En cours ($enCoursCount)'),
          _tab(_OrderTab.livrees, 'Livrées ($livreesCount)'),
          _tab(_OrderTab.toutes, 'Toutes'),
        ],
      ),
    );
  }

  Widget _tab(_OrderTab value, String label) {
    final active = value == current;
    return Expanded(
      child: InkWell(
        onTap: () => onSelect(value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: active ? AppColors.primary : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: AppTextStyles.labelMedium.copyWith(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: active ? AppColors.primary : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Order card ───────────────────────────────────────────────────────

class _OrderCard extends StatelessWidget {
  const _OrderCard({required this.commande, required this.onTap});
  final Commande commande;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ref = commande.reference.isNotEmpty
        ? '#${commande.reference}'
        : '#${commande.id.substring(0, 8).toUpperCase()}';
    final df = DateFormat('d MMM', 'fr_FR');
    final qte = '${_nf.format(commande.quantiteKg.round())} kg';
    final montant = '${_nf.format(commande.montantTotal.round())} F';

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color: AppColors.border, width: AppDimens.borderThin),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: _kPrimarySoft,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.local_shipping_outlined,
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
                          'Commande $ref',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          qte,
                          style: AppTextStyles.labelSmall.copyWith(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          montant,
                          style: AppTextStyles.headlineSmall.copyWith(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  _ChipStatut(status: commande.status),
                ],
              ),
              if (commande.livraisonDate != null ||
                  commande.createdAt != null) ...[
                const SizedBox(height: 10),
                const Divider(
                  height: 1,
                  thickness: AppDimens.borderThin,
                  color: AppColors.border,
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    if (commande.livraisonDate != null) ...[
                      const Icon(
                        Icons.event_outlined,
                        size: 14,
                        color: AppColors.textSubtle,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Livraison ${df.format(commande.livraisonDate!)}',
                        style: AppTextStyles.labelSmall.copyWith(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ] else if (commande.createdAt != null) ...[
                      const Icon(
                        Icons.calendar_today_outlined,
                        size: 14,
                        color: AppColors.textSubtle,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Passée ${df.format(commande.createdAt!)}',
                        style: AppTextStyles.labelSmall.copyWith(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ChipStatut extends StatelessWidget {
  const _ChipStatut({required this.status});
  final OrderStatus status;

  @override
  Widget build(BuildContext context) {
    final (bg, fg, label) = _spec(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: AppTextStyles.labelSmall.copyWith(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: fg,
          height: 1.2,
        ),
      ),
    );
  }

  (Color, Color, String) _spec(OrderStatus s) {
    switch (s) {
      case OrderStatus.sent:
        return (_kWarnSoft, _kWarn, 'Envoyée');
      case OrderStatus.accepted:
        return (_kPrimarySoft, AppColors.primary, 'Acceptée');
      case OrderStatus.rejected:
        return (const Color(0xFFFEE2E2), AppColors.error, 'Refusée');
      case OrderStatus.inProgress:
        return (_kPrimarySoft, AppColors.primary, 'En cours');
      case OrderStatus.delivered:
        return (_kPrimarySoft, AppColors.primary, 'Livrée');
      case OrderStatus.completed:
        return (_kPrimarySoft, AppColors.primary, 'Clôturée');
      case OrderStatus.disputed:
        return (_kWarnSoft, _kWarn, 'Litige');
      case OrderStatus.cancelled:
        return (
          const Color(0xFFE5E7EB),
          AppColors.textSecondary,
          'Annulée',
        );
      case OrderStatus.unknown:
        return (
          const Color(0xFFE5E7EB),
          AppColors.textSecondary,
          '—',
        );
    }
  }
}

// ─── Empty state ─────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState();
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppDimens.space24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 40,
            color: AppColors.textSubtle.withValues(alpha: 0.9),
          ),
          const SizedBox(height: AppDimens.space12),
          Text(
            'Aucune commande dans cet onglet',
            style: AppTextStyles.titleSmall,
          ),
        ],
      ),
    );
  }
}

final _nf = NumberFormat('#,##0', 'fr_FR');
