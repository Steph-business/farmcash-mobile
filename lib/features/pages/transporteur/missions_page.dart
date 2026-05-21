import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../models/enums.dart';
import '../../../models/livraison.dart';
import '../../../routing/route_names.dart';
import '../../../services/providers.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_dimens.dart';
import '../../../theme/app_text_styles.dart';
import '../../widgets/communs/chargement.dart';
import '../../widgets/communs/header_utilisateur.dart';
import '../../widgets/communs/vue_erreur.dart';

// ─── Couleurs locales ──────────────────────────────────────────────────

const Color _kPrimarySoft = Color(0xFFE8F5E9);
const Color _kWarnSoft = Color(0xFFFEF3C7);
const Color _kWarn = Color(0xFFB45309);

enum _MissionTab { enCours, disponibles, terminees }

const Set<ShipmentStatus> _kEnCours = {
  ShipmentStatus.accepted,
  ShipmentStatus.loading,
  ShipmentStatus.inTransit,
};

const Set<ShipmentStatus> _kTerminees = {
  ShipmentStatus.delivered,
  ShipmentStatus.cancelled,
};

/// Bundle missions transporteur : ses missions (statuts confondus) +
/// les missions disponibles à accepter (pour le compteur de l'onglet).
class _MissionsData {
  const _MissionsData({
    required this.mesShipments,
    required this.disponibles,
  });
  final List<Livraison> mesShipments;
  final List<Livraison> disponibles;
}

/// On charge à la fois les missions disponibles (pour le compteur
/// "Disponibles (N)") et celles déjà acceptées par le transporteur
/// (lifecycle en cours/terminées).
///
/// `GET /logistics/missions/available` ne renvoie que les REQUESTED
/// matchant les routes du transporteur. `GET /logistics/shipments/my`
/// retourne les shipments acceptés (tous statuts confondus).
final _missionsTransporteurProvider =
    FutureProvider.autoDispose<_MissionsData>((ref) async {
  final svc = ref.watch(logisticsServiceProvider);
  final results = await Future.wait([
    svc.getMyMissions(),
    svc.getAvailableMissions(),
  ]);
  return _MissionsData(
    mesShipments: results[0],
    disponibles: results[1],
  );
});

class MissionsTransporteurPage extends ConsumerStatefulWidget {
  const MissionsTransporteurPage({super.key});

  @override
  ConsumerState<MissionsTransporteurPage> createState() =>
      _MissionsTransporteurPageState();
}

class _MissionsTransporteurPageState
    extends ConsumerState<MissionsTransporteurPage> {
  _MissionTab _tab = _MissionTab.enCours;

  Future<void> _refresh() async {
    ref.invalidate(_missionsTransporteurProvider);
    await ref.read(_missionsTransporteurProvider.future);
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(_missionsTransporteurProvider);
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const HeaderUtilisateur(variant: HeaderVariant.transporteur),
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
                    message: 'Impossible de charger les missions. $e',
                    onRetry: _refresh,
                  ),
                ),
                data: (data) => _buildContent(data),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(_MissionsData data) {
    final enCours = data.mesShipments
        .where((m) => _kEnCours.contains(m.status))
        .toList();
    final terminees = data.mesShipments
        .where((m) => _kTerminees.contains(m.status))
        .toList();
    final listeFiltree = switch (_tab) {
      _MissionTab.enCours => enCours,
      _MissionTab.terminees => terminees,
      _MissionTab.disponibles => data.disponibles,
    };

    final headerText = enCours.isEmpty
        ? 'Aucune mission en cours · ${data.disponibles.length} dispo'
        : '${enCours.length} mission${enCours.length > 1 ? 's' : ''} en cours';

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: _refresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          AppDimens.pagePaddingH,
          0,
          AppDimens.pagePaddingH,
          AppDimens.space16,
        ),
        children: [
          _CounterHero(texte: headerText),
          AppDimens.vGap16,
          _TabBar(
            current: _tab,
            enCoursCount: enCours.length,
            disponiblesCount: data.disponibles.length,
            terminees: terminees.length,
            onSelect: (t) => setState(() => _tab = t),
          ),
          AppDimens.vGap12,
          if (listeFiltree.isEmpty)
            _EmptyState(tab: _tab)
          else
            ...listeFiltree.map(
              (m) => _MissionCard(
                mission: m,
                onTap: () => context.push(
                  RouteNames.transporteurMissionDetailPathFor(m.id),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ─── Titre ─────────────────────────────────────────────────────────────

class _PageTitle extends StatelessWidget {
  const _PageTitle();
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppDimens.pagePaddingH,
        AppDimens.space8,
        AppDimens.pagePaddingH,
        AppDimens.space8,
      ),
      child: Text(
        'Missions',
        style: AppTextStyles.displayLarge.copyWith(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          height: 1.2,
          letterSpacing: -0.3,
        ),
      ),
    );
  }
}

// ─── Hero ──────────────────────────────────────────────────────────────

class _CounterHero extends StatelessWidget {
  const _CounterHero({required this.texte});
  final String texte;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
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
              Icons.local_shipping_outlined,
              size: 18,
              color: AppColors.onPrimary,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              texte,
              style: AppTextStyles.bodyMedium.copyWith(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Tabs ──────────────────────────────────────────────────────────────

class _TabBar extends StatelessWidget {
  const _TabBar({
    required this.current,
    required this.enCoursCount,
    required this.disponiblesCount,
    required this.terminees,
    required this.onSelect,
  });
  final _MissionTab current;
  final int enCoursCount;
  final int disponiblesCount;
  final int terminees;
  final ValueChanged<_MissionTab> onSelect;

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
          _tab(_MissionTab.enCours, 'En cours ($enCoursCount)'),
          const SizedBox(width: 18),
          _tab(_MissionTab.disponibles, 'Disponibles ($disponiblesCount)'),
          const SizedBox(width: 18),
          _tab(_MissionTab.terminees, 'Terminées ($terminees)'),
        ],
      ),
    );
  }

  Widget _tab(_MissionTab value, String label) {
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

// ─── Mission card ─────────────────────────────────────────────────────

class _MissionCard extends StatelessWidget {
  const _MissionCard({required this.mission, required this.onTap});
  final Livraison mission;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final reference = mission.reference ??
        mission.commandeId.substring(0, 8).toUpperCase();
    final itineraire = mission.itineraireLabel ??
        '${mission.pickupAddress ?? '—'} → ${mission.deliveryAddress ?? '—'}';
    final qte = mission.quantiteKg != null
        ? '${_nf.format(mission.quantiteKg!.round())} kg'
        : null;
    final prix = mission.prixDevis ?? mission.prixFinal;
    final prixLabel =
        prix != null ? '+${_nf.format(prix.round())} F' : 'à fixer';
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: AppColors.border,
              width: AppDimens.borderThin,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _StatusBadge(status: mission.status),
              const SizedBox(height: 10),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: _kPrimarySoft,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.local_shipping_outlined,
                      size: 24,
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
                          'Commande #$reference',
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 3),
                        Text(
                          itineraire,
                          style: AppTextStyles.bodySmall.copyWith(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                            height: 1.4,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (qte != null) ...[
                          const SizedBox(height: 3),
                          Text(
                            qte,
                            style: AppTextStyles.labelSmall.copyWith(
                              fontSize: 11,
                              color: AppColors.textSubtle,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Icon(
                    Icons.chevron_right,
                    size: 18,
                    color: AppColors.textSubtle,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const Divider(
                height: 1,
                thickness: 1,
                color: AppColors.border,
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _scheduleLabel(mission),
                      style: AppTextStyles.labelSmall.copyWith(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  Text(
                    prixLabel,
                    style: AppTextStyles.titleSmall.copyWith(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _scheduleLabel(Livraison m) {
    final df = DateFormat('d MMM HH:mm', 'fr_FR');
    if (m.scheduledAt != null) return 'Prévu ${df.format(m.scheduledAt!)}';
    if (m.createdAt != null) return 'Publié ${df.format(m.createdAt!)}';
    return '—';
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});
  final ShipmentStatus status;

  @override
  Widget build(BuildContext context) {
    final (bg, fg, label) = _spec();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 5,
            height: 5,
            decoration: BoxDecoration(color: fg, shape: BoxShape.circle),
          ),
          const SizedBox(width: 5),
          Text(
            label.toUpperCase(),
            style: AppTextStyles.labelSmall.copyWith(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: fg,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  (Color, Color, String) _spec() {
    switch (status) {
      case ShipmentStatus.requested:
        return (_kWarnSoft, _kWarn, 'À accepter');
      case ShipmentStatus.accepted:
        return (_kPrimarySoft, AppColors.primary, 'Acceptée');
      case ShipmentStatus.loading:
        return (_kPrimarySoft, AppColors.primary, 'Enlèvement');
      case ShipmentStatus.inTransit:
        return (_kPrimarySoft, AppColors.primary, 'En route');
      case ShipmentStatus.delivered:
        return (_kPrimarySoft, AppColors.primary, 'Livrée');
      case ShipmentStatus.cancelled:
        return (const Color(0xFFE5E7EB), AppColors.textSecondary, 'Annulée');
      case ShipmentStatus.unknown:
        return (const Color(0xFFE5E7EB), AppColors.textSecondary, '—');
    }
  }
}

// ─── Empty state ───────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.tab});
  final _MissionTab tab;

  @override
  Widget build(BuildContext context) {
    final msg = switch (tab) {
      _MissionTab.enCours =>
        'Aucune mission en cours. Accepte une mission depuis « Disponibles ».',
      _MissionTab.disponibles =>
        'Aucune mission disponible dans tes zones. Vérifie tes itinéraires.',
      _MissionTab.terminees => 'Tu n\'as pas encore livré de mission.',
    };
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 32,
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.local_shipping_outlined,
              size: 40,
              color: AppColors.textSubtle.withValues(alpha: 0.9),
            ),
            const SizedBox(height: 12),
            Text(
              msg,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

final _nf = NumberFormat('#,##0', 'fr_FR');
