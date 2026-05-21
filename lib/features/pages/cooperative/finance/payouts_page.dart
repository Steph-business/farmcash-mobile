import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../models/payout.dart';
import '../../../../routing/route_names.dart';
import '../../../../services/providers.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';
import '../../../widgets/communs/chargement.dart';
import '../../../widgets/communs/vue_erreur.dart';

// ─── Couleurs accent ─────────────────────────────────────────────────────

const Color _kPrimarySoft = Color(0xFFE8F5E9);

/// Tabs disponibles sur la liste des distributions.
enum _PayoutTab { aDistribuer, historique }

/// Provider qui charge les batches du backend.
final _payoutsProvider = FutureProvider.autoDispose<List<PayoutBatch>>((ref) {
  return ref.read(financeServiceProvider).listPayoutBatches();
});

/// Page Distributions coopérative — liste des batches de payouts.
class PayoutsCooperativePage extends ConsumerStatefulWidget {
  const PayoutsCooperativePage({super.key});

  @override
  ConsumerState<PayoutsCooperativePage> createState() =>
      _PayoutsCooperativePageState();
}

class _PayoutsCooperativePageState
    extends ConsumerState<PayoutsCooperativePage> {
  _PayoutTab _tab = _PayoutTab.aDistribuer;

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(_payoutsProvider);
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
                  padding: EdgeInsets.only(top: 48),
                  child: Chargement(size: 22),
                ),
                error: (e, _) => Padding(
                  padding: const EdgeInsets.all(AppDimens.pagePaddingH),
                  child: VueErreur(
                    message: 'Impossible de charger les distributions. $e',
                    onRetry: () => ref.invalidate(_payoutsProvider),
                  ),
                ),
                data: (all) {
                  final aDistribuer = all
                      .where((p) =>
                          p.status.toUpperCase() == 'PENDING' ||
                          p.status.toUpperCase() == 'PROCESSING')
                      .toList(growable: false);
                  final historique = all
                      .where((p) =>
                          p.status.toUpperCase() != 'PENDING' &&
                          p.status.toUpperCase() != 'PROCESSING')
                      .toList(growable: false);
                  final tabList = _tab == _PayoutTab.aDistribuer
                      ? aDistribuer
                      : historique;
                  final totalMontant = aDistribuer.fold<double>(
                    0,
                    (acc, p) => acc + p.totalAmount,
                  );
                  return RefreshIndicator(
                    color: AppColors.primary,
                    onRefresh: () async {
                      ref.invalidate(_payoutsProvider);
                      await ref.read(_payoutsProvider.future);
                    },
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(
                        AppDimens.pagePaddingH,
                        0,
                        AppDimens.pagePaddingH,
                        AppDimens.space16,
                      ),
                      children: [
                        _CounterCard(
                          value:
                              '${aDistribuer.length} distribution(s) à faire',
                          sub: '${_fmt(totalMontant)} F total',
                        ),
                        AppDimens.vGap16,
                        _TabsBar(
                          tab: _tab,
                          aDistribuerCount: aDistribuer.length,
                          historiqueCount: historique.length,
                          onChange: (t) => setState(() => _tab = t),
                        ),
                        AppDimens.vGap16,
                        if (tabList.isEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 24),
                            child: Center(
                              child: Text(
                                _tab == _PayoutTab.aDistribuer
                                    ? 'Aucune distribution en attente.'
                                    : 'Aucun historique pour le moment.',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                          )
                        else
                          for (final p in tabList) ...[
                            _PayoutCard(payout: p),
                            const SizedBox(height: 12),
                          ],
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
              'Distributions',
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
        child: const Center(
          child: Icon(
            Icons.notifications_none,
            size: 22,
            color: AppColors.text,
          ),
        ),
      ),
    );
  }
}

// ─── Counter card (primary-soft) ─────────────────────────────────────────

class _CounterCard extends StatelessWidget {
  const _CounterCard({required this.value, required this.sub});

  final String value;
  final String sub;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: _kPrimarySoft,
        borderRadius: AppDimens.brCard,
        border: Border.all(
          color: AppColors.border,
          width: AppDimens.borderThin,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: AppTextStyles.titleLarge.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            sub,
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

// ─── Tabs (À distribuer / Historique) ────────────────────────────────────

class _TabsBar extends StatelessWidget {
  const _TabsBar({
    required this.tab,
    required this.aDistribuerCount,
    required this.historiqueCount,
    required this.onChange,
  });

  final _PayoutTab tab;
  final int aDistribuerCount;
  final int historiqueCount;
  final ValueChanged<_PayoutTab> onChange;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppColors.border,
            width: AppDimens.borderThin,
          ),
        ),
      ),
      child: Row(
        children: [
          _TabItem(
            label: 'À distribuer ($aDistribuerCount)',
            active: tab == _PayoutTab.aDistribuer,
            onTap: () => onChange(_PayoutTab.aDistribuer),
          ),
          _TabItem(
            label: 'Historique ($historiqueCount)',
            active: tab == _PayoutTab.historique,
            onTap: () => onChange(_PayoutTab.historique),
          ),
        ],
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  const _TabItem({
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
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

// ─── Payout card ─────────────────────────────────────────────────────────

class _PayoutCard extends StatelessWidget {
  const _PayoutCard({required this.payout});

  final PayoutBatch payout;

  @override
  Widget build(BuildContext context) {
    final memo = 'Distribution #${payout.id.substring(0, payout.id.length.clamp(0, 8))}';
    final sousTitre = '${payout.items.length} ligne(s) · '
        '${_fmt(payout.totalAmount)} F';
    final dateLabel = payout.createdAt != null
        ? 'Créé le ${DateFormat('dd/MM').format(payout.createdAt!.toLocal())}'
        : '';
    final statusKey = payout.status.toUpperCase();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: AppDimens.brCard,
        border: Border.all(
          color: AppColors.border,
          width: AppDimens.borderThin,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            memo,
            style: AppTextStyles.titleSmall.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            sousTitre,
            style: AppTextStyles.bodySmall.copyWith(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          if (dateLabel.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              dateLabel,
              style: AppTextStyles.labelSmall.copyWith(
                fontSize: 11,
                color: AppColors.textSubtle,
              ),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              _ChipStatus(label: _statusLabel(statusKey)),
              const Spacer(),
              _MiniButton(
                label: 'Détail',
                onTap: () => context.push(
                  RouteNames.cooperativePayoutDetailPathFor(payout.id),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

String _statusLabel(String s) {
  switch (s) {
    case 'PENDING':
      return 'En attente';
    case 'PROCESSING':
      return 'En cours';
    case 'COMPLETED':
      return 'Complétée';
    case 'FAILED':
      return 'Échouée';
    default:
      return s;
  }
}

class _ChipStatus extends StatelessWidget {
  const _ChipStatus({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _kPrimarySoft,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: AppTextStyles.labelSmall.copyWith(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: AppColors.primary,
        ),
      ),
    );
  }
}

class _MiniButton extends StatelessWidget {
  const _MiniButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: AppColors.primary,
            width: AppDimens.borderThin,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.labelMedium.copyWith(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.onPrimary,
          ),
        ),
      ),
    );
  }
}

// ─── Helpers ─────────────────────────────────────────────────────────────

String _fmt(double v) {
  final i = v.round();
  if (i < 1000) return '$i';
  final s = '$i';
  final buf = StringBuffer();
  for (var k = 0; k < s.length; k++) {
    if (k > 0 && (s.length - k) % 3 == 0) buf.write(' ');
    buf.write(s[k]);
  }
  return buf.toString();
}
