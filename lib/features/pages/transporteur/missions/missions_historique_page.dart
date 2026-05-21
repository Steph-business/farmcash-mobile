import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../models/enums.dart';
import '../../../../models/livraison.dart';
import '../../../../routing/route_names.dart';
import '../../../../services/providers.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';
import '../../../widgets/communs/chargement.dart';
import '../../../widgets/communs/vue_erreur.dart';

const Color _kPrimarySoft = Color(0xFFE8F5E9);
const Color _kErrorSoft = Color(0xFFFEE2E2);

const BorderRadius _kBrCard = BorderRadius.all(Radius.circular(12));

enum _HistoriqueTab { livrees, annulees }

/// Bundle missions terminées (livrées + annulées) du TRANSPORTER connecté.
class _HistoriqueData {
  const _HistoriqueData({required this.livrees, required this.annulees});
  final List<Livraison> livrees;
  final List<Livraison> annulees;
}

final _historiqueProvider =
    FutureProvider.autoDispose<_HistoriqueData>((ref) async {
  final svc = ref.watch(logisticsServiceProvider);
  final results = await Future.wait([
    svc.getMyMissions(status: ShipmentStatus.delivered),
    svc.getMyMissions(status: ShipmentStatus.cancelled),
  ]);
  return _HistoriqueData(livrees: results[0], annulees: results[1]);
});

/// Page « Historique des missions » — onglets Livrées / Annulées avec
/// récap total gains pour les missions livrées.
class MissionsHistoriquePage extends ConsumerStatefulWidget {
  const MissionsHistoriquePage({super.key});

  @override
  ConsumerState<MissionsHistoriquePage> createState() =>
      _MissionsHistoriquePageState();
}

class _MissionsHistoriquePageState
    extends ConsumerState<MissionsHistoriquePage> {
  _HistoriqueTab _tab = _HistoriqueTab.livrees;

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(_historiqueProvider);
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
                    message: 'Impossible de charger l\'historique. $e',
                    onRetry: () => ref.invalidate(_historiqueProvider),
                  ),
                ),
                data: (data) => _build(data),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _build(_HistoriqueData data) {
    final items =
        _tab == _HistoriqueTab.livrees ? data.livrees : data.annulees;
    final totalGains = data.livrees.fold<double>(
      0,
      (acc, m) => acc + (m.prixFinal ?? m.prixDevis ?? 0),
    );

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () async => ref.invalidate(_historiqueProvider),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          AppDimens.pagePaddingH,
          AppDimens.space12,
          AppDimens.pagePaddingH,
          AppDimens.space16,
        ),
        children: [
          _RecapBanner(
            totalLivrees: data.livrees.length,
            totalGains: totalGains,
          ),
          AppDimens.vGap12,
          _TabBar(
            current: _tab,
            livreesCount: data.livrees.length,
            annuleesCount: data.annulees.length,
            onSelect: (t) => setState(() => _tab = t),
          ),
          AppDimens.vGap12,
          if (items.isEmpty)
            _EmptyState(tab: _tab)
          else
            for (final m in items) ...[
              _MissionRow(
                mission: m,
                onTap: () => context.push(
                  RouteNames.transporteurMissionDetailPathFor(m.id),
                ),
              ),
              const SizedBox(height: 10),
            ],
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

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
                : context.go(RouteNames.transporteurMissionsPath),
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
              'Historique des missions',
              style: AppTextStyles.titleSmall.copyWith(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RecapBanner extends StatelessWidget {
  const _RecapBanner({
    required this.totalLivrees,
    required this.totalGains,
  });

  final int totalLivrees;
  final double totalGains;

  @override
  Widget build(BuildContext context) {
    final gains = _nf.format(totalGains.round());
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: _kPrimarySoft,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.check_circle_outline,
              size: 18,
              color: AppColors.onPrimary,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$totalLivrees mission${totalLivrees > 1 ? 's' : ''} livrée${totalLivrees > 1 ? 's' : ''}',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  totalGains > 0
                      ? '+$gains F au total'
                      : 'Aucun gain enregistré',
                  style: AppTextStyles.labelSmall.copyWith(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TabBar extends StatelessWidget {
  const _TabBar({
    required this.current,
    required this.livreesCount,
    required this.annuleesCount,
    required this.onSelect,
  });
  final _HistoriqueTab current;
  final int livreesCount;
  final int annuleesCount;
  final ValueChanged<_HistoriqueTab> onSelect;

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
          _tab(_HistoriqueTab.livrees, 'Livrées ($livreesCount)'),
          const SizedBox(width: 18),
          _tab(_HistoriqueTab.annulees, 'Annulées ($annuleesCount)'),
        ],
      ),
    );
  }

  Widget _tab(_HistoriqueTab value, String label) {
    final active = value == current;
    return InkWell(
      onTap: () => onSelect(value),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: active ? AppColors.primary : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.labelMedium.copyWith(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: active ? AppColors.primary : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _MissionRow extends StatelessWidget {
  const _MissionRow({required this.mission, required this.onTap});

  final Livraison mission;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final reference = mission.reference ??
        mission.commandeId.substring(
          0,
          mission.commandeId.length < 8 ? mission.commandeId.length : 8,
        ).toUpperCase();
    final trajet = mission.itineraireLabel ??
        '${mission.pickupAddress ?? '—'} → ${mission.deliveryAddress ?? '—'}';
    final dateRef = mission.deliveredAt ?? mission.createdAt;
    final df = DateFormat('d MMM HH:mm', 'fr_FR');
    final dateLabel = dateRef != null ? df.format(dateRef.toLocal()) : '—';
    final prix = mission.prixFinal ?? mission.prixDevis;
    final livree = mission.status == ShipmentStatus.delivered;
    final gain = prix != null
        ? (livree ? '+${_nf.format(prix.round())} F' : '${_nf.format(prix.round())} F')
        : '—';
    final couleurGain = livree ? AppColors.primary : AppColors.textSecondary;

    return InkWell(
      onTap: onTap,
      borderRadius: _kBrCard,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: _kBrCard,
          border:
              Border.all(color: AppColors.border, width: AppDimens.borderThin),
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: livree ? _kPrimarySoft : _kErrorSoft,
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: Icon(
                livree ? Icons.check : Icons.close,
                size: 22,
                color: livree ? AppColors.primary : AppColors.error,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Commande #$reference',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.text,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    trajet,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodySmall.copyWith(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    dateLabel,
                    style: AppTextStyles.labelSmall.copyWith(
                      fontSize: 11,
                      color: AppColors.textSubtle,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              gain,
              style: AppTextStyles.titleSmall.copyWith(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: couleurGain,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.tab});
  final _HistoriqueTab tab;

  @override
  Widget build(BuildContext context) {
    final msg = tab == _HistoriqueTab.livrees
        ? 'Aucune mission livrée pour le moment'
        : 'Aucune mission annulée';
    return Padding(
      padding: const EdgeInsets.all(AppDimens.space24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.history,
            size: 40,
            color: AppColors.textSubtle.withValues(alpha: 0.9),
          ),
          const SizedBox(height: AppDimens.space12),
          Text(
            msg,
            textAlign: TextAlign.center,
            style: AppTextStyles.titleSmall,
          ),
        ],
      ),
    );
  }
}

final _nf = NumberFormat('#,##0', 'fr_FR');
