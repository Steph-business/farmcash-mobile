import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../api_client/api_exception.dart';
import '../../../../models/annonce_achat.dart';
import '../../../../models/parcelle.dart';
import '../../../../services/providers.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';
import '../../../widgets/communs/chargement.dart';
import '../../../widgets/communs/snackbars.dart';
import '../../../widgets/communs/vue_erreur.dart';

const Color _kPrimarySoft = Color(0xFFE8F5E9);
const Color _kWarn = Color(0xFFB45309);

// ─── Provider ────────────────────────────────────────────────────────

class _RepondreBundle {
  const _RepondreBundle({required this.demande, required this.parcelles});
  final AnnonceAchat demande;
  final List<Parcelle> parcelles;
}

final _repondreBundleProvider = FutureProvider.autoDispose
    .family<_RepondreBundle, String>((ref, demandeId) async {
  final svc = ref.read(marketplaceServiceProvider);
  final results = await Future.wait<dynamic>([
    svc.getAnnonceAchat(demandeId),
    svc.listParcelles().then<Object?>((v) => v).catchError(
          (_) => const <Parcelle>[],
        ),
  ]);
  return _RepondreBundle(
    demande: results[0] as AnnonceAchat,
    parcelles: results[1] as List<Parcelle>,
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
              _Header(),
              Expanded(child: Chargement(size: 22)),
            ],
          ),
          error: (e, _) => Column(
            children: [
              const _Header(),
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
        const _Header(),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
            children: [
              _RecapCard(demande: d),
              AppDimens.vGap16,
              const _SectionTitle(title: 'Depuis quelle parcelle ?'),
              AppDimens.vGap8,
              _ParcelleSelector(
                parcelles: parcelles,
                selectedId: _parcelleId,
                onChanged: (id) => setState(() => _parcelleId = id),
                enabled: !_isSubmitting,
              ),
              AppDimens.vGap16,
              const _SectionTitle(title: 'Quantité que je peux fournir'),
              AppDimens.vGap8,
              _InputUnit(
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
                _HelpText(
                  text:
                      'Parcelle de ${_fmt(maxDispo)} ha — adapte la quantité selon ta récolte.',
                ),
              AppDimens.vGap16,
              const _SectionTitle(title: 'Prix proposé'),
              AppDimens.vGap8,
              _InputUnit(
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
              _HelpText(
                text:
                    'L\'acheteur accepte jusqu\'à ${_fmt(d.prixMaxKg)} F/kg. Tu peux baisser pour gagner l\'offre.',
              ),
              AppDimens.vGap16,
              _TotalCard(total: _total),
              AppDimens.vGap24,
              const _SectionTitle(title: 'Message à l\'acheteur (optionnel)'),
              AppDimens.vGap8,
              _NoteField(controller: _msgCtrl, enabled: !_isSubmitting),
            ],
          ),
        ),
        _StickyActions(
          isSubmitting: _isSubmitting,
          onEnvoyer: _envoyer,
          onRefuser: _refuser,
        ),
      ],
    );
  }
}

// ─── Header ───────────────────────────────────────────────────────

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

// ─── Recap card (vraies données AnnonceAchat) ────────────────────

class _RecapCard extends StatelessWidget {
  const _RecapCard({required this.demande});
  final AnnonceAchat demande;

  @override
  Widget build(BuildContext context) {
    final nomProduit = demande.produitLabel;
    final qte = '${_fmt(demande.quantiteKg)} kg';
    final prixMax = '${_fmt(demande.prixMaxKg)} F/kg';
    final region = demande.regionNom;
    final buyer = demande.buyerNom ?? 'Acheteur';
    final photo = demande.buyer?.photoUrl;
    final dateLimite = demande.dateLimiteLivraison;
    final dateLabel = dateLimite != null
        ? 'Livraison avant le ${DateFormat('d MMM y', 'fr_FR').format(dateLimite)}'
        : 'Date de livraison à confirmer';

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
                  child: photo != null && photo.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: photo,
                          fit: BoxFit.cover,
                          placeholder: (_, _) =>
                              Container(color: AppColors.surfaceSoft),
                          errorWidget: (_, _, _) =>
                              Container(color: AppColors.surfaceSoft),
                        )
                      : Container(
                          color: AppColors.background,
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.person_outline,
                            size: 22,
                            color: AppColors.primary,
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
                      buyer,
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (region != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        region,
                        style: AppTextStyles.bodySmall.copyWith(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
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
          const SizedBox(height: 12),
          Text(
            '$qte de $nomProduit',
            style: AppTextStyles.displayLarge.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Prix max accepté : $prixMax',
            style: AppTextStyles.displayLarge.copyWith(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            dateLabel,
            style: AppTextStyles.labelSmall.copyWith(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: _kWarn,
            ),
          ),
          if (demande.description != null &&
              demande.description!.trim().isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              demande.description!,
              style: AppTextStyles.bodySmall.copyWith(
                fontSize: 11,
                color: AppColors.text,
                height: 1.5,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─── Section title ────────────────────────────────────────────────

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

// ─── Parcelle selector (API parcelles) ─────────────────────────────

class _ParcelleSelector extends StatelessWidget {
  const _ParcelleSelector({
    required this.parcelles,
    required this.selectedId,
    required this.onChanged,
    required this.enabled,
  });

  final List<Parcelle> parcelles;
  final String? selectedId;
  final ValueChanged<String?> onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    if (parcelles.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surfaceSoft,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: AppColors.border,
            width: AppDimens.borderThin,
          ),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.info_outline,
              size: 16,
              color: AppColors.textSubtle,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Aucune parcelle déclarée — déclare-en une pour rattacher tes offres.',
                style: AppTextStyles.bodySmall.copyWith(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      );
    }
    return DropdownButtonFormField<String>(
      initialValue: selectedId,
      isExpanded: true,
      onChanged: enabled ? onChanged : null,
      decoration: InputDecoration(
        filled: true,
        fillColor: AppColors.background,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
            color: AppColors.borderStrong,
            width: AppDimens.borderThin,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
            color: AppColors.borderStrong,
            width: AppDimens.borderThin,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
            color: AppColors.primary,
            width: AppDimens.borderMedium,
          ),
        ),
      ),
      items: [
        for (final p in parcelles)
          DropdownMenuItem<String>(
            value: p.id,
            child: Text(
              '${p.nom} · ${_fmt(p.superficieHa ?? 0)} ha',
            ),
          ),
      ],
    );
  }
}

// ─── Input avec unité ─────────────────────────────────────────────

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

// ─── Total card ───────────────────────────────────────────────────

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

// ─── Note ─────────────────────────────────────────────────────────

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

// ─── Sticky actions ───────────────────────────────────────────────

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

// ─── Helpers ──────────────────────────────────────────────────────

String _fmt(double v) => NumberFormat('#,##0', 'fr_FR').format(v.round());
