import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../api_client/api_exception.dart';
import '../../../../models/coop_collection.dart';
import '../../../../models/coop_vehicle.dart';
import '../../../../routing/route_names.dart';
import '../../../../services/providers.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';
import '../../../widgets/communs/chargement.dart';
import '../../../widgets/communs/snackbars.dart';
import '../../../widgets/communs/vue_erreur.dart';

const Color _kPrimarySoft = Color(0xFFE8F5E9);
const BorderRadius _kBrCard = BorderRadius.all(Radius.circular(12));

enum _LogiTab { parc, collectes }

/// Bundle parc + collectes actives (PLANNED + IN_PROGRESS).
class _LogiData {
  const _LogiData({required this.vehicles, required this.collections});
  final List<CoopVehicle> vehicles;
  final List<CoopCollection> collections;
}

final _logiProvider = FutureProvider.autoDispose<_LogiData>((ref) async {
  final svc = ref.read(coopLogisticsServiceProvider);
  final results = await Future.wait([
    svc.listVehicles(),
    svc.listCollections(),
  ]);
  final vehicles = results[0] as List<CoopVehicle>;
  final allCollections = results[1] as List<CoopCollection>;
  // Filtre côté client : on garde PLANNED + IN_PROGRESS (les collectes
  // terminées et annulées sont consultables depuis l'historique).
  final actives = allCollections
      .where((c) => c.status == 'PLANNED' || c.status == 'IN_PROGRESS')
      .toList();
  return _LogiData(vehicles: vehicles, collections: actives);
});

/// Page Logistique côté coopérative : 2 onglets (Parc + Collectes).
class LogistiqueCooperativePage extends ConsumerStatefulWidget {
  const LogistiqueCooperativePage({super.key});

  @override
  ConsumerState<LogistiqueCooperativePage> createState() =>
      _LogistiqueCooperativePageState();
}

class _LogistiqueCooperativePageState
    extends ConsumerState<LogistiqueCooperativePage> {
  _LogiTab _tab = _LogiTab.parc;

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(_logiProvider);
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
                    message:
                        'Impossible de charger la logistique. $e',
                    onRetry: () => ref.invalidate(_logiProvider),
                  ),
                ),
                data: (data) => _build(data),
              ),
            ),
            const _Fabs(),
          ],
        ),
      ),
    );
  }

  Widget _build(_LogiData data) {
    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () async => ref.invalidate(_logiProvider),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          AppDimens.pagePaddingH,
          AppDimens.space12,
          AppDimens.pagePaddingH,
          AppDimens.space24,
        ),
        children: [
          _TabBar(
            current: _tab,
            parcCount: data.vehicles.length,
            collectesCount: data.collections.length,
            onSelect: (t) => setState(() => _tab = t),
          ),
          AppDimens.vGap12,
          if (_tab == _LogiTab.parc)
            _ParcList(vehicles: data.vehicles)
          else
            _CollectesList(collections: data.collections),
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
              'Logistique',
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

class _TabBar extends StatelessWidget {
  const _TabBar({
    required this.current,
    required this.parcCount,
    required this.collectesCount,
    required this.onSelect,
  });

  final _LogiTab current;
  final int parcCount;
  final int collectesCount;
  final ValueChanged<_LogiTab> onSelect;

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
          _tab(_LogiTab.parc, 'Parc véhicules ($parcCount)'),
          const SizedBox(width: 18),
          _tab(_LogiTab.collectes, 'Collectes ($collectesCount)'),
        ],
      ),
    );
  }

  Widget _tab(_LogiTab value, String label) {
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

// ─── Parc véhicules ─────────────────────────────────────────────────────

class _ParcList extends StatelessWidget {
  const _ParcList({required this.vehicles});

  final List<CoopVehicle> vehicles;

  @override
  Widget build(BuildContext context) {
    if (vehicles.isEmpty) {
      return const _EmptyState(
        icon: Icons.local_shipping_outlined,
        message: 'Aucun véhicule dans votre parc',
        hint: 'Ajoutez un premier véhicule pour planifier vos collectes.',
      );
    }
    return Column(
      children: [
        for (final v in vehicles) ...[
          _VehicleRow(vehicle: v),
          const SizedBox(height: 10),
        ],
      ],
    );
  }
}

class _VehicleRow extends StatelessWidget {
  const _VehicleRow({required this.vehicle});

  final CoopVehicle vehicle;

  @override
  Widget build(BuildContext context) {
    final immat = (vehicle.immatriculation ?? '').isEmpty
        ? '—'
        : vehicle.immatriculation!;
    final marque = (vehicle.marque ?? '').isEmpty ? '' : vehicle.marque!;
    final chargeLabel = '${_nf.format(vehicle.chargeMaxKg.round())} kg';
    final chauffeur = (vehicle.chauffeurNom ?? '').isEmpty
        ? null
        : vehicle.chauffeurNom!;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: _kBrCard,
        border:
            Border.all(color: AppColors.border, width: AppDimens.borderThin),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: _kPrimarySoft,
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.local_shipping_outlined,
              color: AppColors.primary,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  marque.isEmpty
                      ? '${vehicle.type} · $immat'
                      : '$marque ${vehicle.type} · $immat',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Charge max $chargeLabel'
                  '${chauffeur != null ? ' · $chauffeur' : ''}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodySmall.copyWith(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (!vehicle.isActive)
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.surfaceSoft,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Inactif',
                style: AppTextStyles.labelSmall.copyWith(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ─── Collectes planifiées ───────────────────────────────────────────────

class _CollectesList extends ConsumerWidget {
  const _CollectesList({required this.collections});

  final List<CoopCollection> collections;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (collections.isEmpty) {
      return const _EmptyState(
        icon: Icons.calendar_today_outlined,
        message: 'Aucune collecte planifiée',
        hint: 'Créez une collecte pour aller chercher la marchandise '
            'chez un membre.',
      );
    }
    return Column(
      children: [
        for (final c in collections) ...[
          _CollectionRow(
            collection: c,
            onAction: () => _showActions(context, ref, c),
          ),
          const SizedBox(height: 10),
        ],
      ],
    );
  }

  Future<void> _showActions(
    BuildContext context,
    WidgetRef ref,
    CoopCollection c,
  ) async {
    final action = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(Icons.check_circle_outline,
                  color: AppColors.primary),
              title: const Text('Marquer comme complétée'),
              onTap: () => Navigator.of(ctx).pop('complete'),
            ),
            ListTile(
              leading: const Icon(Icons.cancel_outlined,
                  color: AppColors.error),
              title: const Text('Annuler la collecte'),
              onTap: () => Navigator.of(ctx).pop('cancel'),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
    if (action == null || !context.mounted) return;
    final svc = ref.read(coopLogisticsServiceProvider);
    try {
      if (action == 'complete') {
        await svc.completeCollection(c.id);
        if (!context.mounted) return;
        Snackbars.showSucces(context, 'Collecte marquée complétée');
      } else if (action == 'cancel') {
        await svc.cancelCollection(c.id);
        if (!context.mounted) return;
        Snackbars.showSucces(context, 'Collecte annulée');
      }
      ref.invalidate(_logiProvider);
    } on ApiException catch (e) {
      if (!context.mounted) return;
      Snackbars.showErreur(context, e.message);
    }
  }
}

class _CollectionRow extends StatelessWidget {
  const _CollectionRow({
    required this.collection,
    required this.onAction,
  });

  final CoopCollection collection;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    final farmerNom = collection.farmerNom ?? 'Membre';
    final df = DateFormat('d MMM HH:mm', 'fr_FR');
    final dateLabel = collection.scheduledAt != null
        ? df.format(collection.scheduledAt!.toLocal())
        : '—';
    final qte = '${_nf.format(collection.quantitePrevueKg.round())} kg';
    final inProgress = collection.status == 'IN_PROGRESS';
    return InkWell(
      onTap: onAction,
      borderRadius: _kBrCard,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: _kBrCard,
          border: Border.all(
            color: AppColors.border,
            width: AppDimens.borderThin,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: _kPrimarySoft,
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.agriculture_outlined,
                color: AppColors.primary,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    farmerNom,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '$dateLabel · $qte',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodySmall.copyWith(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  if (collection.pickupAddress.isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Text(
                      collection.pickupAddress,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.labelSmall.copyWith(
                        fontSize: 11,
                        color: AppColors.textSubtle,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: inProgress ? _kPrimarySoft : AppColors.surfaceSoft,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                inProgress ? 'En cours' : 'Planifiée',
                style: AppTextStyles.labelSmall.copyWith(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color:
                      inProgress ? AppColors.primary : AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.icon,
    required this.message,
    required this.hint,
  });

  final IconData icon;
  final String message;
  final String hint;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: const BoxDecoration(
              color: _kPrimarySoft,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Icon(icon, size: 32, color: AppColors.primary),
          ),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: AppTextStyles.titleSmall.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            hint,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodySmall.copyWith(
              fontSize: 12,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _Fabs extends StatelessWidget {
  const _Fabs();

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
      padding: const EdgeInsets.fromLTRB(
        AppDimens.pagePaddingH,
        12,
        AppDimens.pagePaddingH,
        12,
      ),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 44,
              child: OutlinedButton.icon(
                onPressed: () => context.push(
                  RouteNames.cooperativeVehiculeAjouterPath,
                ),
                icon:
                    const Icon(Icons.add, size: 16, color: AppColors.primary),
                label: Text(
                  'Véhicule',
                  style: AppTextStyles.button.copyWith(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(
                    color: AppColors.primary,
                    width: AppDimens.borderThin,
                  ),
                  shape: const RoundedRectangleBorder(
                      borderRadius: _kBrCard),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: SizedBox(
              height: 44,
              child: ElevatedButton.icon(
                onPressed: () => context.push(
                  RouteNames.cooperativeCollecteCreerPath,
                ),
                icon: const Icon(Icons.add, size: 16, color: Colors.white),
                label: Text(
                  'Collecte',
                  style: AppTextStyles.button.copyWith(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: const RoundedRectangleBorder(
                      borderRadius: _kBrCard),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

final _nf = NumberFormat('#,##0', 'fr_FR');
