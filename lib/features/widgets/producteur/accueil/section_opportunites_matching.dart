import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../models/matching.dart';
import '../../../../routing/route_names.dart';
import '../../../../services/providers.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';

/// Provider auto-disposé — opportunités de matching pour le producteur
/// connecté. Tolérant aux erreurs : renvoie liste vide en cas d'échec
/// (la section se masque silencieusement plutôt que d'afficher une erreur
/// bruyante sur l'accueil).
final opportunitesMatchingProducteurProvider =
    FutureProvider.autoDispose<List<MatchingOpportunity>>((ref) async {
  try {
    return await ref.read(matchingServiceProvider).listMyOpportunities();
  } catch (_) {
    return const <MatchingOpportunity>[];
  }
});

final NumberFormat _nfFr = NumberFormat('#,##0', 'fr_FR');

/// Section premium « Opportunités pour toi » sur l'accueil producteur.
///
/// Liste horizontale scrollable de cartes représentant des demandes
/// d'achat qui matchent les cultures déclarées du producteur. Si la
/// liste est vide → silencieux (SizedBox.shrink), pas d'état vide
/// intrusif sur un accueil déjà dense.
///
/// Pattern : carte gradient premium, header avec badge de comptage,
/// CTA discret « Voir toutes » qui pousse vers la page liste.
class SectionOpportunitesMatching extends ConsumerWidget {
  const SectionOpportunitesMatching({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(opportunitesMatchingProducteurProvider);

    return async.when(
      // Loading discret : placeholder compact pour ne pas décaler
      // l'accueil. La section disparaîtra simplement si pas de données.
      loading: () => const _LoadingPlaceholder(),
      // Erreur silencieuse : on masque la section, le matching est
      // une opportunité, pas une info critique.
      error: (_, _) => const SizedBox.shrink(),
      data: (opportunities) {
        if (opportunities.isEmpty) return const SizedBox.shrink();

        // Limite à 5 cartes scrollables horizontalement — au-delà,
        // l'utilisateur ouvre la page liste complète.
        final visibles = opportunities.take(5).toList(growable: false);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _Header(count: opportunities.length),
            const SizedBox(height: 12),
            _CartesHorizontales(opportunities: visibles),
            if (opportunities.length > visibles.length) ...[
              const SizedBox(height: 10),
              _CtaVoirToutes(
                onTap: () => context.push(
                  RouteNames.producteurOpportunitesPath,
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}

/// Placeholder loading compact (hauteur ~ 150 px = hauteur d'une carte).
class _LoadingPlaceholder extends StatelessWidget {
  const _LoadingPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 156,
      decoration: BoxDecoration(
        color: AppColors.surfaceSoft,
        borderRadius: BorderRadius.circular(AppDimens.radiusCard),
      ),
    );
  }
}

/// Header section : titre + sous-titre + badge nombre.
class _Header extends StatelessWidget {
  const _Header({required this.count});
  final int count;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Text(
                    'Opportunités pour toi',
                    style: AppTextStyles.titleLarge.copyWith(
                      fontFamily: 'Poppins',
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.3,
                      color: AppColors.text,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      '$count',
                      style: AppTextStyles.labelSmall.copyWith(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                'Demandes d\'achat qui matchent tes cultures.',
                style: AppTextStyles.bodySmall.copyWith(
                  fontSize: 12.5,
                  color: AppColors.textSecondary,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// CTA discret « Voir toutes » poussé sous la liste horizontale.
class _CtaVoirToutes extends StatelessWidget {
  const _CtaVoirToutes({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 8,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Voir toutes les opportunités',
              style: AppTextStyles.bodyMedium.copyWith(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(
              Icons.arrow_forward_rounded,
              size: 16,
              color: AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }
}

/// Liste horizontale scrollable des cartes opportunités.
class _CartesHorizontales extends StatelessWidget {
  const _CartesHorizontales({required this.opportunities});
  final List<MatchingOpportunity> opportunities;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 160,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.zero,
        itemCount: opportunities.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (_, i) => _CarteOpportunite(opportunity: opportunities[i]),
      ),
    );
  }
}

/// Carte premium d'une opportunité (largeur ~ 78% écran sur mobile).
///
/// Tap → push vers le détail de la demande d'achat (page producteur
/// dédiée à la candidature : `DemandeAchatRepondrePage`).
class _CarteOpportunite extends StatelessWidget {
  const _CarteOpportunite({required this.opportunity});
  final MatchingOpportunity opportunity;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width * 0.78;
    final o = opportunity;
    final qte = _nfFr.format(o.quantiteKg);
    final prix = _nfFr.format(o.prixMaxKg);

    return SizedBox(
      width: width.clamp(280.0, 340.0),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimens.radiusCard),
        child: InkWell(
          onTap: () => context.push(
            RouteNames.producteurDemandeAchatRepondrePathFor(o.annonceId),
          ),
          borderRadius: BorderRadius.circular(AppDimens.radiusCard),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.primary.withValues(alpha: 0.04),
                  AppColors.primary.withValues(alpha: 0.10),
                ],
              ),
              borderRadius: BorderRadius.circular(AppDimens.radiusCard),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.18),
                width: AppDimens.borderThin,
              ),
            ),
            padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header carte : nom produit en gros + score badge
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        o.produitNom,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.titleLarge.copyWith(
                          fontFamily: 'Poppins',
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.3,
                          color: AppColors.text,
                        ),
                      ),
                    ),
                    if (o.matchScore > 0) _ScoreBadge(score: o.matchScore),
                  ],
                ),
                const SizedBox(height: 6),
                // Quantité + prix
                Text(
                  '$qte kg · $prix F/kg max',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 8),
                // Buyer name
                Row(
                  children: [
                    const Icon(
                      Icons.store_outlined,
                      size: 14,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        o.buyerName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.bodySmall.copyWith(
                          fontSize: 12.5,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                // Chip région + chevron
                Row(
                  children: [
                    if ((o.regionName ?? '').trim().isNotEmpty)
                      _ChipRegion(region: o.regionName!),
                    const Spacer(),
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.arrow_forward_rounded,
                        size: 16,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Badge de score (match_score) affiché en haut à droite de chaque carte.
class _ScoreBadge extends StatelessWidget {
  const _ScoreBadge({required this.score});
  final int score;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.bolt_rounded,
            size: 11,
            color: AppColors.success,
          ),
          const SizedBox(width: 2),
          Text(
            '$score',
            style: AppTextStyles.labelSmall.copyWith(
              fontSize: 10.5,
              fontWeight: FontWeight.w800,
              color: AppColors.success,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}

/// Chip région — pilule légère avec icône.
class _ChipRegion extends StatelessWidget {
  const _ChipRegion({required this.region});
  final String region;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: AppColors.border,
          width: AppDimens.borderThin,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.place_outlined,
            size: 12,
            color: AppColors.textSecondary,
          ),
          const SizedBox(width: 3),
          Text(
            region,
            style: AppTextStyles.labelSmall.copyWith(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
