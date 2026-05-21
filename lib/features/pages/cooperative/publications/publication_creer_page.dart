import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../api_client/api_exception.dart';
import '../../../../models/enums.dart';
import '../../../../models/produit.dart';
import '../../../../services/providers.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';
import '../../../widgets/communs/snackbars.dart';

/// Bundle de chargement : catalogue produits (pour le dropdown).
final _publicationBundleProvider =
    FutureProvider.autoDispose<List<Produit>>((ref) async {
  try {
    return await ref.read(marketplaceServiceProvider).listProduits();
  } catch (_) {
    return const <Produit>[];
  }
});

/// Création d'une publication coopérative — formulaire complet branché sur
/// `coopService.createPublication`. La publication est ensuite visible
/// côté marketplace acheteur (`PublicationCoop`).
class PublicationCreerPage extends ConsumerStatefulWidget {
  const PublicationCreerPage({super.key});

  @override
  ConsumerState<PublicationCreerPage> createState() =>
      _PublicationCreerPageState();
}

class _PublicationCreerPageState extends ConsumerState<PublicationCreerPage> {
  final _titreCtrl = TextEditingController();
  final _quantiteCtrl = TextEditingController();
  final _prixCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();
  Produit? _produit;
  ProductQuality _qualite = ProductQuality.standard;
  bool _busy = false;

  static const List<ProductQuality> _qualites = [
    ProductQuality.standard,
    ProductQuality.premium,
    ProductQuality.bio,
    ProductQuality.equitable,
  ];

  @override
  void dispose() {
    _titreCtrl.dispose();
    _quantiteCtrl.dispose();
    _prixCtrl.dispose();
    _descriptionCtrl.dispose();
    super.dispose();
  }

  Future<void> _choisirProduit(List<Produit> produits) async {
    if (produits.isEmpty) {
      Snackbars.showInfo(context, 'Catalogue produit indisponible');
      return;
    }
    final selected = await showModalBottomSheet<Produit>(
      context: context,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => _ProduitSheet(produits: produits, selectedId: _produit?.id),
    );
    if (selected != null && mounted) {
      setState(() {
        _produit = selected;
        if (_titreCtrl.text.trim().isEmpty) {
          _titreCtrl.text = selected.nom;
        }
      });
    }
  }

  Future<void> _publier() async {
    if (_busy) return;
    if (_produit == null) {
      Snackbars.showErreur(context, 'Choisis un produit.');
      return;
    }
    final titre = _titreCtrl.text.trim().isEmpty
        ? _produit!.nom
        : _titreCtrl.text.trim();
    final qte = double.tryParse(_quantiteCtrl.text.replaceAll(',', '.'));
    final prix = double.tryParse(_prixCtrl.text.replaceAll(',', '.'));
    if (qte == null || qte <= 0) {
      Snackbars.showErreur(context, 'Quantité (kg) invalide.');
      return;
    }
    if (prix == null || prix <= 0) {
      Snackbars.showErreur(context, 'Prix au kg invalide.');
      return;
    }
    setState(() => _busy = true);
    try {
      await ref.read(cooperativesServiceProvider).createPublication(
            produitId: _produit!.id,
            titre: titre,
            quantiteKg: qte,
            prixParKg: prix,
            qualite: _qualite,
            description: _descriptionCtrl.text.trim().isEmpty
                ? null
                : _descriptionCtrl.text.trim(),
          );
      if (!mounted) return;
      Snackbars.showSucces(context, 'Publication créée et visible sur le marché.');
      if (context.canPop()) {
        context.pop(true);
      }
    } on ApiException catch (e) {
      if (mounted) Snackbars.showErreur(context, e.message);
    } catch (e) {
      if (mounted) Snackbars.showErreur(context, 'Erreur : $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final asyncProduits = ref.watch(_publicationBundleProvider);
    final produits = asyncProduits.value ?? const <Produit>[];
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
                  const _SectionLabel(label: 'Produit à publier'),
                  AppDimens.vGap8,
                  _ProduitSelector(
                    produit: _produit,
                    onTap: () => _choisirProduit(produits),
                  ),
                  AppDimens.vGap24,
                  const _SectionLabel(label: 'Titre de l\'annonce'),
                  AppDimens.vGap8,
                  _TitreInput(controller: _titreCtrl, enabled: !_busy),
                  AppDimens.vGap24,
                  const _SectionLabel(label: 'Quantité à publier'),
                  AppDimens.vGap8,
                  _InputBig(
                    controller: _quantiteCtrl,
                    suffix: 'kg',
                    hint: 'Ex : 500',
                    enabled: !_busy,
                  ),
                  AppDimens.vGap24,
                  const _SectionLabel(label: 'Prix par kg'),
                  AppDimens.vGap8,
                  _InputBig(
                    controller: _prixCtrl,
                    suffix: 'F CFA / kg',
                    hint: 'Ex : 350',
                    enabled: !_busy,
                  ),
                  AppDimens.vGap24,
                  const _SectionLabel(label: 'Qualité'),
                  AppDimens.vGap8,
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: List.generate(_qualites.length, (i) {
                      final q = _qualites[i];
                      return _ChipQualite(
                        label: _qualiteLabel(q),
                        selected: _qualite == q,
                        onTap: () => setState(() => _qualite = q),
                      );
                    }),
                  ),
                  AppDimens.vGap24,
                  const _SectionLabel(label: 'Description (optionnelle)'),
                  AppDimens.vGap8,
                  _MultilineInput(
                    controller: _descriptionCtrl,
                    enabled: !_busy,
                    placeholder:
                        'Conditions de stockage, dates de récolte, etc.',
                  ),
                ],
              ),
            ),
            _Sticky(busy: _busy, onTap: _publier),
          ],
        ),
      ),
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

// ─── Header ────────────────────────────────────────────────────────

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
              'Publier sur le marché',
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

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});
  final String label;
  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: AppTextStyles.bodyMedium.copyWith(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppColors.text,
      ),
    );
  }
}

// ─── Produit selector ───────────────────────────────────────────────

class _ProduitSelector extends StatelessWidget {
  const _ProduitSelector({required this.produit, required this.onTap});
  final Produit? produit;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimens.radiusCard),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(AppDimens.radiusCard),
          border: Border.all(
            color: AppColors.border,
            width: AppDimens.borderThin,
          ),
        ),
        padding: const EdgeInsets.fromLTRB(16, 14, 14, 14),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    produit?.nom ?? 'Choisir un produit',
                    style: AppTextStyles.titleLarge.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (produit != null) ...[
                    const SizedBox(height: 3),
                    Text(
                      'Catalogue · ${produit!.slug}',
                      style: AppTextStyles.bodySmall.copyWith(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.chevron_right,
              size: 20,
              color: AppColors.textSubtle,
            ),
          ],
        ),
      ),
    );
  }
}

class _ProduitSheet extends StatelessWidget {
  const _ProduitSheet({required this.produits, required this.selectedId});
  final List<Produit> produits;
  final String? selectedId;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.7,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 14),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Choisir un produit',
                style: AppTextStyles.titleSmall.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: produits.length,
                itemBuilder: (_, i) {
                  final p = produits[i];
                  final selected = p.id == selectedId;
                  return ListTile(
                    title: Text(
                      p.nom,
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    trailing: selected
                        ? const Icon(Icons.check, color: AppColors.primary)
                        : null,
                    onTap: () => Navigator.of(context).pop(p),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Inputs ─────────────────────────────────────────────────────────

class _TitreInput extends StatelessWidget {
  const _TitreInput({required this.controller, required this.enabled});
  final TextEditingController controller;
  final bool enabled;
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
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: TextField(
        controller: controller,
        enabled: enabled,
        textCapitalization: TextCapitalization.sentences,
        style: AppTextStyles.bodyMedium.copyWith(fontSize: 14),
        decoration: InputDecoration(
          hintText: 'Ex : Maïs grain blanc · lot été',
          border: InputBorder.none,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
          hintStyle: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSubtle,
          ),
        ),
      ),
    );
  }
}

class _InputBig extends StatelessWidget {
  const _InputBig({
    required this.controller,
    required this.suffix,
    required this.hint,
    required this.enabled,
  });
  final TextEditingController controller;
  final String suffix;
  final String hint;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 14),
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
              enabled: enabled,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: false,
              ),
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              style: AppTextStyles.displayLarge.copyWith(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppColors.text,
              ),
              decoration: InputDecoration(
                hintText: hint,
                border: InputBorder.none,
                focusedBorder: InputBorder.none,
                enabledBorder: InputBorder.none,
                isDense: true,
                hintStyle: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSubtle,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            suffix,
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

class _MultilineInput extends StatelessWidget {
  const _MultilineInput({
    required this.controller,
    required this.enabled,
    required this.placeholder,
  });
  final TextEditingController controller;
  final bool enabled;
  final String placeholder;

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
        enabled: enabled,
        minLines: 3,
        maxLines: 5,
        textCapitalization: TextCapitalization.sentences,
        decoration: InputDecoration(
          hintText: placeholder,
          border: InputBorder.none,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 12,
          ),
          hintStyle: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSubtle,
          ),
        ),
      ),
    );
  }
}

class _ChipQualite extends StatelessWidget {
  const _ChipQualite({
    required this.label,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.background,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.borderStrong,
            width: AppDimens.borderThin,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.labelMedium.copyWith(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: selected ? AppColors.onPrimary : AppColors.text,
          ),
        ),
      ),
    );
  }
}

class _Sticky extends StatelessWidget {
  const _Sticky({required this.busy, required this.onTap});
  final bool busy;
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
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
      child: SizedBox(
        width: double.infinity,
        child: InkWell(
          onTap: busy ? null : onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(12),
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
                    'Publier la publication',
                    style: AppTextStyles.button.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.onPrimary,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
