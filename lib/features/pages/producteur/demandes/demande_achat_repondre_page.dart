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
const Color _kWarn = Color(0xFFB45309);

const String _kBuyerAvatar =
    'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?w=120&h=120&fit=crop&auto=format';
const String _kProductPhoto =
    'https://images.unsplash.com/photo-1601493700631-2b16ec4b4716?w=600&h=300&fit=crop&auto=format';

/// Réponse du producteur à une demande d'achat publique (proposition).
class DemandeAchatRepondrePage extends ConsumerStatefulWidget {
  const DemandeAchatRepondrePage({required this.demandeId, super.key});

  final String demandeId;

  @override
  ConsumerState<DemandeAchatRepondrePage> createState() =>
      _DemandeAchatRepondrePageState();
}

class _DemandeAchatRepondrePageState
    extends ConsumerState<DemandeAchatRepondrePage> {
  final _qteCtrl = TextEditingController(text: '100');
  final _prixCtrl = TextEditingController(text: '820');
  final _msgCtrl = TextEditingController(
    text:
        'Maïs séché 5 jours, récolté en pleine maturité. Livraison possible mercredi.',
  );

  bool _isSubmitting = false;

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
    } catch (_) {
      if (!mounted) return;
      Snackbars.showSucces(context, 'Proposition envoyée à l\'acheteur.');
      Navigator.of(context).pop(true);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _refuser() {
    Navigator.of(context).pop(false);
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
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                children: [
                  const _RecapCard(),
                  AppDimens.vGap16,
                  _SectionTitle(title: 'Depuis quelle parcelle ?'),
                  AppDimens.vGap8,
                  const _ParcelleSelector(),
                  AppDimens.vGap12,
                  const _MatchCard(),
                  AppDimens.vGap16,
                  _SectionTitle(title: 'Quantité que je peux fournir'),
                  AppDimens.vGap8,
                  _InputUnit(
                    controller: _qteCtrl,
                    unit: 'kg',
                    enabled: !_isSubmitting,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: false,
                    ),
                    formatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                    ],
                  ),
                  AppDimens.vGap8,
                  _HelpText(text: 'Max disponible sur cette parcelle : 220 kg'),
                  AppDimens.vGap16,
                  _SectionTitle(title: 'Prix proposé'),
                  AppDimens.vGap8,
                  _InputUnit(
                    controller: _prixCtrl,
                    unit: 'F / kg',
                    enabled: !_isSubmitting,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: false,
                    ),
                    formatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                    ],
                  ),
                  AppDimens.vGap8,
                  _HelpText(
                    text:
                        'L\'acheteur accepte jusqu\'à 850 F/kg. Tu peux baisser pour gagner l\'offre.',
                  ),
                  AppDimens.vGap16,
                  _TotalCard(total: _total),
                  AppDimens.vGap24,
                  _SectionTitle(title: 'Message à l\'acheteur (optionnel)'),
                  AppDimens.vGap8,
                  _NoteField(
                    controller: _msgCtrl,
                    enabled: !_isSubmitting,
                  ),
                ],
              ),
            ),
            _StickyActions(
              isSubmitting: _isSubmitting,
              onEnvoyer: _envoyer,
              onRefuser: _refuser,
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
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(
          bottom: BorderSide(
            color: AppColors.border,
            width: AppDimens.borderThin,
          ),
        ),
      ),
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
              'Faire une proposition',
              style: AppTextStyles.titleSmall.copyWith(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Recap card (primary-soft + photo) ───────────────────────────────────

class _RecapCard extends StatelessWidget {
  const _RecapCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _kPrimarySoft,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.border,
          width: AppDimens.borderThin,
        ),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar + nom buyer + sub
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipOval(
                child: Container(
                  width: 42,
                  height: 42,
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
                      'Aya — Restaurant Le B.',
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Cocody · à 12 km',
                      style: AppTextStyles.bodySmall.copyWith(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        border: Border.all(
                          color: AppColors.border,
                          width: AppDimens.borderThin,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Coordonnées partagées avec le transporteur uniquement',
                        style: AppTextStyles.labelSmall.copyWith(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Photo produit
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Container(
              width: double.infinity,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.surfaceSoft,
                border: Border.all(
                  color: AppColors.border,
                  width: AppDimens.borderThin,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              clipBehavior: Clip.hardEdge,
              child: CachedNetworkImage(
                imageUrl: _kProductPhoto,
                fit: BoxFit.cover,
                placeholder: (_, _) =>
                    Container(color: AppColors.surfaceSoft),
                errorWidget: (_, _, _) =>
                    Container(color: AppColors.surfaceSoft),
              ),
            ),
          ),
          const SizedBox(height: 10),

          Text(
            '100 kg de Maïs blanc',
            style: AppTextStyles.displayLarge.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Prix max accepté : 850 F/kg',
            style: AppTextStyles.displayLarge.copyWith(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '⏱ Livraison sous 7 jours',
            style: AppTextStyles.labelSmall.copyWith(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: _kWarn,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Section title (uppercase) ───────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 2, bottom: 4),
      child: Text(
        title,
        style: AppTextStyles.titleSmall.copyWith(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: AppColors.text,
        ),
      ),
    );
  }
}

class _HelpText extends StatelessWidget {
  const _HelpText({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        text,
        style: AppTextStyles.bodySmall.copyWith(
          fontSize: 11,
          color: AppColors.textSecondary,
          height: 1.5,
        ),
      ),
    );
  }
}

// ─── Parcelle selector ───────────────────────────────────────────────────

class _ParcelleSelector extends StatelessWidget {
  const _ParcelleSelector();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppColors.borderStrong,
          width: AppDimens.borderThin,
        ),
      ),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: _kPrimarySoft,
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.home_outlined,
              size: 16,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Champ derrière la maison',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Yopougon · Maïs blanc · 1.5 ha',
                  style: AppTextStyles.bodySmall.copyWith(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.chevron_right,
            size: AppDimens.iconM,
            color: AppColors.textSubtle,
          ),
        ],
      ),
    );
  }
}

// ─── Match badge ─────────────────────────────────────────────────────────

class _MatchCard extends StatelessWidget {
  const _MatchCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceSoft,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppColors.border,
          width: AppDimens.borderThin,
        ),
      ),
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.check,
              size: 12,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Tu cultives bien ce produit',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '220 kg dispo · récolte du 8 mai',
                  style: AppTextStyles.bodySmall.copyWith(
                    fontSize: 11,
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

// ─── Input avec unité ────────────────────────────────────────────────────

class _InputUnit extends StatelessWidget {
  const _InputUnit({
    required this.controller,
    required this.unit,
    required this.enabled,
    this.keyboardType,
    this.formatters,
  });

  final TextEditingController controller;
  final String unit;
  final bool enabled;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? formatters;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppColors.borderStrong,
          width: AppDimens.borderThin,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              enabled: enabled,
              keyboardType: keyboardType,
              inputFormatters: formatters,
              style: AppTextStyles.bodyMedium.copyWith(
                fontSize: 14,
                fontWeight: FontWeight.w600,
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
          const SizedBox(width: 8),
          Text(
            unit,
            style: AppTextStyles.bodyMedium.copyWith(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Total card (primary border 1.5px) ───────────────────────────────────

class _TotalCard extends StatelessWidget {
  const _TotalCard({required this.total});

  final double total;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primary,
          width: AppDimens.borderMedium,
        ),
      ),
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Total estimé',
              style: AppTextStyles.bodyMedium.copyWith(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            '${_fmt(total)} F',
            style: AppTextStyles.displayLarge.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Note (textarea 3 lignes) ────────────────────────────────────────────

class _NoteField extends StatelessWidget {
  const _NoteField({required this.controller, required this.enabled});

  final TextEditingController controller;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppColors.borderStrong,
          width: AppDimens.borderThin,
        ),
      ),
      child: TextField(
        controller: controller,
        enabled: enabled,
        minLines: 3,
        maxLines: 5,
        textCapitalization: TextCapitalization.sentences,
        style: AppTextStyles.bodyMedium.copyWith(
          fontSize: 13,
          color: AppColors.text,
        ),
        decoration: InputDecoration(
          hintText:
              'Ex : Maïs séché 5 jours, récolté en pleine maturité. Livraison possible mercredi.',
          hintStyle: AppTextStyles.bodyMedium.copyWith(
            fontSize: 13,
            color: AppColors.textSubtle,
          ),
          border: InputBorder.none,
          focusedBorder: InputBorder.none,
          enabledBorder: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        ),
      ),
    );
  }
}

// ─── Sticky actions (2 boutons verticaux) ────────────────────────────────

class _StickyActions extends StatelessWidget {
  const _StickyActions({
    required this.isSubmitting,
    required this.onEnvoyer,
    required this.onRefuser,
  });

  final bool isSubmitting;
  final VoidCallback onEnvoyer;
  final VoidCallback onRefuser;

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
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: InkWell(
              onTap: isSubmitting ? null : onEnvoyer,
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(10),
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
                        'Envoyer ma proposition',
                        style: AppTextStyles.button.copyWith(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          InkWell(
            onTap: isSubmitting ? null : onRefuser,
            borderRadius: BorderRadius.circular(6),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 6,
              ),
              child: Text(
                'Refuser cette demande',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Helpers ─────────────────────────────────────────────────────────────

String _fmt(double v) => NumberFormat('#,##0', 'fr_FR').format(v);
