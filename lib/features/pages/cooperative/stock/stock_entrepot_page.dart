import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../models/enums.dart';
import '../../../../models/lot.dart';
import '../../../../routing/route_names.dart';
import '../../../../services/providers.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';
import '../../../widgets/communs/chargement.dart';
import '../../../widgets/communs/vue_erreur.dart';

// ─── Couleurs / radius locaux alignés sur la maquette ──────────────────
const Color _kPrimarySoft = Color(0xFFE8F5E9);
const BorderRadius _kBrCard14 = BorderRadius.all(Radius.circular(14));
const BorderRadius _kBrCard12 = BorderRadius.all(Radius.circular(12));
const BorderRadius _kBrThumb = BorderRadius.all(Radius.circular(8));

/// Bundle entrepôt + lots stockés physiquement dans cet entrepôt.
class _EntrepotBundle {
  const _EntrepotBundle({required this.entrepot, required this.lots});
  final Entrepot? entrepot;
  final List<Lot> lots;
}

final _entrepotBundleProvider = FutureProvider.autoDispose
    .family<_EntrepotBundle, String>((ref, entrepotId) async {
  final svc = ref.read(marketplaceServiceProvider);
  // Charge la liste des entrepôts pour récupérer le détail (nom + capacité)
  // et la liste des lots présents dans CET entrepôt (via table `stock`).
  final results = await Future.wait<dynamic>([
    svc.listEntrepots(),
    svc.listLotsByEntrepot(entrepotId),
  ]);
  final entrepots = results[0] as List<Entrepot>;
  final lots = results[1] as List<Lot>;
  Entrepot? entrepot;
  for (final e in entrepots) {
    if (e.id == entrepotId) {
      entrepot = e;
      break;
    }
  }
  return _EntrepotBundle(entrepot: entrepot, lots: lots);
});

/// Détail d'un entrepôt coopérative — capacité + lots stockés.
class StockEntrepotPage extends ConsumerWidget {
  const StockEntrepotPage({super.key, required this.entrepotId});

  final String entrepotId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(_entrepotBundleProvider(entrepotId));
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _Header(
              titre: async.maybeWhen(
                data: (b) => b.entrepot?.nom ?? 'Entrepôt',
                orElse: () => 'Entrepôt',
              ),
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
                    message: 'Impossible de charger cet entrepôt. $e',
                    onRetry: () =>
                        ref.invalidate(_entrepotBundleProvider(entrepotId)),
                  ),
                ),
                data: (bundle) {
                  final entrepot = bundle.entrepot;
                  if (entrepot == null) {
                    return Padding(
                      padding:
                          const EdgeInsets.all(AppDimens.pagePaddingH),
                      child: Text(
                        'Entrepôt introuvable.',
                        style: AppTextStyles.bodyMedium,
                      ),
                    );
                  }
                  return _Body(entrepot: entrepot, lots: bundle.lots);
                },
              ),
            ),
            _StickyButton(
              onTap: () =>
                  context.push(RouteNames.cooperativeStockReceptionPath),
            ),
          ],
        ),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.entrepot, required this.lots});

  final Entrepot entrepot;
  final List<Lot> lots;

  @override
  Widget build(BuildContext context) {
    final utilise =
        lots.fold<double>(0, (acc, l) => acc + l.quantiteKg);
    final capacite = entrepot.capaciteKg;
    final dispoPct = capacite > 0
        ? ((capacite - utilise).clamp(0, capacite) / capacite * 100).round()
        : 0;
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppDimens.pagePaddingH,
        0,
        AppDimens.pagePaddingH,
        AppDimens.space16,
      ),
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 12, bottom: 8),
          child: _KpiRow(
            capacite: capacite,
            utilise: utilise,
            dispoPct: dispoPct,
          ),
        ),
        AppDimens.vGap12,
        Text(
          'Lots dans cet entrepôt',
          style: AppTextStyles.titleSmall.copyWith(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
        AppDimens.vGap12,
        if (lots.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Text(
              'Cet entrepôt est vide.',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          )
        else
          _LotsList(lots: lots),
      ],
    );
  }
}

// ─── Header (back + titre) ──────────────────────────────────────────────

class _Header extends StatelessWidget {
  const _Header({required this.titre});

  final String titre;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppDimens.pagePaddingH,
        AppDimens.space8,
        AppDimens.pagePaddingH,
        AppDimens.space12,
      ),
      child: Row(
        children: [
          InkWell(
            onTap: () => context.canPop()
                ? context.pop()
                : context.go(RouteNames.cooperativeStockPath),
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
              titre,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
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

// ─── KPI row ────────────────────────────────────────────────────────────

class _KpiRow extends StatelessWidget {
  const _KpiRow({
    required this.capacite,
    required this.utilise,
    required this.dispoPct,
  });

  final double capacite;
  final double utilise;
  final int dispoPct;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _KpiCard(value: _formatT(capacite), label: 'Capacité')),
        const SizedBox(width: 8),
        Expanded(child: _KpiCard(value: _formatT(utilise), label: 'Utilisée')),
        const SizedBox(width: 8),
        Expanded(child: _KpiCard(value: '$dispoPct%', label: 'Dispo')),
      ],
    );
  }
}

String _formatT(double kg) {
  if (kg < 1000) return '${kg.round()} kg';
  final t = kg / 1000;
  if (t >= 10) return '${t.toStringAsFixed(0)} t';
  return '${t.toStringAsFixed(1)} t';
}

class _KpiCard extends StatelessWidget {
  const _KpiCard({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: _kBrCard12,
        border: Border.all(
          color: AppColors.border,
          width: AppDimens.borderThin,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: AppTextStyles.titleSmall.copyWith(
              fontFamily: 'Poppins',
              fontSize: 15,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.2,
              height: 1.1,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(
              fontSize: 10,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Liste des lots ─────────────────────────────────────────────────────

class _LotsList extends StatelessWidget {
  const _LotsList({required this.lots});

  final List<Lot> lots;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: _kBrCard14,
        border: Border.all(
          color: AppColors.border,
          width: AppDimens.borderThin,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (int i = 0; i < lots.length; i++) ...[
            _LotTile(lot: lots[i]),
            if (i != lots.length - 1)
              const Divider(
                height: 1,
                thickness: AppDimens.borderThin,
                color: AppColors.border,
              ),
          ],
        ],
      ),
    );
  }
}

class _LotTile extends StatelessWidget {
  const _LotTile({required this.lot});

  final Lot lot;

  @override
  Widget build(BuildContext context) {
    final qteLabel = '${_fmtKg(lot.quantiteKg)} kg';
    final dateLabel = lot.createdAt != null
        ? DateFormat('dd/MM').format(lot.createdAt!.toLocal())
        : '—';
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: _kBrThumb,
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: _kPrimarySoft,
                border: Border.all(
                  color: AppColors.border,
                  width: AppDimens.borderThin,
                ),
                borderRadius: _kBrThumb,
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.inventory_2_outlined,
                color: AppColors.primary,
                size: 22,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${lot.lotCode} · $qteLabel',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.titleSmall.copyWith(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$dateLabel · ${_qualiteLabel(lot.qualite)}',
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
            _qualiteShort(lot.qualite),
            style: AppTextStyles.labelMedium.copyWith(
              fontFamily: 'Poppins',
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.text,
            ),
          ),
        ],
      ),
    );
  }
}

String _qualiteLabel(ProductQuality q) {
  switch (q) {
    case ProductQuality.standard:
      return 'Standard';
    case ProductQuality.premium:
      return 'Premium';
    case ProductQuality.bio:
      return 'Bio';
    case ProductQuality.equitable:
      return 'Équitable';
    case ProductQuality.unknown:
      return '—';
  }
}

String _qualiteShort(ProductQuality q) {
  switch (q) {
    case ProductQuality.premium:
      return 'A';
    case ProductQuality.standard:
      return 'B';
    case ProductQuality.bio:
      return 'BIO';
    case ProductQuality.equitable:
      return 'EQ';
    case ProductQuality.unknown:
      return '—';
  }
}

String _fmtKg(double kg) {
  final i = kg.round();
  if (i < 1000) return '$i';
  final s = '$i';
  final buf = StringBuffer();
  for (var k = 0; k < s.length; k++) {
    if (k > 0 && (s.length - k) % 3 == 0) buf.write(' ');
    buf.write(s[k]);
  }
  return buf.toString();
}

// ─── Sticky bouton ──────────────────────────────────────────────────────

class _StickyButton extends StatelessWidget {
  const _StickyButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.pagePaddingH,
        vertical: 12,
      ),
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(
          top: BorderSide(
            color: AppColors.border,
            width: AppDimens.borderThin,
          ),
        ),
      ),
      child: SizedBox(
        width: double.infinity,
        height: 48,
        child: ElevatedButton.icon(
          onPressed: onTap,
          icon: const Icon(Icons.add, size: 18, color: AppColors.onPrimary),
          label: Text(
            'Réceptionner un nouveau lot',
            style: AppTextStyles.labelLarge.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.onPrimary,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.onPrimary,
            elevation: 0,
            shape: const RoundedRectangleBorder(
              borderRadius: _kBrCard12,
            ),
          ),
        ),
      ),
    );
  }
}
