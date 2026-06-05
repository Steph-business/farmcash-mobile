import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../models/enums.dart';
import '../../../../models/negociation.dart';
import '../../../../services/providers.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../widgets/communs/chargement.dart';
import '../../../widgets/communs/vue_erreur.dart';
import '../../../widgets/producteur/offres/carte_offre.dart';
import '../../../widgets/producteur/offres/etat_vide_offres.dart';
import '../../../widgets/producteur/offres/filtres_offres.dart';
import '../../../widgets/producteur/offres/header_offres.dart';
import '../../../widgets/producteur/offres/offre_modeles.dart';
import '../../../widgets/producteur/offres/sous_titre_offres.dart';

final _offresProvider =
    FutureProvider.autoDispose<OffresBundle>((ref) async {
  final svc = ref.read(negotiationServiceProvider);
  // Pas de `.catchError((_) => [])` ici : avaler les erreurs faisait
  // afficher "aucune offre" alors que l'API renvoyait un 401/500. Si
  // l'un des deux endpoints échoue, on laisse l'exception remonter au
  // FutureProvider — la page affiche une VueErreur avec le vrai
  // message + bouton Réessayer. Les deux appels restent en parallèle.
  final results = await Future.wait<dynamic>([
    svc.listCandidatures(direction: 'incoming'),
    svc.listPropositions(direction: 'outgoing'),
  ]);
  final candidatures = results[0] as List<Candidature>;
  final propositions = results[1] as List<Proposition>;
  final offres = <OffreUnifiee>[
    ...candidatures.map(OffreUnifiee.fromCandidature),
    ...propositions.map(OffreUnifiee.fromProposition),
  ];
  // Tri par date de création décroissante (les plus récentes en premier).
  offres.sort((a, b) {
    final aDt = a.createdAt ?? DateTime(1970);
    final bDt = b.createdAt ?? DateTime(1970);
    return bDt.compareTo(aDt);
  });
  return OffresBundle(offres: offres);
});

/// Liste des offres reçues sur les annonces du producteur — branchée
/// sur `negotiationService`. Le FARMER peut accepter ou refuser ; les
/// candidatures vont vers `traiterCandidature`, les propositions vers
/// `traiterProposition`.
class OffresRecuesPage extends ConsumerStatefulWidget {
  const OffresRecuesPage({super.key});

  @override
  ConsumerState<OffresRecuesPage> createState() => _OffresRecuesPageState();
}

class _OffresRecuesPageState extends ConsumerState<OffresRecuesPage> {
  StatusFilter _filter = StatusFilter.toutes;

  Future<void> _refresh() async {
    ref.invalidate(_offresProvider);
    await ref.read(_offresProvider.future);
  }

  List<OffreUnifiee> _filtrer(List<OffreUnifiee> source) {
    switch (_filter) {
      case StatusFilter.toutes:
        return source;
      case StatusFilter.pending:
        return source
            .where((o) => o.status == NegotiationStatus.pending)
            .toList();
      case StatusFilter.accepted:
        return source
            .where((o) => o.status == NegotiationStatus.accepted)
            .toList();
      case StatusFilter.refused:
        return source
            .where((o) =>
                o.status == NegotiationStatus.rejected ||
                o.status == NegotiationStatus.cancelled)
            .toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(_offresProvider);
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const HeaderOffres(),
            Expanded(
              child: async.when(
                loading: () => const Padding(
                  padding: EdgeInsets.only(top: 48),
                  child: Chargement(size: 22),
                ),
                error: (e, _) => Padding(
                  padding: const EdgeInsets.all(AppDimens.pagePaddingH),
                  child: VueErreur(
                    message: 'Impossible de charger les offres. $e',
                    onRetry: _refresh,
                  ),
                ),
                data: _buildBody,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(OffresBundle bundle) {
    final pendingCount = bundle.offres
        .where((o) => o.status == NegotiationStatus.pending)
        .length;
    final filtered = _filtrer(bundle.offres);
    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: _refresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          AppDimens.pagePaddingH,
          0,
          AppDimens.pagePaddingH,
          AppDimens.space24,
        ),
        children: [
          SousTitreOffres(count: pendingCount),
          AppDimens.vGap12,
          FiltresOffres(
            selection: _filter,
            onChanged: (f) => setState(() => _filter = f),
          ),
          AppDimens.vGap16,
          if (filtered.isEmpty)
            const EtatVideOffres()
          else
            ...filtered.map((o) => CarteOffre(offre: o)),
        ],
      ),
    );
  }
}
