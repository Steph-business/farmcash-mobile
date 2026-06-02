import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/enums.dart';
import '../../../models/publication_coop.dart';
import '../../../services/providers.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_dimens.dart';
import '../../state/auth_state.dart';
import '../../widgets/communs/chargement.dart';
import '../../widgets/communs/header_utilisateur.dart';
import '../../widgets/communs/snackbars.dart';
import '../../widgets/communs/vue_erreur.dart';
import '../../widgets/cooperative/publications/barre_onglets_marche.dart';
import '../../widgets/cooperative/publications/carte_publication_grille.dart';
import '../../widgets/cooperative/publications/etat_sans_cooperative.dart';
import '../../widgets/cooperative/publications/etat_vide_marche.dart';
import '../../widgets/cooperative/publications/hero_compteur_marche.dart';
import '../../widgets/cooperative/publications/onglet_marche_publications.dart';
import '../../widgets/cooperative/publications/titre_marche.dart';

/// Bundle pour la page : publications actives + archivées (filtrées
/// côté client) + total kg pour le compteur hero.
class _MarcheBundle {
  const _MarcheBundle({required this.actives, required this.archivees});
  final List<PublicationCoop> actives;
  final List<PublicationCoop> archivees;
}

bool _isActive(PublicationCoop p) =>
    p.status == ProductStatus.active || p.status == ProductStatus.unknown;

final _marcheCoopProvider = FutureProvider.autoDispose
    .family<_MarcheBundle, String>((ref, cooperativeId) async {
  final svc = ref.read(cooperativesServiceProvider);
  final page = await svc.listPublications(
    cooperativeId: cooperativeId,
    limit: 100,
  );
  final all = page.data;
  return _MarcheBundle(
    actives: all.where(_isActive).toList(growable: false),
    archivees: all
        .where((p) =>
            p.status == ProductStatus.sold ||
            p.status == ProductStatus.expired ||
            p.status == ProductStatus.paused)
        .toList(growable: false),
  );
});

/// Onglet Marché de la coopérative — branché sur `listPublications`.
class MarcheCooperativePage extends ConsumerStatefulWidget {
  const MarcheCooperativePage({super.key});

  @override
  ConsumerState<MarcheCooperativePage> createState() =>
      _MarcheCooperativePageState();
}

class _MarcheCooperativePageState extends ConsumerState<MarcheCooperativePage> {
  OngletMarcheCoop _tab = OngletMarcheCoop.actives;

  void _ouvrirPub(PublicationCoop p) {
    // V1 : pas d'écran "détail publication" coop. On informe via le
    // snackbar unifié style apps pro (fond sombre + icône colorée).
    Snackbars.showInfo(context, 'Détail publication ${p.titre} — à venir');
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final coopId = user?.cooperativeId;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const HeaderUtilisateur(variant: HeaderVariant.cooperative),
            const TitreMarche(),
            Expanded(
              child: coopId == null
                  ? const EtatSansCooperative()
                  : _buildLoaded(coopId),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoaded(String coopId) {
    final async = ref.watch(_marcheCoopProvider(coopId));
    return async.when(
      loading: () => const Padding(
        padding: EdgeInsets.only(top: 48),
        child: Chargement(size: 22),
      ),
      error: (e, _) => Padding(
        padding: const EdgeInsets.all(AppDimens.pagePaddingH),
        child: VueErreur(
          message: 'Impossible de charger les publications. $e',
          onRetry: () => ref.invalidate(_marcheCoopProvider(coopId)),
        ),
      ),
      data: (bundle) {
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
                0,
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
                        ref.invalidate(_marcheCoopProvider(coopId));
                        await ref.read(_marcheCoopProvider(coopId).future);
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
                          onTap: () => _ouvrirPub(pubs[i]),
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
