// =====================================================================
//  Badge premium « Prix marché »
//  ---------------------------------------------------------------------
//  Affiche la médiane + fourchette min/max d'un produit calculées à
//  partir des commandes réelles backend (`GET /ai/price-estimate`).
//
//  Deux usages :
//    1. Producteur — sous le champ "prix par kg" du formulaire de
//       publication. Si le producteur saisit un prix, on ajoute un
//       verdict (sous-marché / dans le marché / au-dessus).
//    2. Acheteur — sur la fiche détail annonce / publication coop, le
//       `prixActuelKg` est passé directement → verdict d'écart pour
//       l'aider à juger l'offre.
//
//  Comportement défensif :
//    - Loading → petit shimmer compact, pas de spinner décalé.
//    - data null OU `isComplete == false` → SizedBox.shrink() (le
//      backend n'a pas assez de signal, on ne pollue pas l'UI).
//    - source == catalog → chip discret « Prix de référence » (le
//      prix vient du catalogue produit, pas d'historique réel).
// =====================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../models/price_estimate.dart';
import '../../../services/providers.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';

class BadgePrixMarche extends ConsumerWidget {
  const BadgePrixMarche({
    super.key,
    required this.produitId,
    this.regionId,
    this.qualite,
    this.prixActuelKg,
    this.margin = const EdgeInsets.symmetric(vertical: 8),
  });

  /// Produit dont on veut l'estimation. Obligatoire — sans ça l'endpoint
  /// ne peut rien calculer.
  final String produitId;

  /// Région optionnelle pour resserrer la médiane sur le marché local.
  final String? regionId;

  /// Qualité optionnelle (`STANDARD | PREMIUM | BIO | EQUITABLE`) —
  /// alignée sur l'enum backend.
  final String? qualite;

  /// Prix actuellement saisi/affiché (F CFA/kg). Si fourni, on ajoute le
  /// sous-encart "Ton prix" avec verdict couleur.
  final double? prixActuelKg;

  /// Margin extérieur. Default `vertical: 8` — visuellement détaché du
  /// champ adjacent.
  final EdgeInsetsGeometry margin;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final query = PriceEstimateQuery(
      produitId: produitId,
      regionId: regionId,
      qualite: qualite,
    );
    final async = ref.watch(priceEstimateProvider(query));

    return async.when(
      loading: () => Padding(
        padding: margin,
        child: const _ShimmerCompact(),
      ),
      error: (_, __) => const SizedBox.shrink(),
      data: (estimate) {
        if (estimate == null || !estimate.isComplete) {
          return const SizedBox.shrink();
        }
        return Padding(
          padding: margin,
          child: _CarteEstimation(
            estimate: estimate,
            prixActuelKg: prixActuelKg,
          ),
        );
      },
    );
  }
}

// ─── Shimmer compact pendant le loading ─────────────────────────────

class _ShimmerCompact extends StatelessWidget {
  const _ShimmerCompact();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: AppColors.surfaceSoft,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 90,
                  height: 9,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  width: 140,
                  height: 11,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(4),
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

// ─── Carte estimation principale ────────────────────────────────────

class _CarteEstimation extends StatelessWidget {
  const _CarteEstimation({
    required this.estimate,
    required this.prixActuelKg,
  });

  final PriceEstimate estimate;
  final double? prixActuelKg;

  static const _orange = Color(0xFFEA8C24);
  static const _orangeSoft = Color(0xFFFFF1E1);

  @override
  Widget build(BuildContext context) {
    final nf = NumberFormat('#,##0', 'fr_FR');
    final median = (estimate.medianKg ?? 0).round();
    final min = estimate.minKg?.round();
    final max = estimate.maxKg?.round();
    final isCatalog = estimate.source == PriceSource.catalog;

    final fourchette = (min != null && max != null)
        ? '${nf.format(min)}-${nf.format(max)} F'
        : null;
    final meta = <String>[
      if (fourchette != null) fourchette,
      if (estimate.sampleSize > 0) '${estimate.sampleSize} ventes',
      '${estimate.periodDays} jours',
    ].join(' · ');

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.compare_arrows_rounded,
                  size: 18,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Text(
                          'PRIX MARCHÉ',
                          style: AppTextStyles.labelSmall.copyWith(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.0,
                            color: AppColors.primary,
                          ),
                        ),
                        if (isCatalog) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 1,
                            ),
                            decoration: BoxDecoration(
                              color: _orangeSoft,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Text(
                              'Prix de référence',
                              style: TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w700,
                                color: _orange,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${nf.format(median)} F/kg',
                          style: AppTextStyles.titleSmall.copyWith(
                            fontFamily: 'Poppins',
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: AppColors.text,
                            letterSpacing: -0.2,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 2),
                          child: Text(
                            '(médiane)',
                            style: AppTextStyles.bodySmall.copyWith(
                              fontSize: 11,
                              color: AppColors.textSubtle,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      meta,
                      style: AppTextStyles.bodySmall.copyWith(
                        fontSize: 11.5,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (prixActuelKg != null && prixActuelKg! > 0) ...[
            const SizedBox(height: 10),
            _SousEncartVerdict(
              prixKg: prixActuelKg!,
              estimate: estimate,
            ),
          ],
        ],
      ),
    );
  }
}

// ─── Sous-encart verdict (ton prix vs marché) ───────────────────────

class _SousEncartVerdict extends StatelessWidget {
  const _SousEncartVerdict({
    required this.prixKg,
    required this.estimate,
  });

  final double prixKg;
  final PriceEstimate estimate;

  static const _orange = Color(0xFFEA8C24);
  static const _orangeSoft = Color(0xFFFFF1E1);
  static const _greenSoft = Color(0xFFE8F5E9);
  static const _redSoft = Color(0xFFFEE2E2);
  static const _red = Color(0xFFC62828);

  @override
  Widget build(BuildContext context) {
    final verdict = estimate.verdictFor(prixKg);
    final diff = estimate.percentDiffFromMedian(prixKg);
    final pct = diff.abs().round();

    final (bg, fg, icon, label) = switch (verdict) {
      PriceVerdict.underMarket => (
        _redSoft,
        _red,
        Icons.trending_down_rounded,
        '−$pct% sous le marché — risque de mauvaise vente',
      ),
      PriceVerdict.fairMarket => (
        _greenSoft,
        AppColors.success,
        Icons.check_circle_outline_rounded,
        diff.abs() < 1
            ? 'Dans le marché'
            : 'Dans le marché (${diff >= 0 ? '+' : '−'}$pct%)',
      ),
      PriceVerdict.aboveMarket => (
        _orangeSoft,
        _orange,
        Icons.trending_up_rounded,
        '+$pct% au-dessus — possible négociation',
      ),
      PriceVerdict.noSignal => (
        AppColors.surfaceSoft,
        AppColors.textSecondary,
        Icons.help_outline_rounded,
        'Pas assez de données pour situer ton prix',
      ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: fg),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(
                fontSize: 12,
                color: fg,
                fontWeight: FontWeight.w600,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
