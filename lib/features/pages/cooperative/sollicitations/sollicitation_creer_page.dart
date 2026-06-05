import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../api_client/api_exception.dart';
import '../../../../models/annonce_achat.dart';
import '../../../../services/providers.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';
import '../../../widgets/communs/snackbars.dart';
import '../../../widgets/cooperative/sollicitations/audience_chip_creer_sollicitation_coop.dart';
import '../../../widgets/cooperative/sollicitations/buyer_card_creer_sollicitation_coop.dart';
import '../../../widgets/cooperative/sollicitations/date_input_creer_sollicitation_coop.dart';
import '../../../widgets/cooperative/sollicitations/field_label_creer_sollicitation_coop.dart';
import '../../../widgets/cooperative/sollicitations/group_title_creer_sollicitation_coop.dart';
import '../../../widgets/cooperative/sollicitations/header_creer_sollicitation_coop.dart';
import '../../../widgets/cooperative/sollicitations/input_unit_creer_sollicitation_coop.dart';
import '../../../widgets/cooperative/sollicitations/message_field_creer_sollicitation_coop.dart';
import '../../../widgets/cooperative/sollicitations/need_card_creer_sollicitation_coop.dart';
import '../../../widgets/cooperative/sollicitations/sticky_creer_sollicitation_coop.dart';
import '../../../widgets/cooperative/sollicitations/toggle_row_creer_sollicitation_coop.dart';

/// Compteurs estimatifs pour les audiences géo (COOPS_VOISINES,
/// INDEPENDANTS). Le backend les détermine au moment du fan-out via
/// `rayon_km` + zone — on ne peut pas connaître le chiffre exact avant
/// envoi. Ces estimations sont affichées avec « ≈ » pour être honnête.
/// TODO(coop-sollicitation) : exposer un endpoint
/// `GET /coop/sollicitations/audience-counts?annonce_id=...` pour avoir
/// les vrais chiffres en pré-affichage.
const int _kEstimateCoops = 12;
const int _kEstimateIndep = 85;

/// Codes d'audience attendus par le backend
/// (`cooperativesService.createSollicitation`).
const String _kAudMembres = 'MEMBRES';
const String _kAudCoops = 'COOPS_VOISINES';
const String _kAudIndep = 'INDEPENDANTS';

/// Bundle des données contextuelles fetchées au montage : offre source
/// (si `offreId` fourni) + nombre réel de membres coop. Audiences géo
/// restent en estimatif (cf. TODO ci-dessus).
class _SollicitationContext {
  const _SollicitationContext({this.annonce, required this.nbMembres});
  final AnnonceAchat? annonce;
  final int nbMembres;
}

/// Provider familial (clé = offreId nullable). Charge en parallèle :
///   - l'annonce d'achat source si offreId présent
///   - le nombre total de membres coop (toujours)
final _contexteProvider = FutureProvider.autoDispose
    .family<_SollicitationContext, String?>((ref, offreId) async {
  final coopSvc = ref.read(cooperativesServiceProvider);
  final marketSvc = ref.read(marketplaceServiceProvider);

  final results = await Future.wait<dynamic>([
    coopSvc.listMembers(limit: 1).then<Object?>((v) => v).catchError(
          (Object _) => null,
        ),
    if (offreId != null && offreId.isNotEmpty)
      marketSvc.getAnnonceAchat(offreId).then<Object?>((v) => v).catchError(
            (Object _) => null,
          )
    else
      Future<Object?>.value(null),
  ]);

  final membersPage = results[0];
  // `Paginated<MembreCoop>` expose `total` (entier).
  final int nbMembres = membersPage == null
      ? 0
      : (membersPage as dynamic).total as int;
  final annonce = results[1] as AnnonceAchat?;
  return _SollicitationContext(annonce: annonce, nbMembres: nbMembres);
});

/// Création d'une sollicitation multi-audience par la coop.
///
/// Maquette : `mockups/cooperative/sollicitation_creer.html`. Permet à la
/// coop de fan-out une offre acheteur vers ses membres / coops voisines /
/// indépendants. L'offre cliente à couvrir est affichée en read-only ;
/// le manque à compléter est calculé côté affichage (mock).
class SollicitationCreerPage extends ConsumerStatefulWidget {
  const SollicitationCreerPage({this.offreId, super.key});

  /// Id de l'offre acheteur à couvrir (optionnel — page accessible aussi
  /// depuis le FAB coop sans contexte d'offre précis).
  final String? offreId;

  @override
  ConsumerState<SollicitationCreerPage> createState() =>
      _SollicitationCreerPageState();
}

class _SollicitationCreerPageState
    extends ConsumerState<SollicitationCreerPage> {
  // Audiences cochées (multi-select). Par défaut : membres.
  final Set<String> _audiences = {_kAudMembres};

  // Conditions — prix pré-rempli à la première donnée disponible (offre
  // source) via `didUpdateContext`. Date limite défaut : J+7.
  final _prixCtrl = TextEditingController();
  DateTime _dateLimite = DateTime.now().add(const Duration(days: 7));
  bool _engagementsAvenir = false;

  // Message optionnel
  final _messageCtrl = TextEditingController();

  bool _isSubmitting = false;

  /// Empêche de pré-remplir le prix plusieurs fois (si le user a touché
  /// le champ, on respecte sa valeur même si l'offre est rechargée).
  bool _prixUserTouched = false;

  @override
  void initState() {
    super.initState();
    _prixCtrl.addListener(() {
      if (_prixCtrl.text.isNotEmpty) _prixUserTouched = true;
    });
  }

  @override
  void dispose() {
    _prixCtrl.dispose();
    _messageCtrl.dispose();
    super.dispose();
  }

  /// Pré-remplit le prix avec le prix max accepté de l'offre acheteur,
  /// sauf si l'utilisateur a déjà tapé une valeur. Appelé après chaque
  /// résolution du provider contexte.
  void _prefillPrixFromOffre(AnnonceAchat annonce) {
    if (_prixUserTouched) return;
    final p = annonce.prixMaxKg;
    if (p > 0 && _prixCtrl.text.isEmpty) {
      // Légèrement sous le max pour donner de la marge à la coop.
      _prixCtrl.text = (p * 0.95).round().toString();
    }
  }

  int _totalRecipients(int nbMembres) {
    var n = 0;
    if (_audiences.contains(_kAudMembres)) n += nbMembres;
    if (_audiences.contains(_kAudCoops)) n += _kEstimateCoops;
    if (_audiences.contains(_kAudIndep)) n += _kEstimateIndep;
    return n;
  }

  void _toggleAudience(String code) {
    setState(() {
      if (_audiences.contains(code)) {
        _audiences.remove(code);
      } else {
        _audiences.add(code);
      }
    });
  }

  Future<void> _choisirDate() async {
    FocusScope.of(context).unfocus();
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _dateLimite,
      firstDate: now,
      lastDate: now.add(const Duration(days: 30)),
      locale: const Locale('fr', 'FR'),
    );
    if (picked != null && mounted) {
      setState(() => _dateLimite = picked);
    }
  }

  Future<void> _envoyer() async {
    if (_isSubmitting) return;
    if (_audiences.isEmpty) {
      Snackbars.showErreur(context, 'Sélectionne au moins une audience.');
      return;
    }
    // Le backend exige un annonce_achat_id réel pour rattacher la
    // sollicitation à une commande à couvrir. Sans `offreId`, on refuse
    // au lieu de mentir à l'utilisateur.
    final offreId = widget.offreId;
    if (offreId == null || offreId.isEmpty) {
      Snackbars.showErreur(
        context,
        'Ouvre une offre d\'achat depuis « Offres reçues » pour la solliciter.',
      );
      return;
    }

    // Dérive `dureeJours` depuis `_dateLimite` (clamp 1..30 pour rester
    // dans la fenêtre acceptée par le backend DTO).
    final delta = _dateLimite.difference(DateTime.now()).inDays;
    final dureeJours = delta < 1 ? 1 : (delta > 30 ? 30 : delta);

    // Parse le prix min — vide ou 0 = pas de prix imposé.
    final prixTexte = _prixCtrl.text.trim();
    final prixMinKg = double.tryParse(prixTexte);

    setState(() => _isSubmitting = true);
    try {
      await ref.read(cooperativesServiceProvider).createSollicitation(
            annonceAchatId: offreId,
            message: _messageCtrl.text.trim().isEmpty
                ? 'Sollicitation coop pour couvrir une offre acheteur'
                : _messageCtrl.text.trim(),
            audiences: _audiences.toList(),
            dureeJours: dureeJours,
            prixMinKg: (prixMinKg != null && prixMinKg > 0) ? prixMinKg : null,
            permetEngagementsAVenir: _engagementsAvenir,
          );
      if (!mounted) return;
      Snackbars.showSucces(context, 'Sollicitation envoyée.');
      Navigator.of(context).pop(true);
    } on ApiException catch (e) {
      if (mounted) Snackbars.showErreur(context, e.message);
    } catch (e) {
      if (mounted) Snackbars.showErreur(context, 'Erreur : $e');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Fetch contexte (offre source + nb membres réel). Tolérant aux
    // erreurs : chaque appel retombe sur null/0 si le backend échoue.
    final contexteAsync = ref.watch(_contexteProvider(widget.offreId));
    final contexte = contexteAsync.valueOrNull;
    final annonce = contexte?.annonce;
    final nbMembres = contexte?.nbMembres ?? 0;

    // Pré-remplissage prix au premier rendu où l'offre est dispo. On le
    // fait dans le build (idempotent grâce au flag `_prixUserTouched`).
    if (annonce != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _prefillPrixFromOffre(annonce);
      });
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const HeaderCreerSollicitationCoop(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppDimens.pagePaddingH,
                  0,
                  AppDimens.pagePaddingH,
                  AppDimens.space16,
                ),
                children: [
                  // ── Offre cliente à couvrir ───────────────────────
                  const GroupTitleCreerSollicitationCoop(
                    title: 'Offre cliente à couvrir',
                  ),
                  AppDimens.vGap12,
                  BuyerCardCreerSollicitationCoop(
                    buyerNom: annonce?.buyerNom,
                    buyerPhotoUrl: annonce?.buyer?.photoUrl,
                    produitNom: annonce?.produitLabel,
                    quantiteKg: annonce?.quantiteKg,
                    prixMaxKg: annonce?.prixMaxKg,
                    dateLimiteLivraison: annonce?.dateLimiteLivraison,
                  ),
                  AppDimens.vGap24,

                  // ── Besoin à combler ─────────────────────────────
                  // Stock coop pas encore connecté à un endpoint dédié
                  // (TODO : `GET /coop/stock/total?produit_id=...`).
                  // Pour V1, on ne montre que la quantité demandée.
                  const GroupTitleCreerSollicitationCoop(
                    title: 'Besoin à combler',
                  ),
                  AppDimens.vGap12,
                  NeedCardCreerSollicitationCoop(
                    stockKg: null,
                    quantiteDemandeeKg: annonce?.quantiteKg,
                  ),
                  AppDimens.vGap24,

                  // ── Qui solliciter ? ──────────────────────────────
                  const GroupTitleCreerSollicitationCoop(
                    title: 'Qui solliciter ?',
                  ),
                  AppDimens.vGap12,
                  AudienceChipCreerSollicitationCoop(
                    title: 'Mes membres',
                    subtitle: 'Farmers affiliés à la coop',
                    count: '($nbMembres farmer${nbMembres > 1 ? "s" : ""})',
                    selected: _audiences.contains(_kAudMembres),
                    onTap: () => _toggleAudience(_kAudMembres),
                  ),
                  AppDimens.vGap8,
                  AudienceChipCreerSollicitationCoop(
                    title: 'Autres coopératives de la région',
                    subtitle: 'Coops partenaires',
                    count: '(≈ $_kEstimateCoops coops)',
                    selected: _audiences.contains(_kAudCoops),
                    onTap: () => _toggleAudience(_kAudCoops),
                  ),
                  AppDimens.vGap8,
                  AudienceChipCreerSollicitationCoop(
                    title: 'Producteurs indépendants',
                    subtitle: 'Non affiliés, zone Lagunes',
                    count: '(≈ $_kEstimateIndep dans la zone)',
                    selected: _audiences.contains(_kAudIndep),
                    onTap: () => _toggleAudience(_kAudIndep),
                  ),
                  AppDimens.vGap24,

                  // ── Conditions de l'appel ─────────────────────────
                  const GroupTitleCreerSollicitationCoop(
                    title: "Conditions de l'appel",
                  ),
                  AppDimens.vGap12,

                  const FieldLabelCreerSollicitationCoop(
                    label: 'Prix minimum offert',
                  ),
                  AppDimens.vGap8,
                  InputUnitCreerSollicitationCoop(
                    controller: _prixCtrl,
                    unit: 'F/kg',
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: false,
                    ),
                    formatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                    ],
                  ),
                  AppDimens.vGap16,

                  const FieldLabelCreerSollicitationCoop(
                    label: 'Date limite de réponse',
                  ),
                  AppDimens.vGap8,
                  DateInputCreerSollicitationCoop(
                    date: _dateLimite,
                    onTap: _choisirDate,
                  ),
                  AppDimens.vGap16,

                  const FieldLabelCreerSollicitationCoop(
                    label: 'Engagements à venir',
                  ),
                  AppDimens.vGap8,
                  ToggleRowCreerSollicitationCoop(
                    title: 'Permettre les engagements à venir',
                    help:
                        'Les fournisseurs peuvent répondre « Je fournirai dans X jours »',
                    value: _engagementsAvenir,
                    onChanged: (v) =>
                        setState(() => _engagementsAvenir = v),
                  ),
                  AppDimens.vGap24,

                  // ── Message à joindre ────────────────────────────
                  const GroupTitleCreerSollicitationCoop(
                    title: 'Message à joindre (optionnel)',
                  ),
                  AppDimens.vGap12,
                  MessageFieldCreerSollicitationCoop(
                    controller: _messageCtrl,
                  ),
                  AppDimens.vGap8,
                  Text(
                    'Visible par tous les destinataires sélectionnés.',
                    style: AppTextStyles.bodySmall.copyWith(
                      fontSize: 11,
                      color: AppColors.textSubtle,
                    ),
                  ),
                ],
              ),
            ),
            StickyCreerSollicitationCoop(
              count: _totalRecipients(nbMembres),
              isSubmitting: _isSubmitting,
              onTap: _envoyer,
            ),
          ],
        ),
      ),
    );
  }
}
