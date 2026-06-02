import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../api_client/api_exception.dart';
import '../../../../models/annonce_achat.dart';
import '../../../../models/negociation.dart';
import '../../../../services/negotiation_service.dart';
import '../../../../services/providers.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';
import '../../../widgets/acheteur/demandes/carte_proposition_demande.dart';
import '../../../widgets/acheteur/demandes/header_propositions_demande.dart';
import 'discussion_negociation_page.dart';
import '../../../widgets/communs/chargement.dart';
import '../../../widgets/communs/snackbars.dart';
import '../../../widgets/communs/vue_erreur.dart';

// ─── Providers ──────────────────────────────────────────────────────────

/// Bundle qui couple les propositions reçues et la demande source — la
/// demande nous donne le **nom du produit** à afficher en tête des cartes
/// (sinon l'acheteur ne sait pas de quoi on parle si elle a publié
/// plusieurs demandes différentes).
class _PropositionsBundle {
  const _PropositionsBundle({required this.propositions, this.demande});
  final List<Proposition> propositions;
  final AnnonceAchat? demande;
}

final _propositionsAcheteurProvider =
    FutureProvider.autoDispose.family<_PropositionsBundle, String>(
        (ref, demandeId) async {
  final negotiation = ref.read(negotiationServiceProvider);
  final marketplace = ref.read(marketplaceServiceProvider);

  final results = await Future.wait<dynamic>([
    negotiation.listPropositions(direction: 'incoming'),
    // La demande peut avoir été supprimée ou inaccessible — on ne casse
    // pas la liste des propositions si ce fetch échoue.
    marketplace.getAnnonceAchat(demandeId).then<Object?>((v) => v).catchError(
          (_) => null,
        ),
  ]);

  final all = results[0] as List<Proposition>;
  final demande = results[1] as AnnonceAchat?;
  return _PropositionsBundle(
    propositions: all.where((p) => p.annonceAchatId == demandeId).toList(),
    demande: demande,
  );
});

/// Liste des propositions reçues sur une demande d'achat — côté ACHETEUR.
class PropositionDetailAcheteurPage extends ConsumerStatefulWidget {
  const PropositionDetailAcheteurPage({required this.demandeId, super.key});

  final String demandeId;

  @override
  ConsumerState<PropositionDetailAcheteurPage> createState() =>
      _PropositionDetailAcheteurPageState();
}

class _PropositionDetailAcheteurPageState
    extends ConsumerState<PropositionDetailAcheteurPage> {
  String? _opEnCours;

  Future<void> _refresh() async {
    ref.invalidate(_propositionsAcheteurProvider(widget.demandeId));
    await ref.read(_propositionsAcheteurProvider(widget.demandeId).future);
  }

  Future<void> _traiter(Proposition p, NegotiationAction action) async {
    if (_opEnCours != null) return;
    setState(() => _opEnCours = p.id);
    try {
      await ref.read(negotiationServiceProvider).traiterProposition(
            id: p.id,
            action: action,
          );
      await _refresh();
      if (!mounted) return;
      Snackbars.showSucces(
        context,
        action == NegotiationAction.accept
            ? 'Proposition acceptée'
            : 'Proposition refusée',
      );
    } on ApiException catch (e) {
      if (mounted) Snackbars.showErreur(context, e.message);
    } finally {
      if (mounted) setState(() => _opEnCours = null);
    }
  }

  Future<void> _discuter(Proposition p) async {
    // Avant 2026-05-27 c'était un bottom sheet — l'utilisateur préfère
    // une vraie page avec flèche back (plus naturel pour les longues
    // conversations qui peuvent scroller sur plusieurs écrans).
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => DiscussionNegociationPage(proposition: p),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(_propositionsAcheteurProvider(widget.demandeId));
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            HeaderPropositionsDemande(
              count: async.maybeWhen(
                data: (b) => b.propositions.length,
                orElse: () => 0,
              ),
            ),
            Expanded(
              child: async.when(
                loading: () => const Padding(
                  padding: EdgeInsets.only(top: AppDimens.space32),
                  child: Chargement(size: 22),
                ),
                error: (e, _) => Padding(
                  padding: const EdgeInsets.all(AppDimens.pagePaddingH),
                  child: VueErreur(
                    message: 'Impossible de charger les propositions. $e',
                    onRetry: _refresh,
                  ),
                ),
                data: (bundle) {
                  final items = bundle.propositions;
                  if (items.isEmpty) {
                    return _emptyState(context);
                  }
                  final sorted = [...items]
                    ..sort((a, b) => a.prixProposeKg.compareTo(b.prixProposeKg));
                  // Nom + photo du produit — extraits de la demande source.
                  // L'AnnonceAchat ne joint pas (encore) la photo produit
                  // côté API : pour V1 on n'envoie que le nom et on laisse
                  // l'icône eco_outlined par défaut côté carte.
                  final produitNom = bundle.demande?.produitLabel;
                  return RefreshIndicator(
                    color: AppColors.primary,
                    onRefresh: _refresh,
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
                      children: [
                        for (var i = 0; i < sorted.length; i++)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: CartePropositionDemande(
                              proposition: sorted[i],
                              isBest: i == 0,
                              busy: _opEnCours == sorted[i].id,
                              produitNom: produitNom,
                              onAccepter: () => _traiter(
                                sorted[i],
                                NegotiationAction.accept,
                              ),
                              onRefuser: () => _traiter(
                                sorted[i],
                                NegotiationAction.reject,
                              ),
                              onDiscuter: () => _discuter(sorted[i]),
                            ),
                          ),
                      ],
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

  Widget _emptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimens.space24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 44,
              color: AppColors.textSubtle.withValues(alpha: 0.9),
            ),
            const SizedBox(height: AppDimens.space12),
            Text(
              'Aucune proposition reçue',
              style: AppTextStyles.titleSmall,
            ),
            const SizedBox(height: AppDimens.space8),
            Text(
              'Les producteurs n\'ont pas encore répondu\nà ta demande.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySmall.copyWith(
                fontSize: 12,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
