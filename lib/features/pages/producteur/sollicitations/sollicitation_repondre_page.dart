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

const String _kMaisThumb =
    'https://images.unsplash.com/photo-1601493700631-2b16ec4b4716?w=200&h=200&fit=crop&auto=format';

/// Détail enrichi d'une sollicitation côté UI. Le backend renvoie un
/// payload Map complexe (annonce + cooperative + recipients + responses_summary).
/// On extrait ce qui sert au récap card.
class _SolDetail {
  const _SolDetail({
    required this.coopNom,
    required this.coopLogoUrl,
    required this.produitNom,
    required this.produitThumb,
    required this.quantiteKg,
    required this.prixMinKg,
    required this.expiresAt,
    required this.message,
  });

  final String coopNom;
  final String? coopLogoUrl;
  final String produitNom;
  final String? produitThumb;
  final double? quantiteKg;
  final double? prixMinKg;
  final DateTime? expiresAt;
  final String? message;
}

/// Charge le détail enrichi de la sollicitation depuis le backend.
final _solDetailProvider = FutureProvider.autoDispose
    .family<_SolDetail, String>((ref, id) async {
  final raw =
      await ref.read(cooperativesServiceProvider).getSollicitation(id);

  final coop = raw['cooperative'] as Map<String, dynamic>?;
  final annonce = raw['annonce'] as Map<String, dynamic>?;
  final produit = (annonce?['produits_agricoles']
          as Map<String, dynamic>?) ??
      (annonce?['produit'] as Map<String, dynamic>?);
  final medias = annonce?['medias'] as List<dynamic>?;
  final firstPhoto = medias
      ?.whereType<Map>()
      .map((m) => (m['url'] ?? m['thumbnail_url'])?.toString())
      .firstWhere((u) => u != null && u.isNotEmpty, orElse: () => null);

  double? toDouble(dynamic v) {
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v);
    return null;
  }

  DateTime? toDate(dynamic v) {
    if (v is String) return DateTime.tryParse(v);
    return null;
  }

  return _SolDetail(
    coopNom: (coop?['nom'] as String?)?.trim().isNotEmpty == true
        ? coop!['nom'] as String
        : 'Ma coopérative',
    coopLogoUrl: coop?['logo_url'] as String?,
    produitNom: (produit?['nom'] as String?) ?? 'Produit',
    produitThumb: firstPhoto,
    quantiteKg: toDouble(raw['quantite_cible_kg']) ??
        toDouble(annonce?['quantite_kg']),
    prixMinKg: toDouble(annonce?['prix_max_kg']) ??
        toDouble(annonce?['prix_par_kg']),
    expiresAt: toDate(raw['expires_at']),
    message: raw['message'] as String?,
  );
});

/// Page de réponse à une sollicitation reçue de la coopérative.
class SollicitationRepondrePage extends ConsumerStatefulWidget {
  const SollicitationRepondrePage({required this.sollicitationId, super.key});

  final String sollicitationId;

  @override
  ConsumerState<SollicitationRepondrePage> createState() =>
      _SollicitationRepondrePageState();
}

enum _Quand { maintenant, plusTard }

class _SollicitationRepondrePageState
    extends ConsumerState<SollicitationRepondrePage> {
  _Quand _quand = _Quand.maintenant;
  DateTime? _dateEstimee;

  final _qteCtrl = TextEditingController(text: '120');
  final _prixCtrl = TextEditingController(text: '800');
  final _noteCtrl = TextEditingController();

  bool _isSubmitting = false;

  @override
  void dispose() {
    _qteCtrl.dispose();
    _prixCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  double? get _qteKg {
    final raw = _qteCtrl.text.trim().replaceAll(',', '.');
    return double.tryParse(raw);
  }

  Future<void> _choisirDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _dateEstimee ?? now.add(const Duration(days: 7)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (picked != null && mounted) {
      setState(() => _dateEstimee = picked);
    }
  }

  Future<void> _envoyer({required bool accept}) async {
    if (_isSubmitting) return;
    if (accept) {
      final q = _qteKg;
      if (q == null || q <= 0) {
        Snackbars.showErreur(context, 'Indique une quantité valide.');
        return;
      }
    }
    setState(() => _isSubmitting = true);
    try {
      await ref.read(cooperativesServiceProvider).respondSollicitation(
            id: widget.sollicitationId,
            accept: accept,
            quantiteKg: accept ? _qteKg : null,
          );
      if (!mounted) return;
      Snackbars.showSucces(
        context,
        accept ? 'Réponse envoyée à la coop.' : 'Sollicitation refusée.',
      );
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

  @override
  Widget build(BuildContext context) {
    final detailAsync =
        ref.watch(_solDetailProvider(widget.sollicitationId));
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const _Header(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                children: [
                  AppDimens.vGap8,
                  detailAsync.when(
                    loading: () => const _RecapCardLoading(),
                    error: (_, _) => const _RecapCardError(),
                    data: (d) => _RecapCard(detail: d),
                  ),
                  AppDimens.vGap24,
                  _SectionTitle(title: 'Quand peux-tu fournir ?'),
                  AppDimens.vGap12,
                  _WhenRow(
                    selected: _quand,
                    onChange: (q) {
                      setState(() {
                        _quand = q;
                        if (q == _Quand.maintenant) _dateEstimee = null;
                      });
                    },
                  ),
                  if (_quand == _Quand.plusTard) ...[
                    AppDimens.vGap16,
                    _DateField(
                      date: _dateEstimee,
                      onTap: _choisirDate,
                      enabled: !_isSubmitting,
                    ),
                  ],
                  AppDimens.vGap24,
                  _SectionTitle(title: 'Ma contribution'),
                  AppDimens.vGap12,
                  _FieldLabel(label: 'Quantité que je peux fournir'),
                  AppDimens.vGap8,
                  _InputUnit(
                    controller: _qteCtrl,
                    unit: 'kg',
                    enabled: !_isSubmitting,
                    hint: '0',
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: false,
                    ),
                    formatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                    ],
                  ),
                  AppDimens.vGap16,
                  _FieldLabel(label: 'Prix proposé'),
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
                  AppDimens.vGap16,
                  _FieldLabel(label: 'Note pour la coop (optionnel)'),
                  AppDimens.vGap8,
                  _NoteField(controller: _noteCtrl, enabled: !_isSubmitting),
                  AppDimens.vGap16,
                ],
              ),
            ),
            _StickyActions(
              isSubmitting: _isSubmitting,
              onRefuser: () => _envoyer(accept: false),
              onEnvoyer: () => _envoyer(accept: true),
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
        AppDimens.pagePaddingH,
        AppDimens.space8,
        AppDimens.pagePaddingH,
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Répondre à la sollicitation',
                  style: AppTextStyles.titleSmall.copyWith(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Indique ta contribution',
                  style: AppTextStyles.bodySmall.copyWith(
                    fontSize: 12,
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

// ─── Recap (primary-soft) ────────────────────────────────────────────────

class _RecapCard extends StatelessWidget {
  const _RecapCard({required this.detail});

  final _SolDetail detail;

  @override
  Widget build(BuildContext context) {
    final qte = detail.quantiteKg;
    final prix = detail.prixMinKg;
    final delaiJours =
        detail.expiresAt?.difference(DateTime.now()).inDays;
    final parts = <String>[
      if (qte != null) '${qte.toStringAsFixed(0)} kg ${detail.produitNom}',
      if (qte == null) detail.produitNom,
      if (delaiJours != null && delaiJours > 0) 'max ${delaiJours}j',
      if (prix != null && prix > 0) '≥ ${prix.toStringAsFixed(0)} F/kg',
    ];
    final summary = parts.isEmpty
        ? (detail.message ?? 'Sollicitation reçue')
        : parts.join(' · ');
    final thumbUrl = detail.produitThumb ?? _kMaisThumb;

    return Container(
      decoration: BoxDecoration(
        color: _kPrimarySoft,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.border,
          width: AppDimens.borderThin,
        ),
      ),
      padding: const EdgeInsets.fromLTRB(14, 14, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceSoft,
                    border: Border.all(
                      color: AppColors.border,
                      width: AppDimens.borderThin,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  clipBehavior: Clip.hardEdge,
                  child: detail.coopLogoUrl == null ||
                          detail.coopLogoUrl!.isEmpty
                      ? Container(
                          color: AppColors.surfaceSoft,
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.groups_outlined,
                            size: 16,
                            color: AppColors.primary,
                          ),
                        )
                      : CachedNetworkImage(
                          imageUrl: detail.coopLogoUrl!,
                          fit: BoxFit.cover,
                          placeholder: (_, _) =>
                              Container(color: AppColors.surfaceSoft),
                          errorWidget: (_, _, _) =>
                              Container(color: AppColors.surfaceSoft),
                        ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  detail.coopNom,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (detail.expiresAt != null)
                Text(
                  'Jusqu\'au ${DateFormat('d MMM', 'fr_FR').format(detail.expiresAt!)}',
                  style: AppTextStyles.bodySmall.copyWith(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  summary,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontSize: 13,
                    color: AppColors.text,
                    height: 1.4,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  width: 60,
                  height: 60,
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
                    imageUrl: thumbUrl,
                    fit: BoxFit.cover,
                    placeholder: (_, _) =>
                        Container(color: AppColors.surfaceSoft),
                    errorWidget: (_, _, _) =>
                        Container(color: AppColors.surfaceSoft),
                  ),
                ),
              ),
            ],
          ),
          if (detail.message != null &&
              detail.message!.trim().isNotEmpty &&
              !summary.contains(detail.message!.trim())) ...[
            const SizedBox(height: 10),
            Text(
              detail.message!,
              style: AppTextStyles.bodySmall.copyWith(
                fontSize: 12,
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

class _RecapCardLoading extends StatelessWidget {
  const _RecapCardLoading();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _kPrimarySoft,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.border,
          width: AppDimens.borderThin,
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 14),
      child: const Center(
        child: SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }
}

class _RecapCardError extends StatelessWidget {
  const _RecapCardError();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFDECEA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.error,
          width: AppDimens.borderThin,
        ),
      ),
      padding: const EdgeInsets.all(14),
      child: Text(
        'Impossible de charger le détail de la sollicitation. '
        'Tu peux quand même répondre.',
        style: AppTextStyles.bodySmall.copyWith(
          fontSize: 12,
          color: AppColors.error,
        ),
      ),
    );
  }
}

// ─── Section title ───────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: AppTextStyles.titleSmall.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w700,
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
      style: AppTextStyles.labelMedium.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: AppColors.textSecondary,
      ),
    );
  }
}

// ─── When toggle ─────────────────────────────────────────────────────────

class _WhenRow extends StatelessWidget {
  const _WhenRow({required this.selected, required this.onChange});

  final _Quand selected;
  final ValueChanged<_Quand> onChange;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _WhenCard(
            emoji: '✅',
            title: 'Maintenant',
            subtitle: 'Stocks dispo',
            active: selected == _Quand.maintenant,
            onTap: () => onChange(_Quand.maintenant),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _WhenCard(
            emoji: '⏳',
            title: 'Plus tard',
            subtitle: 'Date à venir',
            active: selected == _Quand.plusTard,
            onTap: () => onChange(_Quand.plusTard),
          ),
        ),
      ],
    );
  }
}

class _WhenCard extends StatelessWidget {
  const _WhenCard({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.active,
    required this.onTap,
  });

  final String emoji;
  final String title;
  final String subtitle;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 14, 12, 14),
        decoration: BoxDecoration(
          color: active ? _kPrimarySoft : AppColors.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: active ? AppColors.primary : AppColors.border,
            width: AppDimens.borderMedium,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 4),
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
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Date field ──────────────────────────────────────────────────────────

class _DateField extends StatelessWidget {
  const _DateField({
    required this.date,
    required this.onTap,
    required this.enabled,
  });

  final DateTime? date;
  final VoidCallback onTap;
  final bool enabled;

  String _format(DateTime d) {
    final dd = d.day.toString().padLeft(2, '0');
    final mm = d.month.toString().padLeft(2, '0');
    return '$dd/$mm/${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FieldLabel(label: 'Date estimée'),
        AppDimens.vGap8,
        InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.border,
                width: AppDimens.borderThin,
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.calendar_today_outlined,
                  size: AppDimens.iconM,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    date != null
                        ? _format(date!)
                        : 'Choisir une date',
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontSize: 14,
                      color: date != null
                          ? AppColors.text
                          : AppColors.textSubtle,
                    ),
                  ),
                ),
                const Icon(
                  Icons.keyboard_arrow_down,
                  size: AppDimens.iconM,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Input avec unité (kg / F/kg) ────────────────────────────────────────

class _InputUnit extends StatelessWidget {
  const _InputUnit({
    required this.controller,
    required this.unit,
    required this.enabled,
    this.hint,
    this.keyboardType,
    this.formatters,
  });

  final TextEditingController controller;
  final String unit;
  final bool enabled;
  final String? hint;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? formatters;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
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
              enabled: enabled,
              keyboardType: keyboardType,
              inputFormatters: formatters,
              style: AppTextStyles.bodyMedium.copyWith(
                fontSize: 14,
                color: AppColors.text,
              ),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: AppTextStyles.bodyMedium.copyWith(
                  fontSize: 14,
                  color: AppColors.textSubtle,
                ),
                border: InputBorder.none,
                focusedBorder: InputBorder.none,
                enabledBorder: InputBorder.none,
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 12),
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

// ─── Note (textarea 2 lignes) ────────────────────────────────────────────

class _NoteField extends StatelessWidget {
  const _NoteField({required this.controller, required this.enabled});

  final TextEditingController controller;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.border,
          width: AppDimens.borderThin,
        ),
      ),
      child: TextField(
        controller: controller,
        enabled: enabled,
        minLines: 2,
        maxLines: 4,
        textCapitalization: TextCapitalization.sentences,
        style: AppTextStyles.bodyMedium.copyWith(
          fontSize: 13,
          color: AppColors.text,
        ),
        decoration: InputDecoration(
          hintText: 'Précisions sur ta livraison…',
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

// ─── Sticky actions ──────────────────────────────────────────────────────

class _StickyActions extends StatelessWidget {
  const _StickyActions({
    required this.isSubmitting,
    required this.onRefuser,
    required this.onEnvoyer,
  });

  final bool isSubmitting;
  final VoidCallback onRefuser;
  final VoidCallback onEnvoyer;

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
      padding: const EdgeInsets.fromLTRB(
        AppDimens.pagePaddingH,
        14,
        AppDimens.pagePaddingH,
        12,
      ),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: isSubmitting ? null : onRefuser,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.borderStrong,
                    width: AppDimens.borderThin,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  'Refuser cette sollicitation',
                  style: AppTextStyles.button.copyWith(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: InkWell(
              onTap: isSubmitting ? null : onEnvoyer,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(12),
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
                        'Envoyer ma réponse',
                        style: AppTextStyles.button.copyWith(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

