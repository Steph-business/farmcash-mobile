import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../models/farmer_stats.dart';
import '../../../../routing/route_names.dart';
import '../../../../services/providers.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';
import '../../../widgets/communs/chargement.dart';
import '../../../widgets/communs/entete_page_standard.dart';
import '../../../widgets/communs/vue_erreur.dart';

// ─── Providers ─────────────────────────────────────────────────────────

/// Vue agrégée — pilote l'état (loading/error/refresh) de la page.
final _overviewProvider = FutureProvider.autoDispose<FarmerOverview>(
  (ref) => ref.watch(farmerStatsServiceProvider).getOverview(),
);

/// Actions en attente — secondaire, dégrade en silence si erreur.
final _pendingActionsProvider =
    FutureProvider.autoDispose<FarmerPendingActions>(
      (ref) => ref.watch(farmerStatsServiceProvider).getPendingActions(),
    );

/// Funnel de conversion par annonce — secondaire, dégrade en liste vide.
final _conversionProvider =
    FutureProvider.autoDispose<List<FarmerConversionRow>>(
      (ref) => ref.watch(farmerStatsServiceProvider).getConversionFunnel(),
    );

// Accent ambré local (le thème ne définit pas de warning/amber).
const Color _amber = Color(0xFFB45309);
const Color _amberBg = Color(0xFFFFFBEB);
const Color _amberBorder = Color(0xFFFCD34D);
const Color _star = Color(0xFFF59E0B);

final NumberFormat _nf = NumberFormat('#,##0', 'fr_FR');

/// Formate un montant XOF : "450 000 F CFA".
String _fcfa(double v) => '${_nf.format(v)} F CFA';

// ─── Page ──────────────────────────────────────────────────────────────

/// Tableau de bord analytique du producteur — « Mes statistiques ».
///
/// Agrège revenus 30j, KPI commerce, note moyenne, actions en attente et
/// performance des annonces (funnel de conversion) à partir des endpoints
/// `oversight/farmer/*`. Pull-to-refresh + gestion loading/error.
class MesStatistiquesPage extends ConsumerWidget {
  const MesStatistiquesPage({super.key});

  Future<void> _refresh(WidgetRef ref) async {
    ref.invalidate(_overviewProvider);
    ref.invalidate(_pendingActionsProvider);
    ref.invalidate(_conversionProvider);
    await ref.read(_overviewProvider.future);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(_overviewProvider);

    return Scaffold(
      backgroundColor: AppColors.surfaceSoft,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const EntetePageStandard(titre: 'Mes statistiques'),
            Expanded(
              child: async.when(
                loading: () => const Padding(
                  padding: EdgeInsets.only(top: AppDimens.space32),
                  child: Chargement(size: 22),
                ),
                error: (e, _) => Padding(
                  padding: const EdgeInsets.all(AppDimens.pagePaddingH),
                  child: VueErreur(
                    message: 'Impossible de charger tes statistiques.',
                    onRetry: () => _refresh(ref),
                  ),
                ),
                data: (overview) => RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: () => _refresh(ref),
                  child: _Contenu(overview: overview),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Contenu scrollable ────────────────────────────────────────────────

class _Contenu extends ConsumerWidget {
  const _Contenu({required this.overview});
  final FarmerOverview overview;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = overview.commerce;
    final pendingAsync = ref.watch(_pendingActionsProvider);
    final conversionAsync = ref.watch(_conversionProvider);

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(
        AppDimens.pagePaddingH,
        4,
        AppDimens.pagePaddingH,
        AppDimens.space32,
      ),
      children: [
        // 1 — Revenus 30 jours (hero)
        _HeroRevenus(revenue: overview.revenue),
        AppDimens.vGap24,

        // 2 — Grille KPI 2×2
        _TitreSection(texte: 'Mon commerce'),
        AppDimens.vGap12,
        _GrilleKpi(commerce: c),
        AppDimens.vGap24,

        // 3 — Note moyenne
        _CarteNote(rating: overview.rating),
        AppDimens.vGap24,

        // 4 — Actions en attente
        pendingAsync.maybeWhen(
          data: (p) => p.total > 0
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _CarteActionsEnAttente(actions: p),
                    AppDimens.vGap24,
                  ],
                )
              : const SizedBox.shrink(),
          orElse: () => const SizedBox.shrink(),
        ),

        // 5 — Performance des annonces (funnel)
        _TitreSection(texte: 'Performance des annonces'),
        AppDimens.vGap12,
        conversionAsync.when(
          loading: () => const Padding(
            padding: EdgeInsets.symmetric(vertical: AppDimens.space16),
            child: Chargement(size: 20),
          ),
          error: (_, _) => const _CarteFunnelVide(
            message: 'Statistiques des annonces indisponibles pour le moment.',
          ),
          data: (rows) => rows.isEmpty
              ? const _CarteFunnelVide(
                  message:
                      'Publie une annonce pour voir tes stats de conversion.',
                )
              : Column(
                  children: [
                    for (final r in rows) ...[
                      _CarteFunnel(row: r),
                      const SizedBox(height: 10),
                    ],
                  ],
                ),
        ),

        // 6 — Alertes cultures (si analyses critiques)
        if (overview.cultures.criticalAnalyses30d > 0) ...[
          AppDimens.vGap12,
          _CarteAlerteCultures(count: overview.cultures.criticalAnalyses30d),
        ],
      ],
    );
  }
}

// ─── Section 1 : hero revenus ──────────────────────────────────────────

class _HeroRevenus extends StatelessWidget {
  const _HeroRevenus({required this.revenue});
  final FarmerRevenue revenue;

  @override
  Widget build(BuildContext context) {
    final n = revenue.ordersCompleted30d;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2E7D32), Color(0xFF1B5E20)],
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.25),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.trending_up_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Revenus · 30 derniers jours',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withValues(alpha: 0.92),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            _fcfa(revenue.last30dXof),
            style: AppTextStyles.displayMedium.copyWith(
              fontFamily: 'Poppins',
              fontSize: 30,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            n == 0
                ? 'Aucune commande finalisée sur la période'
                : '$n commande${n > 1 ? "s" : ""} finalisée${n > 1 ? "s" : ""} · 30 derniers jours',
            style: AppTextStyles.bodySmall.copyWith(
              fontSize: 12.5,
              color: Colors.white.withValues(alpha: 0.85),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Section 2 : grille KPI ────────────────────────────────────────────

class _GrilleKpi extends StatelessWidget {
  const _GrilleKpi({required this.commerce});
  final FarmerCommerce commerce;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _CarteKpi(
                icone: Icons.storefront_rounded,
                valeur: '${commerce.activeAnnonces}',
                label: 'Annonces actives',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _CarteKpi(
                icone: Icons.visibility_outlined,
                valeur: _nf.format(commerce.totalViews),
                label: 'Vues totales',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _CarteKpi(
                icone: Icons.local_shipping_outlined,
                valeur: '${commerce.ordersToShip}',
                label: 'À expédier',
                accent: commerce.ordersToShip > 0,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _CarteKpi(
                icone: Icons.handshake_outlined,
                valeur: '${commerce.pendingCandidatures}',
                label: 'Offres en attente',
                accent: commerce.pendingCandidatures > 0,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _CarteKpi extends StatelessWidget {
  const _CarteKpi({
    required this.icone,
    required this.valeur,
    required this.label,
    this.accent = false,
  });

  final IconData icone;
  final String valeur;
  final String label;

  /// Met en avant la carte en ambré quand une valeur appelle une action.
  final bool accent;

  @override
  Widget build(BuildContext context) {
    final fg = accent ? _amber : AppColors.primary;
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      decoration: BoxDecoration(
        color: accent ? _amberBg : AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimens.radiusCard),
        border: Border.all(
          color: accent
              ? _amberBorder.withValues(alpha: 0.7)
              : AppColors.border,
          width: AppDimens.borderThin,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: fg.withValues(alpha: accent ? 0.14 : 0.10),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icone, size: 19, color: fg),
          ),
          const SizedBox(height: 12),
          Text(
            valeur,
            style: AppTextStyles.titleLarge.copyWith(
              fontFamily: 'Poppins',
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppColors.text,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
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

// ─── Section 3 : note moyenne ──────────────────────────────────────────

class _CarteNote extends StatelessWidget {
  const _CarteNote({required this.rating});
  final FarmerRating rating;

  @override
  Widget build(BuildContext context) {
    final avg = rating.average;
    final full = avg.floor();
    final hasHalf = (avg - full) >= 0.5;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimens.radiusCard),
        border: Border.all(
          color: AppColors.border,
          width: AppDimens.borderThin,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: _star.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.star_rounded, color: _star, size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      rating.count == 0 ? '—' : avg.toStringAsFixed(1),
                      style: AppTextStyles.titleLarge.copyWith(
                        fontFamily: 'Poppins',
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppColors.text,
                      ),
                    ),
                    const SizedBox(width: 2),
                    Text(
                      ' / 5',
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                if (rating.count == 0)
                  Text(
                    'Pas encore d\'évaluation',
                    style: AppTextStyles.bodySmall.copyWith(
                      fontSize: 12.5,
                      color: AppColors.textSecondary,
                    ),
                  )
                else
                  Row(
                    children: [
                      for (var i = 0; i < 5; i++)
                        Icon(
                          i < full
                              ? Icons.star_rounded
                              : (i == full && hasHalf
                                    ? Icons.star_half_rounded
                                    : Icons.star_outline_rounded),
                          size: 16,
                          color: _star,
                        ),
                      const SizedBox(width: 8),
                      Text(
                        'basé sur ${rating.count} évaluation${rating.count > 1 ? "s" : ""}',
                        style: AppTextStyles.bodySmall.copyWith(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Section 4 : actions en attente ────────────────────────────────────

class _CarteActionsEnAttente extends StatelessWidget {
  const _CarteActionsEnAttente({required this.actions});
  final FarmerPendingActions actions;

  @override
  Widget build(BuildContext context) {
    final a = actions;
    return Material(
      color: _amberBg,
      borderRadius: BorderRadius.circular(AppDimens.radiusCard),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppDimens.radiusCard),
        // Cible la plus fréquente : les offres reçues à traiter.
        onTap: () => context.push(RouteNames.producteurOffresRecuesPath),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppDimens.radiusCard),
            border: Border.all(
              color: _amberBorder.withValues(alpha: 0.8),
              width: AppDimens.borderThin,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.bolt_rounded, color: _amber, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Tu as ${a.total} action${a.total > 1 ? "s" : ""} en attente',
                      style: AppTextStyles.titleMedium.copyWith(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w800,
                        color: _amber,
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: _amber,
                    size: 22,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              if (a.candidaturesToHandle > 0)
                _LigneAction(
                  texte:
                      '${a.candidaturesToHandle} offre${a.candidaturesToHandle > 1 ? "s" : ""} à traiter',
                ),
              if (a.ordersToShip > 0)
                _LigneAction(
                  texte:
                      '${a.ordersToShip} commande${a.ordersToShip > 1 ? "s" : ""} à livrer',
                ),
              if (a.previsionsToConvertSoon > 0)
                _LigneAction(
                  texte:
                      '${a.previsionsToConvertSoon} prévision${a.previsionsToConvertSoon > 1 ? "s" : ""} à convertir bientôt',
                ),
              if (a.annoncesPendingCoop > 0)
                _LigneAction(
                  texte:
                      '${a.annoncesPendingCoop} annonce${a.annoncesPendingCoop > 1 ? "s" : ""} en attente de ta coop',
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LigneAction extends StatelessWidget {
  const _LigneAction({required this.texte});
  final String texte;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Container(
            width: 5,
            height: 5,
            margin: const EdgeInsets.only(right: 8, left: 2),
            decoration: const BoxDecoration(
              color: _amber,
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Text(
              texte,
              style: AppTextStyles.bodyMedium.copyWith(
                fontSize: 13,
                color: AppColors.text,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Section 5 : funnel de conversion ──────────────────────────────────

class _CarteFunnel extends StatelessWidget {
  const _CarteFunnel({required this.row});
  final FarmerConversionRow row;

  @override
  Widget build(BuildContext context) {
    final r = row;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimens.radiusCard),
        border: Border.all(
          color: AppColors.border,
          width: AppDimens.borderThin,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  r.titre,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.titleMedium.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.text,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '${r.conversionRate.toStringAsFixed(r.conversionRate % 1 == 0 ? 0 : 1)}%',
                  style: AppTextStyles.labelMedium.copyWith(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Barre de progression vues → candidatures → commandes
          _BarreFunnel(
            views: r.views,
            candidatures: r.candidatures,
            orders: r.orders,
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _Etape(
                icone: Icons.visibility_outlined,
                valeur: r.views,
                label: 'vues',
              ),
              const SizedBox(width: 16),
              _Etape(
                icone: Icons.handshake_outlined,
                valeur: r.candidatures,
                label: 'offres',
              ),
              const SizedBox(width: 16),
              _Etape(
                icone: Icons.shopping_bag_outlined,
                valeur: r.orders,
                label: r.orders > 1 ? 'commandes' : 'commande',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Barre segmentée illustrant l'entonnoir : la part candidatures et la part
/// commandes sont calculées relativement aux vues (borne basse visible).
class _BarreFunnel extends StatelessWidget {
  const _BarreFunnel({
    required this.views,
    required this.candidatures,
    required this.orders,
  });

  final int views;
  final int candidatures;
  final int orders;

  @override
  Widget build(BuildContext context) {
    final base = views <= 0 ? 1 : views;
    // Largeurs proportionnelles, avec un minimum visuel si la valeur > 0.
    double frac(int v) {
      if (v <= 0) return 0;
      final f = v / base;
      return f < 0.06 ? 0.06 : f;
    }

    final candFrac = frac(candidatures).clamp(0.0, 1.0);
    final ordFrac = frac(orders).clamp(0.0, 1.0);

    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: SizedBox(
        height: 8,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final w = constraints.maxWidth;
            return Stack(
              children: [
                // Fond = vues (100%)
                Container(color: AppColors.primary.withValues(alpha: 0.10)),
                // Candidatures
                Container(
                  width: w * candFrac,
                  color: AppColors.primary.withValues(alpha: 0.40),
                ),
                // Commandes
                Container(width: w * ordFrac, color: AppColors.primary),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _Etape extends StatelessWidget {
  const _Etape({
    required this.icone,
    required this.valeur,
    required this.label,
  });
  final IconData icone;
  final int valeur;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icone, size: 14, color: AppColors.textSecondary),
        const SizedBox(width: 4),
        Text(
          '$valeur',
          style: AppTextStyles.bodyMedium.copyWith(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AppColors.text,
          ),
        ),
        const SizedBox(width: 3),
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            fontSize: 11.5,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _CarteFunnelVide extends StatelessWidget {
  const _CarteFunnelVide({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimens.radiusCard),
        border: Border.all(
          color: AppColors.border,
          width: AppDimens.borderThin,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.insights_outlined,
              size: 20,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: AppTextStyles.bodyMedium.copyWith(
                fontSize: 13,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Section 6 : alertes cultures ──────────────────────────────────────

class _CarteAlerteCultures extends StatelessWidget {
  const _CarteAlerteCultures({required this.count});
  final int count;

  @override
  Widget build(BuildContext context) {
    final bg = AppColors.error.withValues(alpha: 0.06);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppDimens.radiusCard),
        border: Border.all(
          color: AppColors.error.withValues(alpha: 0.35),
          width: AppDimens.borderThin,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.warning_amber_rounded,
                  size: 22,
                  color: AppColors.error,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$count analyse${count > 1 ? "s" : ""} critique${count > 1 ? "s" : ""} ce mois',
                      style: AppTextStyles.titleMedium.copyWith(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w800,
                        color: AppColors.error,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Tes cultures demandent ton attention.',
                      style: AppTextStyles.bodySmall.copyWith(
                        fontSize: 12.5,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () =>
                  context.push(RouteNames.producteurAiAnalysesHistoriquePath),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.error,
                side: BorderSide(color: AppColors.error.withValues(alpha: 0.4)),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppDimens.radius),
                ),
              ),
              icon: const Icon(Icons.biotech_outlined, size: 18),
              label: const Text(
                'Voir mes analyses',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Titre de section ──────────────────────────────────────────────────

class _TitreSection extends StatelessWidget {
  const _TitreSection({required this.texte});
  final String texte;

  @override
  Widget build(BuildContext context) {
    return Text(
      texte,
      style: AppTextStyles.titleMedium.copyWith(
        fontFamily: 'Poppins',
        fontSize: 15,
        fontWeight: FontWeight.w800,
        color: AppColors.text,
        letterSpacing: -0.2,
      ),
    );
  }
}
