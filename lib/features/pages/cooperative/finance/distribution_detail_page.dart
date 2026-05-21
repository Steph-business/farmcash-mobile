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

// ─── Couleurs alignées maquette ──────────────────────────────────────────

const Color _kPrimarySoft = Color(0xFFE8F5E9);

/// Provider qui retrouve un batch via `listPayoutBatches()` + filtre par id.
/// Pas d'endpoint `GET /finance/payout-batches/:id` côté backend.
final _payoutDetailProvider = FutureProvider.autoDispose
    .family<PayoutBatch?, String>((ref, id) async {
  final all = await ref.read(financeServiceProvider).listPayoutBatches();
  for (final p in all) {
    if (p.id == id) return p;
  }
  return null;
});

/// Page Distribution détail — items réels du `PayoutBatch`.
///
/// CRITIQUE — règle 3b : la coop voit ses membres FULL (nom complet).
/// Mais les items du batch ne portent qu'un `userId` + montant côté API ;
/// l'enrichissement nom/photo nécessitera un endpoint dédié.
class DistributionDetailPage extends ConsumerWidget {
  const DistributionDetailPage({super.key, required this.payoutId});

  /// Identifiant du payout batch.
  final String payoutId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(_payoutDetailProvider(payoutId));

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
                    message: 'Impossible de charger ce batch. $e',
                    onRetry: () =>
                        ref.invalidate(_payoutDetailProvider(payoutId)),
                  ),
                ),
                data: (batch) {
                  if (batch == null) {
                    return _NotFound();
                  }
                  return _Body(batch: batch);
                },
              ),
            ),
            async.maybeWhen(
              data: (b) => b != null
                  ? _StickyConfirm(payoutId: payoutId)
                  : const SizedBox.shrink(),
              orElse: () => const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.batch});

  final PayoutBatch batch;

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
        _HeroInfo(batch: batch),
        AppDimens.vGap24,
        _SectionContribs(batch: batch),
      ],
    );
  }
}

class _NotFound extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppDimens.pagePaddingH),
      child: Text(
        'Distribution introuvable.',
        style: AppTextStyles.bodyMedium,
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
                : context.go(RouteNames.cooperativePayoutsPath),
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
              'Détail de la distribution',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.titleSmall.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Hero info ───────────────────────────────────────────────────────────

class _HeroInfo extends StatelessWidget {
  const _HeroInfo({required this.batch});

  final PayoutBatch batch;

  @override
  Widget build(BuildContext context) {
    final dateStr = batch.createdAt != null
        ? 'Créé le ${DateFormat('dd/MM/yyyy').format(batch.createdAt!.toLocal())}'
        : 'Date inconnue';
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
            dateStr,
            style: AppTextStyles.bodySmall.copyWith(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${batch.items.length} bénéficiaire(s)',
            style: AppTextStyles.titleLarge.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${_fmt(batch.totalAmount)} F au total',
            style: AppTextStyles.bodySmall.copyWith(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 10),
          _StatusChip(status: batch.status),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _kPrimarySoft,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        _statusLabel(status),
        style: AppTextStyles.labelSmall.copyWith(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: AppColors.primary,
        ),
      ),
    );
  }
}

String _statusLabel(String s) {
  switch (s.toUpperCase()) {
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

// ─── Section contributeurs ───────────────────────────────────────────────

class _SectionContribs extends StatelessWidget {
  const _SectionContribs({required this.batch});

  final PayoutBatch batch;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Text(
            'Bénéficiaires',
            style: AppTextStyles.titleSmall.copyWith(
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        if (batch.items.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Text(
              'Aucun bénéficiaire dans ce batch.',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          )
        else ...[
          _ContribsCard(items: batch.items),
          const SizedBox(height: 10),
          _TotalRow(label: 'Total', value: '${_fmt(batch.totalAmount)} F'),
        ],
      ],
    );
  }
}

class _ContribsCard extends StatelessWidget {
  const _ContribsCard({required this.items});

  final List<PayoutItem> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: AppDimens.brCard,
        border: Border.all(
          color: AppColors.border,
          width: AppDimens.borderThin,
        ),
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        children: List.generate(items.length, (i) {
          return _ContribRow(item: items[i], isLast: i == items.length - 1);
        }),
      ),
    );
  }
}

class _ContribRow extends StatelessWidget {
  const _ContribRow({required this.item, required this.isLast});

  final PayoutItem item;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
            decoration: BoxDecoration(
              color: _kPrimarySoft,
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.border,
                width: AppDimens.borderThin,
              ),
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.person_outline,
              size: 18,
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
                  'Bénéficiaire #${_shortId(item.userId)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.titleSmall.copyWith(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${_providerLabel(item.provider.apiValue)} · ${_statusLabel(item.status)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodySmall.copyWith(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${_fmt(item.amount)} F',
            style: AppTextStyles.titleSmall.copyWith(
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

String _providerLabel(String s) {
  switch (s) {
    case 'ORANGE_MONEY':
      return 'Orange Money';
    case 'MTN_MOMO':
      return 'MTN MoMo';
    case 'WAVE':
      return 'Wave';
    case 'MOOV':
      return 'Moov';
    case 'WALLET':
      return 'Wallet';
    case 'VIREMENT':
      return 'Virement';
    default:
      return s;
  }
}

String _shortId(String id) {
  if (id.length <= 6) return id;
  return id.substring(0, 6);
}

class _TotalRow extends StatelessWidget {
  const _TotalRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: _kPrimarySoft,
        borderRadius: AppDimens.brCard,
        border: Border.all(
          color: AppColors.border,
          width: AppDimens.borderThin,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.titleSmall.copyWith(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            value,
            style: AppTextStyles.titleLarge.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Sticky bottom : Confirmer la distribution ──────────────────────────

class _StickyConfirm extends StatelessWidget {
  const _StickyConfirm({required this.payoutId});

  final String payoutId;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(
          top: BorderSide(
            color: AppColors.border,
            width: AppDimens.borderThin,
          ),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 12),
      child: SizedBox(
        width: double.infinity,
        child: InkWell(
          onTap: () => context.push(
            RouteNames.cooperativePayoutConfirmationPathFor(payoutId),
          ),
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: AppColors.primary,
                width: AppDimens.borderThin,
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              'Confirmer la distribution',
              style: AppTextStyles.labelLarge.copyWith(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.onPrimary,
              ),
            ),
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
