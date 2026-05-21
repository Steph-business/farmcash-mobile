import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../api_client/api_exception.dart';
import '../../../models/annonce_vente.dart';
import '../../../models/enums.dart';
import '../../../routing/route_names.dart';
import '../../../services/providers.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_dimens.dart';
import '../../../theme/app_text_styles.dart';
import '../../widgets/communs/chargement.dart';
import '../../widgets/communs/snackbars.dart';
import '../../widgets/communs/vue_erreur.dart';

const Color _kPrimarySoft = Color(0xFFE8F5E9);
const Color _kWarn = Color(0xFFB45309);
const BorderRadius _kBrCard12 = BorderRadius.all(Radius.circular(12));
const BorderRadius _kBrChip = BorderRadius.all(Radius.circular(14));

/// Provider qui récupère l'annonce de vente attachée à la coopérative
/// (paramètre `livraisonId` == `annonce_vente_id`). Côté backend, la coop
/// peut valider/rejeter une annonce qui lui a été assignée.
final _peseeAnnonceProvider = FutureProvider.autoDispose
    .family<AnnonceVente, String>((ref, id) async {
  return ref.read(marketplaceServiceProvider).getAnnonceVente(id);
});

/// Pesée d'une livraison farmer arrivée à la coopérative.
/// `validateAnnonceVente` → propage la quantité/qualité validées à
/// l'annonce, change son statut côté back et notifie le farmer.
class PeseePage extends ConsumerStatefulWidget {
  const PeseePage({super.key, required this.livraisonId});

  final String livraisonId;

  @override
  ConsumerState<PeseePage> createState() => _PeseePageState();
}

class _PeseePageState extends ConsumerState<PeseePage> {
  final _poidsCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();
  ProductQuality _qualite = ProductQuality.standard;
  bool _hydrated = false;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _poidsCtrl.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _poidsCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  void _hydrateOnce(AnnonceVente a) {
    if (_hydrated) return;
    _hydrated = true;
    _poidsCtrl.text = a.quantiteKg.round().toString();
    _qualite = a.qualite == ProductQuality.unknown
        ? ProductQuality.standard
        : a.qualite;
  }

  double? get _poidsMesure {
    final raw = _poidsCtrl.text.trim().replaceAll(',', '.');
    if (raw.isEmpty) return null;
    return double.tryParse(raw);
  }

  double _ecartContre(double annonce) {
    final p = _poidsMesure ?? 0;
    return p - annonce;
  }

  String _ecartLabel(double annonce) {
    final e = _ecartContre(annonce);
    final signe = e >= 0 ? '+' : '−';
    return 'Écart annoncé / mesuré : $signe${e.abs().toStringAsFixed(0)} kg';
  }

  Color _ecartColor(double annonce) {
    return _ecartContre(annonce) > -10 ? AppColors.primary : _kWarn;
  }

  Future<void> _valider(AnnonceVente a) async {
    if (_busy) return;
    final poids = _poidsMesure;
    if (poids == null || poids <= 0) {
      Snackbars.showErreur(context, 'Saisis un poids mesuré valide.');
      return;
    }
    setState(() => _busy = true);
    try {
      await ref.read(cooperativesServiceProvider).validateAnnonceVente(
            id: a.id,
            quantiteValideeKg: poids,
            qualiteValidee: _qualite,
            notes: _noteCtrl.text.trim().isEmpty
                ? null
                : _noteCtrl.text.trim(),
          );
      if (!mounted) return;
      Snackbars.showSucces(
        context,
        'Pesée validée. Le producteur est notifié.',
      );
      ref.invalidate(_peseeAnnonceProvider(widget.livraisonId));
      if (context.canPop()) {
        context.pop(true);
      } else {
        context.go(RouteNames.cooperativeCollectePath);
      }
    } on ApiException catch (e) {
      if (mounted) Snackbars.showErreur(context, e.message);
    } catch (e) {
      if (mounted) Snackbars.showErreur(context, 'Erreur : $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _rejeter(AnnonceVente a) async {
    if (_busy) return;
    final motif = await _demanderMotif();
    if (motif == null || motif.trim().isEmpty) return;
    setState(() => _busy = true);
    try {
      await ref.read(cooperativesServiceProvider).rejectAnnonceVente(
            id: a.id,
            motif: motif.trim(),
          );
      if (!mounted) return;
      Snackbars.showInfo(context, 'Livraison rejetée. Producteur notifié.');
      ref.invalidate(_peseeAnnonceProvider(widget.livraisonId));
      if (context.canPop()) {
        context.pop(true);
      } else {
        context.go(RouteNames.cooperativeCollectePath);
      }
    } on ApiException catch (e) {
      if (mounted) Snackbars.showErreur(context, e.message);
    } catch (e) {
      if (mounted) Snackbars.showErreur(context, 'Erreur : $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<String?> _demanderMotif() async {
    final ctrl = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Motif de rejet'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'Ex : marchandise dégradée, poids très en-dessous…',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(ctrl.text),
            child: const Text('Rejeter'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(_peseeAnnonceProvider(widget.livraisonId));
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
                    message: 'Impossible de charger la livraison. $e',
                    onRetry: () => ref
                        .invalidate(_peseeAnnonceProvider(widget.livraisonId)),
                  ),
                ),
              ),
            ],
          ),
          data: (a) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) _hydrateOnce(a);
            });
            return _build(a);
          },
        ),
      ),
    );
  }

  Widget _build(AnnonceVente a) {
    final annonceQte = a.quantiteKg;
    return Column(
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
              _HeroCard(annonce: a),
              const SizedBox(height: 20),
              const _Label('Poids réel mesuré'),
              const SizedBox(height: 10),
              _WeightBox(
                controller: _poidsCtrl,
                ecartLabel: _ecartLabel(annonceQte),
                ecartColor: _ecartColor(annonceQte),
              ),
              const SizedBox(height: 22),
              const _Label('Qualité observée'),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final q in const [
                    ProductQuality.standard,
                    ProductQuality.premium,
                    ProductQuality.bio,
                    ProductQuality.equitable,
                  ])
                    _QualityChip(
                      label: _qualiteLabel(q),
                      active: _qualite == q,
                      onTap: () => setState(() => _qualite = q),
                    ),
                ],
              ),
              const SizedBox(height: 22),
              const _Label('Note interne (optionnel)'),
              const SizedBox(height: 10),
              _NoteField(controller: _noteCtrl, enabled: !_busy),
            ],
          ),
        ),
        _StickyButtons(
          busy: _busy,
          onRejeter: () => _rejeter(a),
          onValider: () => _valider(a),
        ),
      ],
    );
  }
}

String _qualiteLabel(ProductQuality q) {
  switch (q) {
    case ProductQuality.standard:
      return 'Standard';
    case ProductQuality.premium:
      return 'Premium';
    case ProductQuality.bio:
      return 'Bio';
    case ProductQuality.equitable:
      return 'Équitable';
    case ProductQuality.unknown:
      return 'Standard';
  }
}

// ─── Header ───────────────────────────────────────────────────────

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
            onTap: () => context.canPop()
                ? context.pop()
                : context.go(RouteNames.cooperativeCollectePath),
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
              'Peser la livraison',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
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

// ─── Hero card ────────────────────────────────────────────────────

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.annonce});
  final AnnonceVente annonce;

  @override
  Widget build(BuildContext context) {
    final farmerNom = annonce.vendeurNom ?? 'Producteur';
    final qteAnnonce =
        '${NumberFormat('#,##0', 'fr_FR').format(annonce.quantiteKg.round())} kg';
    final qualite = _qualiteLabel(annonce.qualite);
    final photo =
        annonce.photos.isNotEmpty ? annonce.photos.first : null;
    return ClipRRect(
      borderRadius: _kBrCard12,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: _kBrCard12,
          border: Border.all(
            color: AppColors.border,
            width: AppDimens.borderThin,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 140,
              width: double.infinity,
              child: photo != null
                  ? CachedNetworkImage(
                      imageUrl: photo,
                      fit: BoxFit.cover,
                      placeholder: (_, _) =>
                          const ColoredBox(color: _kPrimarySoft),
                      errorWidget: (_, _, _) =>
                          const ColoredBox(color: _kPrimarySoft),
                    )
                  : Container(
                      color: _kPrimarySoft,
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.shopping_basket_outlined,
                        size: 48,
                        color: AppColors.primary,
                      ),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    farmerNom,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.titleSmall.copyWith(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Annoncé : $qteAnnonce · Qualité $qualite',
                    style: AppTextStyles.bodySmall.copyWith(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: AppColors.border,
                        width: AppDimens.borderThin,
                      ),
                    ),
                    child: Text(
                      'En attente de pesée',
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
      ),
    );
  }
}

// ─── Label ─────────────────────────────────────────────────────────

class _Label extends StatelessWidget {
  const _Label(this.text);
  final String text;
  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: AppTextStyles.labelMedium.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: AppColors.text,
      ),
    );
  }
}

// ─── Weight box ──────────────────────────────────────────────────

class _WeightBox extends StatelessWidget {
  const _WeightBox({
    required this.controller,
    required this.ecartLabel,
    required this.ecartColor,
  });
  final TextEditingController controller;
  final String ecartLabel;
  final Color ecartColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: _kBrCard12,
        border: Border.all(
          color: AppColors.borderStrong,
          width: AppDimens.borderThin,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: controller,
            keyboardType:
                const TextInputType.numberWithOptions(decimal: false),
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: AppTextStyles.displayLarge.copyWith(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: AppColors.text,
              letterSpacing: -0.5,
            ),
            decoration: const InputDecoration(
              border: InputBorder.none,
              focusedBorder: InputBorder.none,
              enabledBorder: InputBorder.none,
              isDense: true,
              suffixText: 'kg',
              suffixStyle: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            ecartLabel,
            style: AppTextStyles.bodySmall.copyWith(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: ecartColor,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Quality chip ─────────────────────────────────────────────────

class _QualityChip extends StatelessWidget {
  const _QualityChip({
    required this.label,
    required this.active,
    required this.onTap,
  });
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: _kBrChip,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: active ? AppColors.primary : AppColors.background,
          borderRadius: _kBrChip,
          border: Border.all(
            color: active ? AppColors.primary : AppColors.borderStrong,
            width: AppDimens.borderThin,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.labelMedium.copyWith(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: active ? AppColors.onPrimary : AppColors.text,
          ),
        ),
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
        borderRadius: AppDimens.brInput,
        border: Border.all(
          color: AppColors.border,
          width: AppDimens.borderThin,
        ),
      ),
      child: TextField(
        controller: controller,
        enabled: enabled,
        minLines: 3,
        maxLines: 5,
        textCapitalization: TextCapitalization.sentences,
        decoration: InputDecoration(
          hintText: 'Observations sur la livraison…',
          border: InputBorder.none,
          isDense: true,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          hintStyle: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSubtle,
          ),
        ),
      ),
    );
  }
}

// ─── Sticky bottom ────────────────────────────────────────────────

class _StickyButtons extends StatelessWidget {
  const _StickyButtons({
    required this.busy,
    required this.onRejeter,
    required this.onValider,
  });
  final bool busy;
  final VoidCallback onRejeter;
  final VoidCallback onValider;

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
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: busy ? null : onRejeter,
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 13),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: AppColors.borderStrong,
                    width: AppDimens.borderThin,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  'Rejeter',
                  style: AppTextStyles.button.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.error,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: InkWell(
              onTap: busy ? null : onValider,
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 13),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: busy
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        'Valider',
                        style: AppTextStyles.button.copyWith(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.onPrimary,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
