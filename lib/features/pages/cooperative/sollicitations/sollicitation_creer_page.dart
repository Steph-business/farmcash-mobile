import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../api_client/api_exception.dart';
import '../../../../services/providers.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';
import '../../../widgets/communs/snackbars.dart';

// ─── Couleurs accent ─────────────────────────────────────────────────────

const Color _kPrimarySoft = Color(0xFFE8F5E9);
const Color _kOrange = Color(0xFFE65100);

const String _kBuyerAvatar =
    'https://images.unsplash.com/photo-1560250097-0b93528c311a?w=120&h=120&fit=crop&auto=format';

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
            const _Header(),
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
                  _GroupTitle(title: 'Offre cliente à couvrir'),
                  AppDimens.vGap12,
                  const _BuyerCard(),
                  AppDimens.vGap24,

                  // ── Besoin à combler ─────────────────────────────
                  _GroupTitle(title: 'Besoin à combler'),
                  AppDimens.vGap12,
                  const _NeedCard(),
                  AppDimens.vGap24,

                  // ── Qui solliciter ? ──────────────────────────────
                  _GroupTitle(title: 'Qui solliciter ?'),
                  AppDimens.vGap12,
                  _AudienceChip(
                    title: 'Mes membres',
                    subtitle: 'Farmers affiliés à la coop',
                    count: '($_kCountMembres farmers)',
                    selected: _audiences.contains(_kAudMembres),
                    onTap: () => _toggleAudience(_kAudMembres),
                  ),
                  AppDimens.vGap8,
                  _AudienceChip(
                    title: 'Autres coopératives de la région',
                    subtitle: 'Coops partenaires',
                    count: '($_kCountCoops coops)',
                    selected: _audiences.contains(_kAudCoops),
                    onTap: () => _toggleAudience(_kAudCoops),
                  ),
                  AppDimens.vGap8,
                  _AudienceChip(
                    title: 'Producteurs indépendants',
                    subtitle: 'Non affiliés, zone Lagunes',
                    count: '(~$_kCountIndep dans la zone)',
                    selected: _audiences.contains(_kAudIndep),
                    onTap: () => _toggleAudience(_kAudIndep),
                  ),
                  AppDimens.vGap24,

                  // ── Conditions de l'appel ─────────────────────────
                  _GroupTitle(title: "Conditions de l'appel"),
                  AppDimens.vGap12,

                  _FieldLabel(label: 'Prix minimum offert'),
                  AppDimens.vGap8,
                  _InputUnit(
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

                  _FieldLabel(label: 'Date limite de réponse'),
                  AppDimens.vGap8,
                  _DateInput(
                    date: _dateLimite,
                    onTap: _choisirDate,
                  ),
                  AppDimens.vGap16,

                  _FieldLabel(label: 'Engagements à venir'),
                  AppDimens.vGap8,
                  _ToggleRow(
                    title: 'Permettre les engagements à venir',
                    help:
                        'Les fournisseurs peuvent répondre « Je fournirai dans X jours »',
                    value: _engagementsAvenir,
                    onChanged: (v) =>
                        setState(() => _engagementsAvenir = v),
                  ),
                  AppDimens.vGap24,

                  // ── Message à joindre ────────────────────────────
                  _GroupTitle(title: 'Message à joindre (optionnel)'),
                  AppDimens.vGap12,
                  _MessageField(controller: _messageCtrl),
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
            _Sticky(
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

// ─── Header ──────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppDimens.space16,
        AppDimens.space8,
        AppDimens.space16,
        AppDimens.space12,
      ),
      child: Row(
        children: [
          InkWell(
            onTap: () => Navigator.of(context).pop(),
            borderRadius: BorderRadius.circular(20),
            child: const SizedBox(
              width: 40,
              height: 40,
              child: Icon(
                Icons.arrow_back_ios_new,
                size: 20,
                color: AppColors.text,
              ),
            ),
          ),
          Expanded(
            child: Text(
              'Solliciter des fournisseurs',
              style: AppTextStyles.titleSmall.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Section titles ──────────────────────────────────────────────────────

class _GroupTitle extends StatelessWidget {
  const _GroupTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: AppTextStyles.titleSmall.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: AppColors.text,
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: AppTextStyles.labelSmall.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: AppColors.textSecondary,
      ),
    );
  }
}

// ─── Buyer card (primary-soft, read-only, acheteur ANONYMISÉ) ───────────

class _BuyerCard extends StatelessWidget {
  const _BuyerCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _kPrimarySoft,
        borderRadius: BorderRadius.circular(AppDimens.radiusCard),
        border: Border.all(
          color: _kPrimarySoft,
          width: AppDimens.borderThin,
        ),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ClipOval(
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceSoft,
                    border: Border.all(
                      color: AppColors.border,
                      width: AppDimens.borderThin,
                    ),
                    shape: BoxShape.circle,
                  ),
                  clipBehavior: Clip.hardEdge,
                  child: CachedNetworkImage(
                    imageUrl: _kBuyerAvatar,
                    fit: BoxFit.cover,
                    placeholder: (_, _) =>
                        Container(color: AppColors.surfaceSoft),
                    errorWidget: (_, _, _) =>
                        Container(color: AppColors.surfaceSoft),
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
                      // Acheteur anonymisé : "Industries A." (anti-contournement)
                      'Industries A.',
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Coop ciblée',
                      style: AppTextStyles.labelSmall.copyWith(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Manioc · 5 tonnes · max 380 F/kg',
            style: AppTextStyles.titleLarge.copyWith(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Livraison souhaitée : 25 juin',
            style: AppTextStyles.bodySmall.copyWith(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Need card (stock coop vs manque) ────────────────────────────────────

class _NeedCard extends StatelessWidget {
  const _NeedCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppDimens.radiusCard),
        border: Border.all(
          color: AppColors.border,
          width: AppDimens.borderThin,
        ),
      ),
      child: Column(
        children: [
          _NeedLine(
            label: 'Stock coop actuel',
            value: '2 000 kg',
            ok: true,
            isLast: false,
          ),
          _NeedLine(
            label: 'Manque à compléter',
            value: '3 000 kg',
            ok: false,
            isLast: true,
          ),
        ],
      ),
    );
  }
}

class _NeedLine extends StatelessWidget {
  const _NeedLine({
    required this.label,
    required this.value,
    required this.ok,
    required this.isLast,
  });

  final String label;
  final String value;
  final bool ok;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : const Border(
                bottom: BorderSide(
                  color: AppColors.border,
                  width: AppDimens.borderThin,
                ),
              ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.bodyMedium.copyWith(
                fontSize: 13,
                color: AppColors.text,
              ),
            ),
          ),
          Text(
            value,
            style: AppTextStyles.titleLarge.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: ok ? AppColors.primary : _kOrange,
              decoration: ok ? null : TextDecoration.underline,
              decorationColor: _kOrange,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Audience chip (toggle, carré 12 radius) ─────────────────────────────

class _AudienceChip extends StatelessWidget {
  const _AudienceChip({
    required this.title,
    required this.subtitle,
    required this.count,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final String count;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimens.radiusCard),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected ? _kPrimarySoft : AppColors.background,
          borderRadius: BorderRadius.circular(AppDimens.radiusCard),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
            width: AppDimens.borderThin,
          ),
        ),
        child: Row(
          children: [
            // Checkbox carrée
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: selected ? AppColors.primary : AppColors.background,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: selected
                      ? AppColors.primary
                      : AppColors.borderStrong,
                  width: AppDimens.borderThin,
                ),
              ),
              child: selected
                  ? const Icon(
                      Icons.check,
                      size: 14,
                      color: Colors.white,
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppTextStyles.bodySmall.copyWith(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              count,
              style: AppTextStyles.titleLarge.copyWith(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: selected ? AppColors.primary : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Input avec unité ────────────────────────────────────────────────────

class _InputUnit extends StatelessWidget {
  const _InputUnit({
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
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppDimens.radiusCard),
        border: Border.all(
          color: AppColors.border,
          width: AppDimens.borderThin,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: keyboardType,
              inputFormatters: formatters,
              style: AppTextStyles.bodyMedium.copyWith(
                fontSize: 14,
                color: AppColors.text,
              ),
              decoration: const InputDecoration(
                border: InputBorder.none,
                focusedBorder: InputBorder.none,
                enabledBorder: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 12),
                isDense: true,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            unit,
            style: AppTextStyles.bodyMedium.copyWith(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Date input (read-only, ouvre picker) ────────────────────────────────

class _DateInput extends StatelessWidget {
  const _DateInput({required this.date, required this.onTap});

  final DateTime date;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimens.radiusCard),
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(AppDimens.radiusCard),
          border: Border.all(
            color: AppColors.border,
            width: AppDimens.borderThin,
          ),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.calendar_today_outlined,
              size: 16,
              color: AppColors.textSecondary,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                DateFormat('d MMMM yyyy', 'fr_FR').format(date),
                style: AppTextStyles.bodyMedium.copyWith(
                  fontSize: 14,
                  color: AppColors.text,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Toggle row ──────────────────────────────────────────────────────────

class _ToggleRow extends StatelessWidget {
  const _ToggleRow({
    required this.title,
    required this.help,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final String help;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppDimens.radiusCard),
        border: Border.all(
          color: AppColors.border,
          width: AppDimens.borderThin,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  help,
                  style: AppTextStyles.bodySmall.copyWith(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeThumbColor: Colors.white,
            activeTrackColor: AppColors.primary,
          ),
        ],
      ),
    );
  }
}

// ─── Message field (textarea 3 lignes) ───────────────────────────────────

class _MessageField extends StatelessWidget {
  const _MessageField({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppDimens.radiusCard),
        border: Border.all(
          color: AppColors.border,
          width: AppDimens.borderThin,
        ),
      ),
      child: TextField(
        controller: controller,
        minLines: 3,
        maxLines: 5,
        textCapitalization: TextCapitalization.sentences,
        style: AppTextStyles.bodyMedium.copyWith(
          fontSize: 13,
          color: AppColors.text,
        ),
        decoration: InputDecoration(
          hintText:
              'Détails sur la qualité attendue, lieu de livraison…',
          hintStyle: AppTextStyles.bodyMedium.copyWith(
            fontSize: 13,
            color: AppColors.textSubtle,
          ),
          border: InputBorder.none,
          focusedBorder: InputBorder.none,
          enabledBorder: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        ),
      ),
    );
  }
}

// ─── Sticky bouton plein ─────────────────────────────────────────────────

class _Sticky extends StatelessWidget {
  const _Sticky({
    required this.count,
    required this.isSubmitting,
    required this.onTap,
  });

  final int count;
  final bool isSubmitting;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(
          top: BorderSide(
            color: AppColors.border,
            width: AppDimens.borderThin,
          ),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(24, 14, 24, 12),
      child: SizedBox(
        width: double.infinity,
        child: InkWell(
          onTap: (isSubmitting || count == 0) ? null : onTap,
          borderRadius: BorderRadius.circular(AppDimens.radiusCard),
          child: Opacity(
            opacity: count == 0 ? 0.6 : 1,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(AppDimens.radiusCard),
                border: Border.all(
                  color: AppColors.primary,
                  width: AppDimens.borderThin,
                ),
              ),
              alignment: Alignment.center,
              child: isSubmitting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      'Envoyer la sollicitation ($count destinataires)',
                      style: AppTextStyles.button.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

