import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../api_client/api_exception.dart';
import '../../../../models/annonce_achat.dart';
import '../../../../models/enums.dart';
import '../../../../models/negociation.dart';
import '../../../../models/parcelle.dart';
import '../../../../services/providers.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../widgets/communs/chargement.dart';
import '../../../widgets/communs/snackbars.dart';
import '../../../widgets/communs/vue_erreur.dart';
import '../../../widgets/producteur/demandes/demande_deja_candidate_view.dart';
import '../../../widgets/producteur/demandes/demande_help_text.dart';
import '../../../widgets/producteur/demandes/demande_input_unit.dart';
import '../../../widgets/producteur/demandes/demande_note_field.dart';
import '../../../widgets/producteur/demandes/demande_parcelle_selector.dart';
import '../../../widgets/producteur/demandes/demande_proposal_divider.dart';
import '../../../widgets/producteur/demandes/demande_recap_card.dart';
import '../../../widgets/producteur/demandes/demande_repondre_header.dart';
import '../../../widgets/producteur/demandes/demande_section_title.dart';
import '../../../widgets/producteur/demandes/demande_sticky_actions.dart';
import '../../../widgets/producteur/demandes/demande_total_card.dart';

// ─── Provider ────────────────────────────────────────────────────────

class _RepondreBundle {
  const _RepondreBundle({
    required this.demande,
    required this.parcelles,
    required this.dejaCandidate,
  });
  final AnnonceAchat demande;
  final List<Parcelle> parcelles;

  /// Proposition encore active (pending / counter_offer) déjà envoyée
  /// par le FARMER sur cette demande. Null si pas de candidature en cours
  /// → le formulaire est utilisable. Sinon → on affiche un état "Déjà
  /// candidaté" pour empêcher un nouveau submit qui serait rejeté en 409.
  final Proposition? dejaCandidate;
}

final _repondreBundleProvider = FutureProvider.autoDispose
    .family<_RepondreBundle, String>((ref, demandeId) async {
  final marketSvc = ref.read(marketplaceServiceProvider);
  final negoSvc = ref.read(negotiationServiceProvider);
  // 3 appels parallèles :
  //  • la demande d'achat (CRITIQUE — laisse remonter l'erreur si KO)
  //  • les parcelles du FARMER (optionnel, fallback liste vide)
  //  • ses propositions sortantes — pour détecter une candidature
  //    existante sur cette demande et éviter un 409 backend.
  final results = await Future.wait<dynamic>([
    marketSvc.getAnnonceAchat(demandeId),
    marketSvc.listParcelles().then<Object?>((v) => v).catchError(
      (Object _) => const <Parcelle>[],
    ),
    negoSvc
        .listPropositions(direction: 'outgoing')
        .then<Object?>((v) => v)
        .catchError((Object _) => const <Proposition>[]),
  ]);
  final propositions = (results[2] as List<Proposition>);
  // Une candidature est "active" tant qu'elle n'est ni acceptée, ni
  // rejetée, ni annulée — typiquement PENDING ou COUNTER_OFFER.
  final dejaCandidate = propositions
      .where((p) =>
          p.annonceAchatId == demandeId &&
          (p.status == NegotiationStatus.pending ||
              p.status == NegotiationStatus.counterOffered))
      .cast<Proposition?>()
      .firstOrNull;
  return _RepondreBundle(
    demande: results[0] as AnnonceAchat,
    parcelles: results[1] as List<Parcelle>,
    dejaCandidate: dejaCandidate,
  );
});

/// Réponse du FARMER à une demande d'achat publique (AnnonceAchat). Le
/// formulaire crée une `Proposition` côté backend (`POST /negotiation/
/// propositions`). Le BUYER recevra ensuite l'offre dans son flux et
/// pourra accepter / refuser / contre-offrir.
class DemandeAchatRepondrePage extends ConsumerStatefulWidget {
  const DemandeAchatRepondrePage({required this.demandeId, super.key});

  final String demandeId;

  @override
  ConsumerState<DemandeAchatRepondrePage> createState() =>
      _DemandeAchatRepondrePageState();
}

class _DemandeAchatRepondrePageState
    extends ConsumerState<DemandeAchatRepondrePage> {
  final _qteCtrl = TextEditingController();
  final _prixCtrl = TextEditingController();
  final _msgCtrl = TextEditingController();
  String? _parcelleId;
  bool _isSubmitting = false;
  bool _initialised = false;

  @override
  void initState() {
    super.initState();
    _qteCtrl.addListener(_onChange);
    _prixCtrl.addListener(_onChange);
  }

  @override
  void dispose() {
    _qteCtrl.dispose();
    _prixCtrl.dispose();
    _msgCtrl.dispose();
    super.dispose();
  }

  void _onChange() {
    if (mounted) setState(() {});
  }

  /// Pré-remplit la quantité demandée (ou un peu moins) et un prix sous le
  /// max accepté pour gagner l'enchère.
  void _hydrateOnce(_RepondreBundle bundle) {
    if (_initialised) return;
    _initialised = true;
    _qteCtrl.text = bundle.demande.quantiteKg.round().toString();
    final prixCible = (bundle.demande.prixMaxKg * 0.95).round();
    _prixCtrl.text = prixCible.toString();
    if (bundle.parcelles.isNotEmpty) {
      _parcelleId = bundle.parcelles.first.id;
    }
  }

  double get _qte =>
      double.tryParse(_qteCtrl.text.trim().replaceAll(',', '.')) ?? 0;
  double get _prix =>
      double.tryParse(_prixCtrl.text.trim().replaceAll(',', '.')) ?? 0;
  double get _total => _qte * _prix;

  Future<void> _envoyer() async {
    if (_isSubmitting) return;
    if (_qte <= 0 || _prix <= 0) {
      Snackbars.showErreur(context, 'Indique une quantité et un prix valides.');
      return;
    }
    setState(() => _isSubmitting = true);
    try {
      await ref.read(negotiationServiceProvider).createProposition(
            annonceAchatId: widget.demandeId,
            quantiteKg: _qte,
            prixProposeKg: _prix,
            message: _msgCtrl.text.trim().isEmpty
                ? null
                : _msgCtrl.text.trim(),
          );
      if (!mounted) return;
      Snackbars.showSucces(context, 'Proposition envoyée à l\'acheteur.');
      Navigator.of(context).pop(true);
    } on ApiException catch (e) {
      if (!mounted) return;
      Snackbars.showErreur(context, e.message);
    } catch (e) {
      if (!mounted) return;
      Snackbars.showErreur(context, 'Erreur : $e');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _refuser() {
    Navigator.of(context).pop(false);
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(_repondreBundleProvider(widget.demandeId));
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: async.when(
          loading: () => const Column(
            children: [
              DemandeRepondreHeader(),
              Expanded(child: Chargement(size: 22)),
            ],
          ),
          error: (e, _) => Column(
            children: [
              const DemandeRepondreHeader(),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(AppDimens.pagePaddingH),
                  child: VueErreur(
                    message: 'Impossible de charger la demande. $e',
                    onRetry: () => ref
                        .invalidate(_repondreBundleProvider(widget.demandeId)),
                  ),
                ),
              ),
            ],
          ),
          data: (bundle) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) _hydrateOnce(bundle);
            });
            return _build(bundle);
          },
        ),
      ),
    );
  }

  Widget _build(_RepondreBundle bundle) {
    final d = bundle.demande;
    final parcelles = bundle.parcelles;

    // Si une proposition active existe déjà pour cette demande, on
    // empêche la double-candidature côté UI (le backend renvoie 409
    // sinon, ce qui était confus pour l'utilisateur). On affiche à la
    // place une bannière "Tu as déjà candidaté" avec un CTA vers la
    // page Offres reçues où il peut retrouver / annuler sa proposition.
    final dejaCandidate = bundle.dejaCandidate;
    if (dejaCandidate != null) {
      return DemandeDejaCandidateView(demande: d, proposition: dejaCandidate);
    }

    double? maxDispo;
    if (_parcelleId != null && parcelles.isNotEmpty) {
      maxDispo = parcelles
          .firstWhere(
            (p) => p.id == _parcelleId,
            orElse: () => parcelles.first,
          )
          .superficieHa;
    }
    return Column(
      children: [
        const DemandeRepondreHeader(),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
            children: [
              // Section "Détails de la demande" — lecture seule. Affiche le
              // nom de l'acheteur (jointure `users.full_name`), sa photo si
              // dispo, la région (`regions_ci.nom`), le produit, la quantité,
              // le prix max accepté, la date limite et la description.
              DemandeRecapCard(demande: d),
              AppDimens.vGap24,
              // Séparateur visuel net entre la lecture et le formulaire.
              // Le titre "Ma proposition" rend explicite que la suite est
              // l'action du producteur — pas la simple consultation.
              const DemandeProposalDivider(),
              AppDimens.vGap16,
              const DemandeSectionTitle(title: 'Depuis quelle parcelle ?'),
              AppDimens.vGap8,
              DemandeParcelleSelector(
                parcelles: parcelles,
                selectedId: _parcelleId,
                onChanged: (id) => setState(() => _parcelleId = id),
                enabled: !_isSubmitting,
              ),
              AppDimens.vGap16,
              const DemandeSectionTitle(title: 'Quantité que je peux fournir'),
              AppDimens.vGap8,
              DemandeInputUnit(
                controller: _qteCtrl,
                unit: 'kg',
                enabled: !_isSubmitting,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: false),
                formatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                ],
              ),
              AppDimens.vGap8,
              if (maxDispo != null)
                DemandeHelpText(
                  text:
                      'Parcelle de ${_fmt(maxDispo)} ha — adapte la quantité selon ta récolte.',
                ),
              AppDimens.vGap16,
              const DemandeSectionTitle(title: 'Prix proposé'),
              AppDimens.vGap8,
              DemandeInputUnit(
                controller: _prixCtrl,
                unit: 'F / kg',
                enabled: !_isSubmitting,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: false),
                formatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                ],
              ),
              AppDimens.vGap8,
              DemandeHelpText(
                text:
                    'L\'acheteur accepte jusqu\'à ${_fmt(d.prixMaxKg)} F/kg. Tu peux baisser pour gagner l\'offre.',
              ),
              AppDimens.vGap16,
              DemandeTotalCard(total: _total),
              AppDimens.vGap24,
              const DemandeSectionTitle(
                title: 'Message à l\'acheteur (optionnel)',
              ),
              AppDimens.vGap8,
              DemandeNoteField(controller: _msgCtrl, enabled: !_isSubmitting),
            ],
          ),
        ),
        DemandeStickyActions(
          isSubmitting: _isSubmitting,
          onEnvoyer: _envoyer,
          onRefuser: _refuser,
        ),
      ],
    );
  }
}

// ─── Helpers ──────────────────────────────────────────────────────

String _fmt(double v) => NumberFormat('#,##0', 'fr_FR').format(v.round());
