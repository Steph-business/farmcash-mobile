import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../api_client/api_exception.dart';
import '../../../models/livraison.dart';
import '../../../routing/route_names.dart';
import '../../../services/providers.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_dimens.dart';
import '../../../theme/app_text_styles.dart';
import '../../widgets/communs/chargement.dart';
import '../../widgets/communs/snackbars.dart';
import '../../widgets/communs/vue_erreur.dart';

const Color _kPrimarySoft = Color(0xFFE8F5E9);

final _itinerairesProvider =
    FutureProvider.autoDispose<List<TransporterRoute>>((ref) async {
  return ref.read(logisticsServiceProvider).listMyRoutes();
});

/// Liste des routes (origin → destination) que le transporteur dessert.
/// Le bouton "Ajouter" pousse vers `vehicule_ajouter_page` qui sert aussi
/// de formulaire de route (V1 simplifié).
class ItinerairesTransporteurPage extends ConsumerStatefulWidget {
  const ItinerairesTransporteurPage({super.key});

  @override
  ConsumerState<ItinerairesTransporteurPage> createState() =>
      _ItinerairesTransporteurPageState();
}

class _ItinerairesTransporteurPageState
    extends ConsumerState<ItinerairesTransporteurPage> {
  String? _busyId;

  Future<void> _refresh() async {
    ref.invalidate(_itinerairesProvider);
    await ref.read(_itinerairesProvider.future);
  }

  Future<void> _toggleActif(TransporterRoute r) async {
    if (_busyId != null) return;
    setState(() => _busyId = r.id);
    try {
      await ref
          .read(logisticsServiceProvider)
          .updateRoute(r.id, isActive: !r.isActive);
      await _refresh();
    } on ApiException catch (e) {
      if (mounted) Snackbars.showErreur(context, e.message);
    } finally {
      if (mounted) setState(() => _busyId = null);
    }
  }

  Future<void> _supprimer(TransporterRoute r) async {
    if (_busyId != null) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Désactiver l\'itinéraire ?'),
        content: Text(
          '${r.origineZone} → ${r.destinationZone} sera désactivé. '
          'Tu pourras le réactiver plus tard.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Désactiver'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    if (!mounted) return;
    setState(() => _busyId = r.id);
    try {
      await ref.read(logisticsServiceProvider).deleteRoute(r.id);
      await _refresh();
      if (mounted) Snackbars.showInfo(context, 'Itinéraire désactivé');
    } on ApiException catch (e) {
      if (mounted) Snackbars.showErreur(context, e.message);
    } finally {
      if (mounted) setState(() => _busyId = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(_itinerairesProvider);
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _Header(
              onBack: () => context.canPop()
                  ? context.pop()
                  : context.go(RouteNames.transporteurMissionsPath),
              onAdd: () async {
                await context
                    .push(RouteNames.transporteurVehiculeAjouterPath);
                _refresh();
              },
            ),
            Expanded(
              child: async.when(
                loading: () => const Padding(
                  padding: EdgeInsets.only(top: 48),
                  child: Chargement(size: 22),
                ),
                error: (e, _) => Padding(
                  padding: const EdgeInsets.all(AppDimens.pagePaddingH),
                  child: VueErreur(
                    message: 'Impossible de charger les itinéraires. $e',
                    onRetry: _refresh,
                  ),
                ),
                data: (routes) => RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: _refresh,
                  child: routes.isEmpty
                      ? const _EmptyState()
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(
                            AppDimens.pagePaddingH,
                            8,
                            AppDimens.pagePaddingH,
                            24,
                          ),
                          itemCount: routes.length,
                          itemBuilder: (_, i) {
                            final r = routes[i];
                            return _RouteCard(
                              route: r,
                              busy: _busyId == r.id,
                              onToggle: () => _toggleActif(r),
                              onDelete: () => _supprimer(r),
                            );
                          },
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

// ─── Header ─────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  const _Header({required this.onBack, required this.onAdd});
  final VoidCallback onBack;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 8, 16, 12),
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(
          bottom: BorderSide(
            color: AppColors.border,
            width: AppDimens.borderThin,
          ),
        ),
      ),
      child: Row(
        children: [
          InkWell(
            onTap: onBack,
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
              'Mes itinéraires',
              style: AppTextStyles.titleSmall.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          InkWell(
            onTap: onAdd,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: Text(
                'Ajouter',
                style: AppTextStyles.labelMedium.copyWith(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Card route ──────────────────────────────────────────────────────

class _RouteCard extends StatelessWidget {
  const _RouteCard({
    required this.route,
    required this.busy,
    required this.onToggle,
    required this.onDelete,
  });
  final TransporterRoute route;
  final bool busy;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final capacite = '${_nf.format(route.capaciteMaxKg.round())} kg max';
    final tarif = '${_nf.format(route.tarifKg.round())} F/kg';
    final minimum = route.tarifMinimum > 0
        ? 'min ${_nf.format(route.tarifMinimum.round())} F'
        : null;
    final delai = route.delaiTypique;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.border,
            width: AppDimens.borderThin,
          ),
        ),
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: _kPrimarySoft,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.alt_route,
                    size: 18,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '${route.origineZone} → ${route.destinationZone}',
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (busy)
                  const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.primary,
                    ),
                  )
                else
                  Switch(
                    value: route.isActive,
                    activeThumbColor: AppColors.primary,
                    onChanged: (_) => onToggle(),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                _MetaChip(label: capacite),
                _MetaChip(label: tarif),
                if (minimum != null) _MetaChip(label: minimum),
                if (delai != null) _MetaChip(label: delai),
              ],
            ),
            const SizedBox(height: 6),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: busy ? null : onDelete,
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.error,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  'Supprimer',
                  style: AppTextStyles.labelMedium.copyWith(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.error,
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

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.label});
  final String label;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.surfaceSoft,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: AppTextStyles.labelSmall.copyWith(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}

// ─── Empty state ────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState();
  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        const SizedBox(height: 80),
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.alt_route_outlined,
                size: 40,
                color: AppColors.textSubtle.withValues(alpha: 0.9),
              ),
              const SizedBox(height: 12),
              Text(
                'Aucun itinéraire déclaré',
                style: AppTextStyles.titleSmall,
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  'Déclare au moins une route (origine → destination) pour recevoir des missions.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

final _nf = NumberFormat('#,##0', 'fr_FR');
