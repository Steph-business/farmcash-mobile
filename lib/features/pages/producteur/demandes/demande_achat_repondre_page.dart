import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../../../api_client/api_exception.dart';
import '../../../../models/annonce_achat.dart';
import '../../../../models/enums.dart';
import '../../../../models/negociation.dart';
import '../../../../models/parcelle.dart';
import '../../../../services/providers.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';
import '../../../widgets/communs/chargement.dart';
import '../../../widgets/communs/entete_page_standard.dart';
import '../../../widgets/communs/snackbars.dart';
import '../../../widgets/communs/vue_erreur.dart';
import '../../../widgets/producteur/demandes/demande_achat_modeles.dart';
import '../../../widgets/producteur/demandes/demande_deja_candidate_view.dart';
import '../../../widgets/producteur/demandes/demande_parcelle_selector.dart';
import '../../../widgets/producteur/demandes/demande_recap_card.dart';

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
      // 3 appels parallèles : la demande (critique), les parcelles
      // (optionnel) et les propositions sortantes — pour détecter une
      // candidature existante sur cette demande et éviter un 409 backend.
      final results = await Future.wait<dynamic>([
        marketSvc.getAnnonceAchat(demandeId),
        marketSvc
            .listParcelles()
            .then<Object?>((v) => v)
            .catchError((Object _) => const <Parcelle>[]),
        negoSvc
            .listPropositions(direction: 'outgoing')
            .then<Object?>((v) => v)
            .catchError((Object _) => const <Proposition>[]),
      ]);
      final propositions = (results[2] as List<Proposition>);
      final dejaCandidate = propositions
          .where(
            (p) =>
                p.annonceAchatId == demandeId &&
                (p.status == NegotiationStatus.pending ||
                    p.status == NegotiationStatus.counterOffered),
          )
          .cast<Proposition?>()
          .firstOrNull;
      return _RepondreBundle(
        demande: results[0] as AnnonceAchat,
        parcelles: results[1] as List<Parcelle>,
        dejaCandidate: dejaCandidate,
      );
    });

// ─── Page : DÉTAILS + sticky CTA « Candidater » ─────────────────────

/// Page de détails d'une demande d'achat publique vue côté FARMER.
///
/// **Flow en 2 temps** : lecture d'abord (page complète des détails),
/// puis tap sur le CTA sticky « Candidater » → bottom sheet de
/// candidature (parcelle, qté, prix, photos, message). Évite la
/// confusion ancien design où détails + formulaire se mélangaient.
class DemandeAchatRepondrePage extends ConsumerStatefulWidget {
  const DemandeAchatRepondrePage({required this.demandeId, super.key});

  final String demandeId;

  @override
  ConsumerState<DemandeAchatRepondrePage> createState() =>
      _DemandeAchatRepondrePageState();
}

class _DemandeAchatRepondrePageState
    extends ConsumerState<DemandeAchatRepondrePage> {
  bool _isSubmitting = false;

  Future<void> _ouvrirSheetCandidater(_RepondreBundle bundle) async {
    final result = await showModalBottomSheet<_CandidatureFormResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.42),
      builder: (_) => _FeuilleCandidater(
        demande: bundle.demande,
        parcelles: bundle.parcelles,
      ),
    );
    if (result != null && mounted) {
      await _envoyer(result);
    }
  }

  Future<void> _envoyer(_CandidatureFormResult r) async {
    if (_isSubmitting) return;
    setState(() => _isSubmitting = true);
    try {
      final negoSvc = ref.read(negotiationServiceProvider);

      // 1. Upload des photos (1 round-trip par image) → URLs publiques.
      //    Tolérant : si UNE photo échoue, on continue avec les autres
      //    plutôt que de bloquer toute la candidature. On loggue pour
      //    debug.
      final photoUrls = <String>[];
      for (final x in r.photos) {
        try {
          final url = await negoSvc.uploadPropositionPhoto(File(x.path));
          photoUrls.add(url);
        } catch (e) {
          debugPrint('[candidature] upload photo KO : $e');
        }
      }

      // 2. Map date → délai en jours (le backend stocke un delai_j,
      //    pas un timestamp). >=0 même si date dans le passé proche.
      int? delaiJ;
      if (r.dateLivraison != null) {
        final d = r.dateLivraison!.difference(DateTime.now()).inDays;
        delaiJ = d < 0 ? 0 : d;
      }

      // 3. Map parcelle choisie → nom (lieu_livraison côté backend).
      String? lieuLivraison;
      if (r.parcelleId != null) {
        final bundle = ref
            .read(_repondreBundleProvider(widget.demandeId))
            .value;
        final p = bundle?.parcelles.firstWhere(
          (e) => e.id == r.parcelleId,
          orElse: () => bundle.parcelles.first,
        );
        lieuLivraison = p?.nom;
      }

      // 4. Création de la proposition avec TOUTES les méta-données :
      //    photos URLs, délai, lieu, message — plus de hack concat.
      await negoSvc.createProposition(
        annonceAchatId: widget.demandeId,
        quantiteKg: r.qte,
        prixProposeKg: r.prix,
        message: r.message,
        delaiLivraisonJ: delaiJ,
        lieuLivraison: lieuLivraison,
        photos: photoUrls.isEmpty ? null : photoUrls,
      );
      if (!mounted) return;
      Snackbars.showSucces(context, 'Proposition envoyée à l\'acheteur.');
      Navigator.of(context).pop(true);
    } on ApiException catch (e) {
      if (mounted) Snackbars.showErreur(context, e.message);
    } catch (e) {
      if (mounted) Snackbars.showErreurInattendue(context, e);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
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
              EntetePageStandard(titre: 'Demande d\'achat'),
              Expanded(child: Chargement(size: 22)),
            ],
          ),
          error: (e, _) => Column(
            children: [
              const EntetePageStandard(titre: 'Demande d\'achat'),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(AppDimens.pagePaddingH),
                  child: VueErreur(
                    message: 'Impossible de charger la demande. $e',
                    onRetry: () => ref.invalidate(
                      _repondreBundleProvider(widget.demandeId),
                    ),
                  ),
                ),
              ),
            ],
          ),
          data: (bundle) => _buildContent(bundle),
        ),
      ),
    );
  }

  Widget _buildContent(_RepondreBundle bundle) {
    // Si une proposition active existe déjà pour cette demande, on
    // empêche la double-candidature côté UI (le backend renvoie 409
    // sinon). Bannière "Déjà candidaté" → page Mes négociations.
    final dejaCandidate = bundle.dejaCandidate;
    if (dejaCandidate != null) {
      return DemandeDejaCandidateView(
        demande: bundle.demande,
        proposition: dejaCandidate,
      );
    }

    return Column(
      children: [
        const EntetePageStandard(titre: 'Demande d\'achat'),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            children: [
              DemandeRecapCard(demande: bundle.demande),
              const SizedBox(height: 16),
              const _BlocCommentCaMarche(),
              const SizedBox(height: 80), // espace pour le sticky CTA
            ],
          ),
        ),
        _StickyCandidater(
          isSubmitting: _isSubmitting,
          onTap: () => _ouvrirSheetCandidater(bundle),
        ),
      ],
    );
  }
}

// ─── Sticky CTA « Candidater » ──────────────────────────────────────

class _StickyCandidater extends StatelessWidget {
  const _StickyCandidater({required this.isSubmitting, required this.onTap});

  final bool isSubmitting;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(
          top: BorderSide(color: AppColors.border, width: AppDimens.borderThin),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 54,
          child: Material(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(14),
            child: InkWell(
              onTap: isSubmitting ? null : onTap,
              borderRadius: BorderRadius.circular(14),
              child: Center(
                child: isSubmitting
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.4,
                          color: Colors.white,
                        ),
                      )
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.handshake_outlined,
                            color: Colors.white,
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'Candidater à cette offre',
                            style: AppTextStyles.button.copyWith(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Bloc « Comment ça marche ? » ───────────────────────────────────

class _BlocCommentCaMarche extends StatelessWidget {
  const _BlocCommentCaMarche();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.18)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.lightbulb_outline_rounded,
              size: 18,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Comment candidater ?',
                  style: AppTextStyles.titleSmall.copyWith(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.text,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Renseigne la quantité que tu peux fournir, ton prix, et "
                  "ajoute des photos de ton produit. L'acheteur recevra ta "
                  'proposition et pourra accepter, refuser ou négocier.',
                  style: AppTextStyles.bodySmall.copyWith(
                    fontSize: 12.5,
                    height: 1.4,
                    color: AppColors.textSecondary,
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

// ─── Résultat retourné par la bottom sheet ──────────────────────────

class _CandidatureFormResult {
  final double qte;
  final double prix;
  final String? parcelleId;
  final DateTime? dateLivraison;
  final String? message;
  final List<XFile> photos;
  const _CandidatureFormResult({
    required this.qte,
    required this.prix,
    required this.parcelleId,
    required this.dateLivraison,
    required this.message,
    required this.photos,
  });
}

// ─── Bottom sheet : formulaire de candidature ───────────────────────

class _FeuilleCandidater extends StatefulWidget {
  const _FeuilleCandidater({required this.demande, required this.parcelles});

  final AnnonceAchat demande;
  final List<Parcelle> parcelles;

  @override
  State<_FeuilleCandidater> createState() => _FeuilleCandidaterState();
}

class _FeuilleCandidaterState extends State<_FeuilleCandidater> {
  late final TextEditingController _qteCtrl;
  late final TextEditingController _prixCtrl;
  final TextEditingController _msgCtrl = TextEditingController();
  String? _parcelleId;
  DateTime? _dateLivraison;
  final List<XFile> _photos = [];

  @override
  void initState() {
    super.initState();
    final d = widget.demande;
    // Pré-remplissage : qté demandée + prix légèrement sous le max
    // accepté pour signaler une offre compétitive.
    _qteCtrl = TextEditingController(text: d.quantiteKg.round().toString());
    _prixCtrl = TextEditingController(
      text: (d.prixMaxKg * 0.95).round().toString(),
    );
    if (widget.parcelles.isNotEmpty) {
      _parcelleId = widget.parcelles.first.id;
    }
    // Pré-remplit la date livraison à la date limite de l'acheteur si
    // elle existe — le producteur peut la modifier avant d'envoyer.
    _dateLivraison = widget.demande.dateLimiteLivraison;
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

  double get _qte =>
      double.tryParse(_qteCtrl.text.trim().replaceAll(',', '.')) ?? 0;
  double get _prix =>
      double.tryParse(_prixCtrl.text.trim().replaceAll(',', '.')) ?? 0;
  double get _total => _qte * _prix;
  bool get _valide => _qte > 0 && _prix > 0;

  Future<void> _ajouterPhoto() async {
    if (_photos.length >= 3) {
      Snackbars.showInfo(context, 'Maximum 3 photos.');
      return;
    }
    try {
      final picked = await ImagePicker().pickImage(
        source: ImageSource.camera,
        maxWidth: 1600,
        imageQuality: 80,
      );
      if (picked == null || !mounted) return;
      setState(() => _photos.add(picked));
    } catch (_) {
      if (mounted) {
        Snackbars.showErreur(context, "Impossible d'ajouter la photo.");
      }
    }
  }

  /// Ouvre un Cupertino date picker (mobile-friendly) pour choisir la
  /// date de livraison proposée. Min = aujourd'hui, max = +90 jours.
  Future<void> _choisirDate() async {
    FocusScope.of(context).unfocus();
    final now = DateTime.now();
    final initial = _dateLivraison ?? now.add(const Duration(days: 7));
    final clamped = initial.isBefore(now) ? now : initial;
    await showCupertinoModalPopup<void>(
      context: context,
      builder: (ctx) => Container(
        height: 280,
        color: CupertinoColors.systemBackground.resolveFrom(ctx),
        child: SafeArea(
          top: false,
          child: Column(
            children: [
              SizedBox(
                height: 44,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CupertinoButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      child: const Text('Annuler'),
                    ),
                    CupertinoButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      child: const Text(
                        'OK',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: CupertinoDatePicker(
                  initialDateTime: clamped,
                  minimumDate: now,
                  maximumDate: now.add(const Duration(days: 90)),
                  mode: CupertinoDatePickerMode.date,
                  onDateTimeChanged: (d) {
                    if (mounted) setState(() => _dateLivraison = d);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _ajouterPhotoGalerie() async {
    if (_photos.length >= 3) {
      Snackbars.showInfo(context, 'Maximum 3 photos.');
      return;
    }
    try {
      final picked = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 1600,
        imageQuality: 80,
      );
      if (picked == null || !mounted) return;
      setState(() => _photos.add(picked));
    } catch (_) {
      if (mounted) {
        Snackbars.showErreur(context, "Impossible d'ajouter la photo.");
      }
    }
  }

  void _envoyer() {
    if (!_valide) {
      Snackbars.showErreur(context, 'Indique une quantité et un prix valides.');
      return;
    }
    Navigator.of(context).pop(
      _CandidatureFormResult(
        qte: _qte,
        prix: _prix,
        parcelleId: _parcelleId,
        dateLivraison: _dateLivraison,
        message: _msgCtrl.text.trim().isEmpty ? null : _msgCtrl.text.trim(),
        photos: List.unmodifiable(_photos),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final d = widget.demande;
    final double? maxDispo =
        (_parcelleId != null && widget.parcelles.isNotEmpty)
        ? widget.parcelles
              .firstWhere(
                (p) => p.id == _parcelleId,
                orElse: () => widget.parcelles.first,
              )
              .superficieHa
        : null;

    // Comparaison prix vs max acheteur — pour micro-feedback dans la
    // total card (« -5% vs max » en vert, « +X% au-dessus » en ambre).
    final double prixMax = d.prixMaxKg;
    final double diffPct = (prixMax > 0 && _prix > 0)
        ? (_prix - prixMax) / prixMax * 100
        : 0;

    return DraggableScrollableSheet(
      initialChildSize: 0.90,
      minChildSize: 0.55,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollCtrl) {
        return Container(
          decoration: const BoxDecoration(
            // Fond sheet en soft → fait ressortir les cartes blanches.
            color: AppColors.surfaceSoft,
            borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
          ),
          child: Column(
            children: [
              // Drag handle.
              Padding(
                padding: const EdgeInsets.only(top: 10, bottom: 4),
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              _SheetHeaderPremium(
                produitNom: d.produitLabel,
                qteDemandee: '${_fmt(d.quantiteKg)} kg',
                buyerNom: d.buyerNom ?? 'Acheteur',
                onClose: () => Navigator.of(context).pop(),
              ),
              const Divider(height: 1, color: AppColors.border),
              Expanded(
                child: ListView(
                  controller: scrollCtrl,
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                  children: [
                    // 1. Photos (EN-TÊTE) — preuve visuelle du produit en
                    //    premier, comme demandé par l'utilisateur.
                    _SectionPremium(
                      icon: Icons.photo_library_outlined,
                      label: 'PHOTOS DU PRODUIT',
                      trailing: _CompteurBadge(valeur: '${_photos.length}/3'),
                      child: _GrillePhotosPremium(
                        photos: _photos,
                        onAjouter: _ajouterPhoto,
                        onGalerie: _ajouterPhotoGalerie,
                        onSupprimer: (i) => setState(() => _photos.removeAt(i)),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // 2. Quantité
                    _SectionPremium(
                      icon: Icons.scale_outlined,
                      label: 'QUANTITÉ QUE JE PEUX FOURNIR',
                      helper: maxDispo != null
                          ? 'Parcelle de ${_fmt(maxDispo)} ha — adapte la '
                                'quantité selon ta récolte.'
                          : null,
                      child: _ChampNumeriquePremium(
                        controller: _qteCtrl,
                        unit: 'kg',
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: false,
                        ),
                        formatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // 3. Prix proposé
                    _SectionPremium(
                      icon: Icons.payments_outlined,
                      label: 'PRIX PROPOSÉ',
                      helper:
                          "Max acheteur : ${_fmt(d.prixMaxKg)} F/kg — "
                          "baisse un peu pour gagner l'offre.",
                      child: _ChampNumeriquePremium(
                        controller: _prixCtrl,
                        unit: 'F / kg',
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: false,
                        ),
                        formatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // 4. Total estimé — HERO card visuelle (vert plein).
                    _CarteTotalHero(total: _total, diffPctVsMax: diffPct),
                    const SizedBox(height: 12),

                    // 5. Localisation (= parcelle, renommée pour clarté)
                    _SectionPremium(
                      icon: Icons.place_outlined,
                      label: 'LOCALISATION',
                      child: DemandeParcelleSelector(
                        parcelles: widget.parcelles,
                        selectedId: _parcelleId,
                        onChanged: (id) => setState(() => _parcelleId = id),
                        enabled: true,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // 6. Date de livraison (NEW) — pré-rempli avec la date
                    //    limite acheteur, modifiable. Tap → CupertinoDatePicker.
                    _SectionPremium(
                      icon: Icons.event_outlined,
                      label: 'DATE DE LIVRAISON',
                      child: _ChampDate(
                        date: _dateLivraison,
                        onTap: _choisirDate,
                        onClear: () => setState(() => _dateLivraison = null),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // 7. Message (optionnel, gardé en fin)
                    _SectionPremium(
                      icon: Icons.chat_bubble_outline_rounded,
                      label: "MESSAGE À L'ACHETEUR (OPTIONNEL)",
                      child: _ChampMessagePremium(controller: _msgCtrl),
                    ),
                  ],
                ),
              ),
              // Bouton submit en bas de sheet
              Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(top: BorderSide(color: AppColors.border)),
                ),
                padding: EdgeInsets.fromLTRB(
                  16,
                  12,
                  16,
                  12 + MediaQuery.of(context).viewInsets.bottom,
                ),
                child: SafeArea(
                  top: false,
                  child: SizedBox(
                    height: 54,
                    child: Material(
                      color: _valide
                          ? AppColors.primary
                          : AppColors.borderStrong,
                      borderRadius: BorderRadius.circular(14),
                      child: InkWell(
                        onTap: _valide ? _envoyer : null,
                        borderRadius: BorderRadius.circular(14),
                        child: Center(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.send_rounded,
                                size: 18,
                                color: _valide
                                    ? Colors.white
                                    : AppColors.textSubtle,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                'Envoyer ma proposition',
                                style: AppTextStyles.button.copyWith(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: _valide
                                      ? Colors.white
                                      : AppColors.textSubtle,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─── HEADER de sheet : thumb produit + titre + contexte ─────────────

class _SheetHeaderPremium extends StatelessWidget {
  const _SheetHeaderPremium({
    required this.produitNom,
    required this.qteDemandee,
    required this.buyerNom,
    required this.onClose,
  });

  final String produitNom;
  final String qteDemandee;
  final String buyerNom;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 8, 12),
      child: Row(
        children: [
          // Thumbnail produit 44px — donne le contexte visuel direct.
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Container(
              width: 44,
              height: 44,
              color: AppColors.surfaceSoft,
              child: Image.network(
                thumbForProduit(produitNom),
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => const Icon(
                  Icons.image_outlined,
                  size: 22,
                  color: AppColors.textSubtle,
                ),
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
                  'Ma proposition',
                  style: AppTextStyles.titleLarge.copyWith(
                    fontFamily: 'Poppins',
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                    color: AppColors.text,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Pour $qteDemandee de $produitNom · $buyerNom',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodySmall.copyWith(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close_rounded),
            color: AppColors.textSecondary,
            onPressed: onClose,
            tooltip: 'Fermer',
          ),
        ],
      ),
    );
  }
}

// ─── SECTION premium : carte blanche avec icône + label + child ─────

class _SectionPremium extends StatelessWidget {
  const _SectionPremium({
    required this.icon,
    required this.label,
    required this.child,
    this.trailing,
    this.helper,
  });

  final IconData icon;
  final String label;
  final Widget child;
  final Widget? trailing;
  final String? helper;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Ligne header section
          Row(
            children: [
              Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(7),
                ),
                alignment: Alignment.center,
                child: Icon(icon, size: 15, color: AppColors.primary),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  style: AppTextStyles.bodySmall.copyWith(
                    fontFamily: 'Poppins',
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
          const SizedBox(height: 12),
          child,
          if (helper != null) ...[
            const SizedBox(height: 8),
            Text(
              helper!,
              style: AppTextStyles.bodySmall.copyWith(
                fontSize: 11.5,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _CompteurBadge extends StatelessWidget {
  const _CompteurBadge({required this.valeur});
  final String valeur;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.surfaceSoft,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        valeur,
        style: AppTextStyles.bodySmall.copyWith(
          fontFamily: 'Poppins',
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}

// ─── INPUT NUMÉRIQUE premium : valeur grosse + unité fine ──────────

class _ChampNumeriquePremium extends StatelessWidget {
  const _ChampNumeriquePremium({
    required this.controller,
    required this.unit,
    this.keyboardType,
    this.formatters,
  });

  final TextEditingController controller;
  final String unit;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? formatters;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: AppColors.surfaceSoft,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: keyboardType,
              inputFormatters: formatters,
              cursorColor: AppColors.primary,
              style: AppTextStyles.titleLarge.copyWith(
                fontFamily: 'Poppins',
                fontSize: 22,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
                color: AppColors.text,
              ),
              decoration: const InputDecoration(
                border: InputBorder.none,
                focusedBorder: InputBorder.none,
                enabledBorder: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 14),
                isDense: true,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            unit,
            style: AppTextStyles.bodyMedium.copyWith(
              fontFamily: 'Poppins',
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── TOTAL HERO : carte verte avec gros chiffre + delta ─────────────

class _CarteTotalHero extends StatelessWidget {
  const _CarteTotalHero({required this.total, required this.diffPctVsMax});

  final double total;
  final double diffPctVsMax;

  @override
  Widget build(BuildContext context) {
    // Delta vs max acheteur : négatif = bon (sous le max → compétitif).
    // Positif = au-dessus → ambre warning.
    final isCompetitif = diffPctVsMax <= 0;
    final Color deltaColor = isCompetitif
        ? Colors.white.withValues(alpha: 0.95)
        : const Color(0xFFFEF3C7);
    final String deltaLabel = total > 0
        ? (isCompetitif
              ? '${diffPctVsMax.abs().toStringAsFixed(0)} % sous le max'
              : '+${diffPctVsMax.toStringAsFixed(0)} % au-dessus du max')
        : '';

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.primaryHover],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.28),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(
                Icons.calculate_outlined,
                size: 16,
                color: Colors.white,
              ),
              const SizedBox(width: 8),
              Text(
                'TOTAL ESTIMÉ',
                style: AppTextStyles.bodySmall.copyWith(
                  fontFamily: 'Poppins',
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.0,
                  color: Colors.white.withValues(alpha: 0.85),
                ),
              ),
              const Spacer(),
              if (deltaLabel.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    deltaLabel,
                    style: AppTextStyles.bodySmall.copyWith(
                      fontFamily: 'Poppins',
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.3,
                      color: deltaColor,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${_fmt(total)} F',
            style: AppTextStyles.displayLarge.copyWith(
              fontFamily: 'Poppins',
              fontSize: 30,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.8,
              color: Colors.white,
              height: 1.05,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Quantité × prix proposé',
            style: AppTextStyles.bodySmall.copyWith(
              fontSize: 11.5,
              color: Colors.white.withValues(alpha: 0.75),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── CHAMP MESSAGE multilignes premium ─────────────────────────────

class _ChampMessagePremium extends StatelessWidget {
  const _ChampMessagePremium({required this.controller});
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceSoft,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      child: TextField(
        controller: controller,
        maxLines: 4,
        minLines: 3,
        cursorColor: AppColors.primary,
        style: AppTextStyles.bodyMedium.copyWith(
          fontSize: 13.5,
          color: AppColors.text,
          height: 1.4,
        ),
        decoration: InputDecoration(
          border: InputBorder.none,
          focusedBorder: InputBorder.none,
          enabledBorder: InputBorder.none,
          hintText: 'Précisions sur la qualité, le calibre, la disponibilité…',
          hintStyle: AppTextStyles.bodyMedium.copyWith(
            fontSize: 13,
            color: AppColors.textSubtle,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 10),
          isDense: true,
        ),
      ),
    );
  }
}

// ─── Grille photos premium : 3 slots fixes + 2 actions chips ────────

class _GrillePhotosPremium extends StatelessWidget {
  const _GrillePhotosPremium({
    required this.photos,
    required this.onAjouter,
    required this.onGalerie,
    required this.onSupprimer,
  });

  final List<XFile> photos;
  final VoidCallback onAjouter;
  final VoidCallback onGalerie;
  final ValueChanged<int> onSupprimer;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Grille 3 slots fixes — chacun à largeur égale.
        Row(
          children: [
            for (var i = 0; i < 3; i++) ...[
              if (i > 0) const SizedBox(width: 8),
              Expanded(
                child: AspectRatio(
                  aspectRatio: 1,
                  child: i < photos.length
                      ? _VignettePremium(
                          file: File(photos[i].path),
                          onSupprimer: () => onSupprimer(i),
                        )
                      : _SlotFantome(
                          onTap: i == photos.length ? onAjouter : null,
                        ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 12),
        // 2 actions chips : Appareil photo + Galerie
        Row(
          children: [
            Expanded(
              child: _PhotoActionChip(
                icone: Icons.camera_alt_outlined,
                label: 'Appareil photo',
                onTap: photos.length >= 3 ? null : onAjouter,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _PhotoActionChip(
                icone: Icons.photo_library_outlined,
                label: 'Galerie',
                onTap: photos.length >= 3 ? null : onGalerie,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _SlotFantome extends StatelessWidget {
  const _SlotFantome({this.onTap});
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final actif = onTap != null;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: actif
              ? AppColors.primary.withValues(alpha: 0.06)
              : AppColors.surfaceSoft,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: actif
                ? AppColors.primary.withValues(alpha: 0.35)
                : AppColors.border,
          ),
        ),
        alignment: Alignment.center,
        child: Icon(
          actif ? Icons.add_rounded : Icons.image_outlined,
          size: 26,
          color: actif ? AppColors.primary : AppColors.textSubtle,
        ),
      ),
    );
  }
}

class _VignettePremium extends StatelessWidget {
  const _VignettePremium({required this.file, required this.onSupprimer});
  final File file;
  final VoidCallback onSupprimer;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.file(
            file,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => Container(
              color: AppColors.surfaceSoft,
              alignment: Alignment.center,
              child: const Icon(
                Icons.broken_image_outlined,
                size: 22,
                color: AppColors.textSubtle,
              ),
            ),
          ),
        ),
        Positioned(
          top: 6,
          right: 6,
          child: GestureDetector(
            onTap: onSupprimer,
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.65),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.close_rounded,
                size: 15,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _PhotoActionChip extends StatelessWidget {
  const _PhotoActionChip({
    required this.icone,
    required this.label,
    required this.onTap,
  });

  final IconData icone;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final actif = onTap != null;
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          height: 42,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: actif ? AppColors.primary : AppColors.border,
              width: actif ? 1.3 : 1,
            ),
          ),
          alignment: Alignment.center,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icone,
                size: 16,
                color: actif ? AppColors.primary : AppColors.textSubtle,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: actif ? AppColors.primary : AppColors.textSubtle,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Champ date (tap-target → CupertinoDatePicker) ──────────────────

class _ChampDate extends StatelessWidget {
  const _ChampDate({
    required this.date,
    required this.onTap,
    required this.onClear,
  });

  final DateTime? date;
  final VoidCallback onTap;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final hasDate = date != null;
    final label = hasDate
        ? DateFormat('EEEE d MMMM y', 'fr_FR').format(date!)
        : 'Choisir une date';

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 52,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: hasDate
                  ? AppColors.primary.withValues(alpha: 0.35)
                  : AppColors.borderStrong,
              width: hasDate ? 1.3 : 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.event_outlined,
                size: 18,
                color: hasDate ? AppColors.primary : AppColors.textSecondary,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  // Première lettre en majuscule pour le format français.
                  label.isEmpty ? label : _capitalize(label),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontSize: 14,
                    fontWeight: hasDate ? FontWeight.w700 : FontWeight.w500,
                    color: hasDate ? AppColors.text : AppColors.textSecondary,
                  ),
                ),
              ),
              if (hasDate)
                InkWell(
                  onTap: onClear,
                  borderRadius: BorderRadius.circular(20),
                  child: const Padding(
                    padding: EdgeInsets.all(4),
                    child: Icon(
                      Icons.close_rounded,
                      size: 18,
                      color: AppColors.textSubtle,
                    ),
                  ),
                )
              else
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

  String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}

// ─── Helpers ──────────────────────────────────────────────────────

String _fmt(double v) => NumberFormat('#,##0', 'fr_FR').format(v.round());
