import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../models/prevision.dart';
import '../../../../routing/route_names.dart';
import '../../../../services/providers.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../widgets/acheteur/marche/hero_prevision_detail.dart';
import '../../../widgets/acheteur/marche/info_acompte_card_prevision.dart';
import '../../../widgets/acheteur/marche/prevision_detail_constants.dart';
import '../../../widgets/acheteur/marche/progress_bar_prevision.dart';
import '../../../widgets/acheteur/marche/section_comment_ca_marche_prevision.dart';
import '../../../widgets/acheteur/marche/section_vendeur_prevision.dart';
import '../../../widgets/acheteur/marche/sticky_bottom_prevision.dart';
import '../../../widgets/acheteur/marche/title_card_prevision.dart';
import '../../../widgets/communs/chargement.dart';
import '../../../widgets/communs/entete_page_standard.dart';
import '../../../widgets/communs/vue_erreur.dart';

/// Charge une prévision par id en cherchant dans la liste globale — `null`
/// si le backend ne la trouve pas (fallback maquette pris en compte côté UI).
final _previsionAcheteurDetailProvider = FutureProvider.autoDispose
    .family<Prevision?, String>((ref, id) async {
  try {
    final all = await ref.read(marketplaceServiceProvider).listPrevisions();
    return all.firstWhere(
      (p) => p.id == id,
      orElse: () => throw Exception('not found'),
    );
  } catch (_) {
    return null;
  }
});

/// Détail d'une prévision côté ACHETEUR — hero + badge orange, recap,
/// info acompte 10%, barre progression, vendeur anonymisé, 3 steps,
/// sticky qty + bouton réserver.
class PrevisionDetailAcheteurPage extends ConsumerStatefulWidget {
  const PrevisionDetailAcheteurPage({required this.previsionId, super.key});

  final String previsionId;

  @override
  ConsumerState<PrevisionDetailAcheteurPage> createState() =>
      _PrevisionDetailAcheteurPageState();
}

class _PrevisionDetailAcheteurPageState
    extends ConsumerState<PrevisionDetailAcheteurPage> {
  int _qte = 200;

  @override
  Widget build(BuildContext context) {
    final async =
        ref.watch(_previsionAcheteurDetailProvider(widget.previsionId));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: async.when(
          loading: () => const Column(
            children: [
              EntetePageStandard(titre: 'Chargement…'),
              Expanded(child: Chargement(size: 22)),
            ],
          ),
          error: (e, _) => Column(
            children: [
              const EntetePageStandard(titre: 'Prévision'),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(AppDimens.pagePaddingH),
                  child: VueErreur(
                    message: 'Impossible de charger la prévision.',
                    onRetry: () => ref.invalidate(
                      _previsionAcheteurDetailProvider(widget.previsionId),
                    ),
                  ),
                ),
              ),
            ],
          ),
          data: (p) => _buildContent(p),
        ),
      ),
    );
  }

  Widget _buildContent(Prevision? p) {
    // Fallback aux valeurs de la maquette si pas de backend.
    final nom = kPrevisionDetailMock.nom;
    final qualite = kPrevisionDetailMock.qualite;
    final prix = p?.prixCibleKg?.round() ?? kPrevisionDetailMock.prixPrev;
    final qteTotale =
        p?.quantitePrevKg.round() ?? kPrevisionDetailMock.qteTotalePrev;
    final qteReservee = kPrevisionDetailMock.qteReservee;
    final progress = qteTotale > 0 ? qteReservee / qteTotale : 0.6;
    final dispoLe = p?.dateRecoltePrev != null
        ? 'Disponible le ${DateFormat('d MMM', 'fr_FR').format(p!.dateRecoltePrev!)}'
        : kPrevisionDetailMock.disponibleLe;
    final acompteAffiche = (qteTotale * prix * 0.10).round();

    return Column(
      children: [
        EntetePageStandard(titre: 'Prévision · $nom'),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.only(bottom: 100),
            children: [
              HeroPrevisionDetail(
                photoUrl: kPrevisionDetailHeroFallback,
                badgeText: 'Prévision · $dispoLe',
              ),
              TitleCardPrevision(
                nom: nom,
                qualite: qualite,
                prixPrevu: prix,
                qteTotale: qteTotale,
              ),
              InfoAcompteCardPrevision(acompte: acompteAffiche),
              ProgressBarPrevision(
                qteReservee: qteReservee,
                qteTotale: qteTotale,
                progress: progress,
              ),
              SectionVendeurPrevision(nom: kPrevisionDetailMock.vendeurAnonymise),
              const SectionCommentCaMarchePrevision(),
            ],
          ),
        ),
        StickyBottomPrevision(
          qte: _qte,
          onMinus: () {
            if (_qte > 1) setState(() => _qte--);
          },
          onPlus: () => setState(() => _qte++),
          onReserver: () => context.push(
            RouteNames.acheteurReservationPaiementPathFor(widget.previsionId),
          ),
        ),
      ],
    );
  }
}
