import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../models/enums.dart';
import '../../../../models/publication_coop.dart';
import '../../../../routing/route_names.dart';
import '../../../../services/providers.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../state/auth_state.dart';
import '../../communs/chargement.dart';
import '../../communs/vue_erreur.dart';
import 'barre_onglets_marche.dart';
import 'carte_publication_grille.dart';
import 'etat_sans_cooperative.dart';
import 'etat_vide_marche.dart';
import 'hero_compteur_marche.dart';
import 'onglet_marche_publications.dart';

/// Bundle pour la page : publications actives + archivées (filtrées
/// côté client) + total kg pour le compteur hero.
class _PublicationsBundle {
  const _PublicationsBundle({
    required this.actives,
    required this.archivees,
  });
  final List<PublicationCoop> actives;
  final List<PublicationCoop> archivees;
}

bool _isActive(PublicationCoop p) =>
    p.status == ProductStatus.active || p.status == ProductStatus.unknown;

final publicationsCoopProvider = FutureProvider.autoDispose
    .family<List<PublicationCoop>, String>((ref, cooperativeId) async {
  final svc = ref.read(cooperativesServiceProvider);
  final page = await svc.listPublications(
    cooperativeId: cooperativeId,
    limit: 100,
  );
  return page.data;
});

/// Liste des publications coop (mode vitrine vendeur). Utilisé dans le
/// nouvel onglet « Publications » du Stock coop — la page Marché coop
/// affiche désormais les opportunités acheteurs (cf. refonte 2026-06-05).
///
/// Pas de Scaffold ni de header — c'est un contenu pur, à insérer dans
/// un onglet ou une page parente qui fournit le chrome.
class ContenuPublicationsCoop extends ConsumerStatefulWidget {
  const ContenuPublicationsCoop({super.key});

  @override
  ConsumerState<ContenuPublicationsCoop> createState() =>
      _ContenuPublicationsCoopState();
}

class _ContenuPublicationsCoopState
    extends ConsumerState<ContenuPublicationsCoop> {
  OngletMarcheCoop _tab = OngletMarcheCoop.actives;

  void _ouvrirPub(PublicationCoop p, String coopId) {
    context.push(RouteNames.cooperativePublicationCoopDetailPathFor(p.id))
        .then((_) {
      if (mounted) {
        ref.invalidate(publicationsCoopProvider(coopId));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final coopId = user?.cooperativeId;
    if (coopId == null) {
      return const EtatSansCooperative();
    }
    final async = ref.watch(publicationsCoopProvider(coopId));
    return async.when(
      loading: () => const Padding(
        padding: EdgeInsets.only(top: 48),
        child: Chargement(size: 22),
      ),
      error: (e, _) => Padding(
        padding: const EdgeInsets.all(AppDimens.pagePaddingH),
        child: VueErreur(
          message: 'Impossible de charger les publications. $e',
          onRetry: () => ref.invalidate(publicationsCoopProvider(coopId)),
        ),
      ),
      data: (all) {
        final actives = all.where(_isActive).toList(growable: false);
        final archivees = all
            .where((p) =>
                p.status == ProductStatus.sold ||
                p.status == ProductStatus.expired ||
                p.status == ProductStatus.paused)
            .toList(growable: false);
        final bundle = _PublicationsBundle(
          actives: actives,
          archivees: archivees,
        );
        final pubs = _tab == OngletMarcheCoop.actives
            ? bundle.actives
            : bundle.archivees;
        final totalKgActives =
            bundle.actives.fold<double>(0, (acc, p) => acc + p.quantiteKg);
        final tonnesLabel = _formatTonnes(totalKgActives);
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppDimens.pagePaddingH,
                AppDimens.space8,
                AppDimens.pagePaddingH,
                AppDimens.space12,
              ),
              child: HeroCompteurMarche(
                titre: '${bundle.actives.length} publications actives',
                sousTitre: tonnesLabel,
              ),
            ),
            BarreOngletsMarche(
              current: _tab,
              activesCount: bundle.actives.length,
              archiveesCount: bundle.archivees.length,
              onSelect: (t) => setState(() => _tab = t),
            ),
            Expanded(
              child: pubs.isEmpty
                  ? EtatVideMarche(tab: _tab)
                  : RefreshIndicator(
                      color: AppColors.primary,
                      onRefresh: () async {
                        ref.invalidate(publicationsCoopProvider(coopId));
                        await ref.read(
                            publicationsCoopProvider(coopId).future);
                      },
                      child: GridView.builder(
                        padding: const EdgeInsets.fromLTRB(
                          AppDimens.pagePaddingH,
                          AppDimens.space12,
                          AppDimens.pagePaddingH,
                          AppDimens.space16,
                        ),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 0.72,
                        ),
                        itemCount: pubs.length,
                        itemBuilder: (_, i) => CartePublicationGrille(
                          pub: pubs[i],
                          onTap: () => _ouvrirPub(pubs[i], coopId),
                        ),
                      ),
                    ),
            ),
          ],
        );
      },
    );
  }
}

String _formatTonnes(double kg) {
  if (kg < 1000) return '${kg.round()} kg';
  final tonnes = kg / 1000;
  if (tonnes >= 10) return '${tonnes.toStringAsFixed(0)} tonnes';
  return '${tonnes.toStringAsFixed(1)} tonnes';
}
