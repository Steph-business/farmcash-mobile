import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../models/lot.dart';
import '../../../routing/route_names.dart';
import '../../../services/providers.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_dimens.dart';
import '../../../theme/app_text_styles.dart';
import '../../widgets/communs/chargement.dart';
import '../../widgets/communs/header_utilisateur.dart';
import '../../widgets/communs/vue_erreur.dart';

// ─── Couleurs locales (alignées sur la maquette) ────────────────────────

const Color _kPrimarySoft = Color(0xFFE8F5E9);

/// Bundle entrepôts + lots récents pour cette page d'accueil stock.
class _StockBundle {
  const _StockBundle({required this.entrepots, required this.lots});
  final List<Entrepot> entrepots;
  final List<Lot> lots;
}

final _stockBundleProvider =
    FutureProvider.autoDispose<_StockBundle>((ref) async {
  final svc = ref.read(marketplaceServiceProvider);
  final results = await Future.wait<dynamic>([
    svc.listEntrepots(),
    svc.listLots(),
  ]);
  return _StockBundle(
    entrepots: results[0] as List<Entrepot>,
    lots: results[1] as List<Lot>,
  );
});

/// Onglet Stock de la coopérative — branché sur `listEntrepots`/`listLots`.
class StockCooperativePage extends ConsumerWidget {
  const StockCooperativePage({super.key});

  void _ouvrirEntrepot(BuildContext context, Entrepot e) {
    context.push(RouteNames.cooperativeStockEntrepotPathFor(e.id));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(_stockBundleProvider);
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const HeaderUtilisateur(variant: HeaderVariant.cooperative),
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
                    message: 'Impossible de charger le stock. $e',
                    onRetry: () => ref.invalidate(_stockBundleProvider),
                  ),
                ),
                data: (bundle) {
                  final entrepots = bundle.entrepots;
                  final lots = bundle.lots;
                  final stockTotalKg = lots.fold<double>(
                    0,
                    (acc, l) => acc + l.quantiteKg,
                  );
                  final lotsRecents = [...lots]..sort((a, b) {
                      final aDate = a.createdAt ??
                          DateTime.fromMillisecondsSinceEpoch(0);
                      final bDate = b.createdAt ??
                          DateTime.fromMillisecondsSinceEpoch(0);
                      return bDate.compareTo(aDate);
                    });
                  return Column(
                    children: [
                      _Summary(
                        stockLabel: _formatStock(stockTotalKg),
                        nbEntrepots: entrepots.length,
                      ),
                      Expanded(
                        child: RefreshIndicator(
                          color: AppColors.primary,
                          onRefresh: () async {
                            ref.invalidate(_stockBundleProvider);
                            await ref.read(_stockBundleProvider.future);
                          },
                          child: ListView(
                            padding: const EdgeInsets.fromLTRB(
                              AppDimens.pagePaddingH,
                              AppDimens.space8,
                              AppDimens.pagePaddingH,
                              AppDimens.space24,
                            ),
                            children: [
                              const _SectionTitre(label: 'Entrepôts'),
                              AppDimens.vGap12,
                              if (entrepots.isEmpty)
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                  child: Text(
                                    'Aucun entrepôt enregistré.',
                                    style: AppTextStyles.bodySmall.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                )
                              else
                                for (final e in entrepots) ...[
                                  _EntrepotCard(
                                    entrepot: e,
                                    onTap: () => _ouvrirEntrepot(context, e),
                                  ),
                                  AppDimens.vGap12,
                                ],
                              AppDimens.vGap12,
                              const _SectionTitre(label: 'Lots récents'),
                              AppDimens.vGap12,
                              if (lotsRecents.isEmpty)
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                  child: Text(
                                    'Aucun lot pour le moment.',
                                    style: AppTextStyles.bodySmall.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                )
                              else
                                _LotsCard(lots: lotsRecents.take(8).toList()),
                            ],
                          ),
                        ),
                      ),
                    ],
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

String _formatStock(double kg) {
  if (kg < 1000) return '${kg.round()} kg stockés';
  final tonnes = kg / 1000;
  if (tonnes >= 10) return '${tonnes.toStringAsFixed(0)} t stockées';
  return '${tonnes.toStringAsFixed(1)} t stockées';
}

// ─── Titre de page ──────────────────────────────────────────────────────

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
        'Stock',
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

// ─── Récap ──────────────────────────────────────────────────────────────

class _Summary extends StatelessWidget {
  const _Summary({required this.stockLabel, required this.nbEntrepots});

  final String stockLabel;
  final int nbEntrepots;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppDimens.pagePaddingH,
        0,
        AppDimens.pagePaddingH,
        AppDimens.space12,
      ),
      child: RichText(
        text: TextSpan(
          style: AppTextStyles.bodySmall.copyWith(
            fontSize: 13,
            color: AppColors.textSecondary,
          ),
          children: [
            TextSpan(
              text: stockLabel,
              style: AppTextStyles.bodySmall.copyWith(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.text,
              ),
            ),
            TextSpan(text: ' · $nbEntrepots entrepôt${nbEntrepots > 1 ? 's' : ''}'),
          ],
        ),
      ),
    );
  }
}

// ─── Section titre ──────────────────────────────────────────────────────

class _SectionTitre extends StatelessWidget {
  const _SectionTitre({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: AppTextStyles.titleSmall.copyWith(
        fontSize: 15,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

// ─── Entrepôt card ──────────────────────────────────────────────────────

class _EntrepotCard extends StatelessWidget {
  const _EntrepotCard({required this.entrepot, required this.onTap});

  final Entrepot entrepot;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    // Pas d'info "usage actuel" sans relation Lot→Entrepôt — on n'affiche
    // que la capacité totale en t/kg.
    final capacite = entrepot.capaciteKg;
    final capaciteLabel = capacite >= 1000
        ? '${(capacite / 1000).toStringAsFixed(1)} t'
        : '${capacite.round()} kg';
    final ville = entrepot.location ?? '';
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(AppDimens.space16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: AppColors.border,
              width: AppDimens.borderThin,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
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
                  Icons.warehouse_outlined,
                  size: 22,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      entrepot.nom,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.text,
                      ),
                    ),
                    if (ville.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        ville,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.bodySmall.copyWith(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                    const SizedBox(height: 6),
                    Text(
                      'Capacité $capaciteLabel${entrepot.isRefrigere ? ' · Réfrigéré' : ''}',
                      style: AppTextStyles.labelSmall.copyWith(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.chevron_right,
                size: 18,
                color: AppColors.textSubtle,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Lots récents ───────────────────────────────────────────────────────

class _LotsCard extends StatelessWidget {
  const _LotsCard({required this.lots});

  final List<Lot> lots;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.border,
          width: AppDimens.borderThin,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (var i = 0; i < lots.length; i++) ...[
            _LotRow(lot: lots[i]),
            if (i < lots.length - 1)
              const Divider(
                height: 1,
                thickness: 1,
                color: AppColors.border,
              ),
          ],
        ],
      ),
    );
  }
}

class _LotRow extends StatelessWidget {
  const _LotRow({required this.lot});

  final Lot lot;

  @override
  Widget build(BuildContext context) {
    final qteLabel = '${_fmtKg(lot.quantiteKg)} kg';
    final dateLabel = lot.createdAt != null
        ? 'Entré le ${DateFormat('dd/MM').format(lot.createdAt!.toLocal())}'
        : 'Date inconnue';
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.space16,
        vertical: 14,
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: _kPrimarySoft,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: AppColors.border,
                width: AppDimens.borderThin,
              ),
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.inventory_2_outlined,
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
                  '${lot.lotCode} · $qteLabel',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.text,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  dateLabel,
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
        ],
      ),
    );
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

