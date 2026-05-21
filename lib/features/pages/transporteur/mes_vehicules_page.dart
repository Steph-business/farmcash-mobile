import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../api_client/api_exception.dart';
import '../../../models/vehicle.dart';
import '../../../routing/route_names.dart';
import '../../../services/providers.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_dimens.dart';
import '../../../theme/app_text_styles.dart';
import '../../widgets/communs/chargement.dart';
import '../../widgets/communs/snackbars.dart';
import '../../widgets/communs/vue_erreur.dart';

const Color _kPrimarySoft = Color(0xFFE8F5E9);

const BorderRadius _kBrCard = BorderRadius.all(Radius.circular(12));

/// Provider liste des véhicules du transporteur connecté.
final _mesVehiculesProvider =
    FutureProvider.autoDispose<List<Vehicle>>((ref) async {
  return ref.watch(logisticsServiceProvider).listMyVehicles();
});

/// Page « Mes véhicules » — liste de la flotte du transporteur avec CTA
/// pour en ajouter un nouveau. Branché sur `/logistics/vehicles/my`.
class MesVehiculesPage extends ConsumerWidget {
  const MesVehiculesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(_mesVehiculesProvider);
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
                    message: 'Impossible de charger tes véhicules. $e',
                    onRetry: () => ref.invalidate(_mesVehiculesProvider),
                  ),
                ),
                data: (items) => RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: () async => ref.invalidate(_mesVehiculesProvider),
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(
                      AppDimens.pagePaddingH,
                      AppDimens.space8,
                      AppDimens.pagePaddingH,
                      AppDimens.space16,
                    ),
                    children: [
                      if (items.isEmpty)
                        const _EmptyState()
                      else ...[
                        for (final v in items) ...[
                          _VehiculeCard(
                            v: v,
                            onDelete: () => _confirmerSuppression(
                              context,
                              ref,
                              v,
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],
                      ],
                      const SizedBox(height: 4),
                      _AjouterBouton(
                        onTap: () => context.push(
                          RouteNames.transporteurVehiculeCreerPath,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmerSuppression(
    BuildContext context,
    WidgetRef ref,
    Vehicle v,
  ) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Supprimer ce véhicule ?'),
        content: Text(
          'Le véhicule "${v.marque ?? v.type}" sera retiré de ta flotte.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text(
              'Supprimer',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
    if (ok != true) return;
    if (!context.mounted) return;
    try {
      await ref.read(logisticsServiceProvider).deleteVehicle(v.id);
      if (!context.mounted) return;
      Snackbars.showSucces(context, 'Véhicule supprimé');
      ref.invalidate(_mesVehiculesProvider);
    } on ApiException catch (e) {
      if (context.mounted) Snackbars.showErreur(context, e.message);
    }
  }
}

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
                : context.go(RouteNames.transporteurProfilSettingsPath),
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
              'Mes véhicules',
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

class _VehiculeCard extends StatelessWidget {
  const _VehiculeCard({required this.v, required this.onDelete});

  final Vehicle v;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final nf = NumberFormat('#,##0', 'fr_FR');
    final titre = v.marque?.trim().isNotEmpty == true
        ? v.marque!.trim()
        : (v.type.isNotEmpty ? v.type : 'Véhicule');
    final typeImmat = [
      if (v.type.isNotEmpty) v.type,
      if (v.immatriculation?.trim().isNotEmpty == true)
        v.immatriculation!.trim(),
    ].join(' · ');
    final capacite = v.chargeMaxKg > 0
        ? '${nf.format(v.chargeMaxKg.round())} kg utiles'
        : 'Capacité non renseignée';
    final photo = v.photoUrl;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: _kBrCard,
        border:
            Border.all(color: AppColors.border, width: AppDimens.borderThin),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: _kPrimarySoft,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: AppColors.border,
                width: AppDimens.borderThin,
              ),
            ),
            clipBehavior: Clip.antiAlias,
            child: photo != null && photo.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: photo,
                    fit: BoxFit.cover,
                    placeholder: (_, _) =>
                        const ColoredBox(color: _kPrimarySoft),
                    errorWidget: (_, _, _) => const Icon(
                      Icons.local_shipping_outlined,
                      size: 22,
                      color: AppColors.primary,
                    ),
                  )
                : const Icon(
                    Icons.local_shipping_outlined,
                    size: 24,
                    color: AppColors.primary,
                  ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        titre,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.text,
                        ),
                      ),
                    ),
                    _StatutChip(actif: v.isActive),
                  ],
                ),
                if (typeImmat.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    typeImmat,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodySmall.copyWith(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
                const SizedBox(height: 2),
                Text(
                  capacite,
                  style: AppTextStyles.bodySmall.copyWith(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Supprimer',
            onPressed: onDelete,
            icon: const Icon(
              Icons.delete_outline,
              size: 20,
              color: AppColors.textSubtle,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatutChip extends StatelessWidget {
  const _StatutChip({required this.actif});

  final bool actif;

  @override
  Widget build(BuildContext context) {
    final bg = actif ? _kPrimarySoft : AppColors.surfaceSoft;
    final fg = actif ? AppColors.primary : AppColors.textSecondary;
    final label = actif ? 'Actif' : 'Inactif';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label.toUpperCase(),
        style: AppTextStyles.labelSmall.copyWith(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: fg,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

class _AjouterBouton extends StatelessWidget {
  const _AjouterBouton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: _kBrCard,
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: _kBrCard,
          border: Border.all(
            color: AppColors.primary,
            width: AppDimens.borderThin,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                color: _kPrimarySoft,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.add,
                size: 20,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Ajouter un véhicule',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ),
            const Icon(
              Icons.chevron_right,
              size: 18,
              color: AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, AppDimens.space24, 0, AppDimens.space16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.local_shipping_outlined,
            size: 40,
            color: AppColors.textSubtle.withValues(alpha: 0.9),
          ),
          const SizedBox(height: AppDimens.space12),
          Text(
            'Aucun véhicule enregistré',
            style: AppTextStyles.titleSmall,
          ),
          const SizedBox(height: 4),
          Text(
            'Ajoute ton premier véhicule pour recevoir des missions.',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
