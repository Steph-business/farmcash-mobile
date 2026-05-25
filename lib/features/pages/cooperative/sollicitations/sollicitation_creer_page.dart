import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../api_client/api_exception.dart';
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

/// Compteurs mock pour chaque audience (affichés à droite des chips
/// toggleables et utilisés pour le compteur dynamique du bouton).
const int _kCountMembres = 47;
const int _kCountCoops = 12;
const int _kCountIndep = 85;

/// Codes d'audience attendus par le backend
/// (`cooperativesService.createSollicitation`).
const String _kAudMembres = 'MEMBRES';
const String _kAudCoops = 'COOPS_VOISINES';
const String _kAudIndep = 'INDEPENDANTS';

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

  // Conditions
  final _prixCtrl = TextEditingController(text: '380');
  DateTime _dateLimite = DateTime(2026, 6, 22);
  bool _engagementsAvenir = true;

  // Message optionnel
  final _messageCtrl = TextEditingController();

  bool _isSubmitting = false;

  @override
  void dispose() {
    _prixCtrl.dispose();
    _messageCtrl.dispose();
    super.dispose();
  }

  int get _totalRecipients {
    var n = 0;
    if (_audiences.contains(_kAudMembres)) n += _kCountMembres;
    if (_audiences.contains(_kAudCoops)) n += _kCountCoops;
    if (_audiences.contains(_kAudIndep)) n += _kCountIndep;
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
      lastDate: now.add(const Duration(days: 365)),
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
    setState(() => _isSubmitting = true);
    try {
      await ref.read(cooperativesServiceProvider).createSollicitation(
            annonceAchatId: offreId,
            message: _messageCtrl.text.trim().isEmpty
                ? 'Sollicitation coop pour couvrir une offre acheteur'
                : _messageCtrl.text.trim(),
            audiences: _audiences.toList(),
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
                  const BuyerCardCreerSollicitationCoop(),
                  AppDimens.vGap24,

                  // ── Besoin à combler ─────────────────────────────
                  const GroupTitleCreerSollicitationCoop(
                    title: 'Besoin à combler',
                  ),
                  AppDimens.vGap12,
                  const NeedCardCreerSollicitationCoop(),
                  AppDimens.vGap24,

                  // ── Qui solliciter ? ──────────────────────────────
                  const GroupTitleCreerSollicitationCoop(
                    title: 'Qui solliciter ?',
                  ),
                  AppDimens.vGap12,
                  AudienceChipCreerSollicitationCoop(
                    title: 'Mes membres',
                    subtitle: 'Farmers affiliés à la coop',
                    count: '($_kCountMembres farmers)',
                    selected: _audiences.contains(_kAudMembres),
                    onTap: () => _toggleAudience(_kAudMembres),
                  ),
                  AppDimens.vGap8,
                  AudienceChipCreerSollicitationCoop(
                    title: 'Autres coopératives de la région',
                    subtitle: 'Coops partenaires',
                    count: '($_kCountCoops coops)',
                    selected: _audiences.contains(_kAudCoops),
                    onTap: () => _toggleAudience(_kAudCoops),
                  ),
                  AppDimens.vGap8,
                  AudienceChipCreerSollicitationCoop(
                    title: 'Producteurs indépendants',
                    subtitle: 'Non affiliés, zone Lagunes',
                    count: '(~$_kCountIndep dans la zone)',
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
              count: _totalRecipients,
              isSubmitting: _isSubmitting,
              onTap: _envoyer,
            ),
          ],
        ),
      ),
    );
  }
}
