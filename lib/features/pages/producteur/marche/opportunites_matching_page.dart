import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../models/matching.dart';
import '../../../../routing/route_names.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';
import '../../../widgets/communs/chargement.dart';
import '../../../widgets/communs/entete_page_standard.dart';
import '../../../widgets/communs/vue_erreur.dart';
import '../../../widgets/producteur/accueil/section_opportunites_matching.dart';

/// Page « Opportunités pour toi » — liste complète des demandes d'achat
/// qui matchent les cultures déclarées du producteur connecté.
///
/// Accessible depuis le CTA « Voir toutes les opportunités » sur
/// l'accueil. Pull-to-refresh + état vide premium si aucune opportunité.
class OpportunitesMatchingPage extends ConsumerWidget {
  const OpportunitesMatchingPage({super.key});

  Future<void> _refresh(WidgetRef ref) async {
    ref.invalidate(opportunitesMatchingProducteurProvider);
    await ref.read(opportunitesMatchingProducteurProvider.future);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(opportunitesMatchingProducteurProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const EntetePageStandard(titre: 'Opportunités pour toi'),
            Expanded(
              child: async.when(
                loading: () => const Padding(
                  padding: EdgeInsets.only(top: AppDimens.space32),
                  child: Chargement(size: 22),
                ),
                error: (e, _) => Padding(
                  padding: const EdgeInsets.all(AppDimens.pagePaddingH),
                  child: VueErreur(
                    message: 'Impossible de charger les opportunités.',
                    onRetry: () => _refresh(ref),
                  ),
                ),
                data: (opportunities) {
                  if (opportunities.isEmpty) {
                    return _EtatVidePremium(onRefresh: () => _refresh(ref));
                  }
                  return RefreshIndicator(
                    color: AppColors.primary,
                    onRefresh: () => _refresh(ref),
                    child: ListView.separated(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(
                        AppDimens.pagePaddingH,
                        14,
                        AppDimens.pagePaddingH,
                        AppDimens.space24,
                      ),
                      itemCount: opportunities.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemBuilder: (_, i) =>
                          _LigneOpportunite(opportunity: opportunities[i]),
                    ),
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

/// État vide premium centré, encourageant.
class _EtatVidePremium extends StatelessWidget {
  const _EtatVidePremium({required this.onRefresh});
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: onRefresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          const SizedBox(height: 80),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.auto_awesome_rounded,
                      size: 34,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'Aucune opportunité pour l\'instant',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.titleLarge.copyWith(
                      fontFamily: 'Poppins',
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: AppColors.text,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Reviens plus tard : on te notifie dès qu\'un acheteur '
                    'publie une demande qui correspond à tes cultures.',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontSize: 13.5,
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

final NumberFormat _nfFr = NumberFormat('#,##0', 'fr_FR');

/// Carte ligne — déclinaison « pleine largeur » de la carte horizontale
/// utilisée sur l'accueil. Tap → page candidature demande achat.
class _LigneOpportunite extends StatelessWidget {
  const _LigneOpportunite({required this.opportunity});
  final MatchingOpportunity opportunity;

  @override
  Widget build(BuildContext context) {
    final o = opportunity;
    final qte = _nfFr.format(o.quantiteKg);
    final prix = _nfFr.format(o.prixMaxKg);

    return Material(
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
          padding: const EdgeInsets.fromLTRB(14, 14, 12, 14),
          child: Row(
            children: [
              // Pastille produit (initiale)
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Text(
                  o.produitNom.isEmpty
                      ? '?'
                      : o.produitNom.characters.first.toUpperCase(),
                  style: AppTextStyles.titleLarge.copyWith(
                    fontFamily: 'Poppins',
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
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
                      o.produitNom,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.titleMedium.copyWith(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.text,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$qte kg · $prix F/kg max',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.store_outlined,
                          size: 12,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 3),
                        Expanded(
                          child: Text(
                            o.buyerName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.bodySmall.copyWith(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                        if ((o.regionName ?? '').trim().isNotEmpty) ...[
                          const SizedBox(width: 6),
                          const Icon(
                            Icons.place_outlined,
                            size: 12,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 2),
                          Flexible(
                            child: Text(
                              o.regionName!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.bodySmall.copyWith(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.chevron_right_rounded,
                size: 22,
                color: AppColors.textSubtle,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
