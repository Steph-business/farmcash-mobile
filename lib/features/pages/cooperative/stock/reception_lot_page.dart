import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../api_client/api_exception.dart';
import '../../../../models/enums.dart';
import '../../../../models/produit.dart';
import '../../../../routing/route_names.dart';
import '../../../../services/providers.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';
import '../../../state/auth_state.dart';
import '../../../widgets/communs/snackbars.dart';

// ─── Constantes locales ─────────────────────────────────────────────────
const Color _kPrimarySoft = Color(0xFFE8F5E9);
const BorderRadius _kBrCard12 = BorderRadius.all(Radius.circular(12));
const BorderRadius _kBrChip = BorderRadius.all(Radius.circular(14));

/// Sources possibles → mappées sur le champ `type` du lot.
/// COLLECTE = livraison farmer, ACHAT_EXTERNE = achat direct hors coop.
const List<({String label, String apiType})> _kSources = [
  (label: 'Depuis une livraison farmer', apiType: 'COLLECTE'),
  (label: 'Lot externe (achat direct)', apiType: 'ACHAT_EXTERNE'),
];

const List<({String label, ProductQuality api})> _kQualites = [
  (label: 'Standard', api: ProductQuality.standard),
  (label: 'Premium', api: ProductQuality.premium),
  (label: 'Bio', api: ProductQuality.bio),
  (label: 'Équitable', api: ProductQuality.equitable),
];

/// Provider qui charge la liste des produits pour le sélecteur.
final _produitsProvider = FutureProvider.autoDispose<List<Produit>>((ref) {
  return ref.read(marketplaceServiceProvider).listProduits();
});

/// Formulaire de réception d'un nouveau lot dans un entrepôt.
class ReceptionLotPage extends ConsumerStatefulWidget {
  const ReceptionLotPage({super.key});

  @override
  ConsumerState<ReceptionLotPage> createState() => _ReceptionLotPageState();
}

class _ReceptionLotPageState extends ConsumerState<ReceptionLotPage> {
  final TextEditingController _qteCtrl = TextEditingController();
  DateTime _date = DateTime.now();
  int _sourceIndex = 0;
  int _qualiteIndex = 0;
  Produit? _produit;
  bool _busy = false;

  @override
  void dispose() {
    _qteCtrl.dispose();
    super.dispose();
  }

  String get _dateLabel {
    const moisPlein = [
      'janvier',
      'février',
      'mars',
      'avril',
      'mai',
      'juin',
      'juillet',
      'août',
      'septembre',
      'octobre',
      'novembre',
      'décembre',
    ];
    return '${_date.day} ${moisPlein[_date.month - 1]} ${_date.year}';
  }

  Future<void> _pickDate() async {
    final res = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(_date.year - 1),
      lastDate: DateTime(_date.year + 1),
    );
    if (res != null && mounted) {
      setState(() => _date = res);
    }
  }

  Future<void> _choisirProduit() async {
    final produits = await ref.read(_produitsProvider.future);
    if (!mounted) return;
    final selected = await showModalBottomSheet<Produit>(
      context: context,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return SafeArea(
          top: false,
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.symmetric(vertical: 8),
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Text(
                  'Choisir un produit',
                  style: AppTextStyles.titleSmall.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              for (final p in produits)
                ListTile(
                  title: Text(p.nom),
                  onTap: () => Navigator.of(ctx).pop(p),
                ),
            ],
          ),
        );
      },
    );
    if (selected != null && mounted) {
      setState(() => _produit = selected);
    }
  }

  Future<void> _enregistrer() async {
    if (_busy) return;
    final user = ref.read(currentUserProvider);
    final coopId = user?.cooperativeId;
    final produit = _produit;
    final quantiteText = _qteCtrl.text.replaceAll(',', '.').trim();
    final quantite = double.tryParse(quantiteText);

    if (produit == null) {
      Snackbars.showErreur(context, 'Choisissez un produit');
      return;
    }
    if (quantite == null || quantite <= 0) {
      Snackbars.showErreur(context, 'Quantité invalide');
      return;
    }
    if (coopId == null || coopId.isEmpty) {
      Snackbars.showErreur(
        context,
        "Aucune coopérative liée à votre compte",
      );
      return;
    }

    setState(() => _busy = true);
    try {
      final source = _kSources[_sourceIndex];
      await ref.read(marketplaceServiceProvider).createLot(
            type: source.apiType,
            produitId: produit.id,
            quantiteKg: quantite,
            cooperativeId: coopId,
            qualite: _kQualites[_qualiteIndex].api,
            dateRecolte: _date,
          );
      if (!mounted) return;
      Snackbars.showSucces(context, 'Lot enregistré');
      if (context.canPop()) context.pop();
    } on ApiException catch (e) {
      if (!mounted) return;
      Snackbars.showErreur(context, e.message);
    } catch (e) {
      if (!mounted) return;
      Snackbars.showErreur(context, 'Erreur : $e');
    } finally {
      if (mounted) setState(() => _busy = false);
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
                  _SectionTitle('Source du lot'),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (int i = 0; i < _kSources.length; i++)
                        _Chip(
                          label: _kSources[i].label,
                          active: _sourceIndex == i,
                          onTap: () => setState(() => _sourceIndex = i),
                        ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  _SectionTitle('Détails du lot'),
                  const SizedBox(height: 12),
                  _FieldLabel('Produit'),
                  const SizedBox(height: 6),
                  _SelectorProduit(
                    produit: _produit,
                    onTap: _busy ? null : _choisirProduit,
                  ),
                  const SizedBox(height: 14),
                  _FieldLabel('Quantité réceptionnée'),
                  const SizedBox(height: 6),
                  _InputWithUnit(
                    controller: _qteCtrl,
                    unit: 'kg',
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                    ],
                    placeholder: '0',
                  ),
                  const SizedBox(height: 14),
                  _FieldLabel('Qualité'),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (int i = 0; i < _kQualites.length; i++)
                        _Chip(
                          label: _kQualites[i].label,
                          active: _qualiteIndex == i,
                          onTap: () => setState(() => _qualiteIndex = i),
                        ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _FieldLabel('Date de récolte'),
                  const SizedBox(height: 6),
                  _InputDate(label: _dateLabel, onTap: _busy ? null : _pickDate),
                ],
              ),
            ),
            _StickyButton(onTap: _enregistrer, busy: _busy),
          ],
        ),
      ),
    );
  }
}

// ─── Header ─────────────────────────────────────────────────────────────

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
                : context.go(RouteNames.cooperativeStockPath),
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
              'Réceptionner un lot',
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

// ─── Section title ──────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: AppTextStyles.titleSmall.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.label);

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

// ─── Chip (source / qualité) ────────────────────────────────────────────

class _Chip extends StatelessWidget {
  const _Chip({
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
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: active ? AppColors.primary : AppColors.background,
          borderRadius: _kBrChip,
          border: Border.all(
            color: active ? AppColors.primary : AppColors.border,
            width: AppDimens.borderThin,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.labelMedium.copyWith(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: active ? AppColors.onPrimary : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

// ─── Sélecteur produit ──────────────────────────────────────────────────

class _SelectorProduit extends StatelessWidget {
  const _SelectorProduit({required this.produit, required this.onTap});

  final Produit? produit;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: _kBrCard12,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: _kBrCard12,
          border: Border.all(
            color: AppColors.border,
            width: AppDimens.borderThin,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                color: _kPrimarySoft,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.inventory_2_outlined,
                size: 18,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                produit?.nom ?? 'Choisir un produit',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.titleSmall.copyWith(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: produit == null
                      ? AppColors.textSubtle
                      : AppColors.text,
                ),
              ),
            ),
            const Icon(
              Icons.keyboard_arrow_down,
              size: 18,
              color: AppColors.textSubtle,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Inputs ─────────────────────────────────────────────────────────────

class _InputWithUnit extends StatelessWidget {
  const _InputWithUnit({
    required this.controller,
    required this.unit,
    this.placeholder = '',
    this.keyboardType,
    this.inputFormatters,
  });

  final TextEditingController controller;
  final String unit;
  final String placeholder;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: _kBrCard12,
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
              inputFormatters: inputFormatters,
              decoration: InputDecoration(
                hintText: placeholder,
                border: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                hintStyle: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSubtle,
                ),
              ),
              style: AppTextStyles.bodyMedium.copyWith(fontSize: 14),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            unit,
            style: AppTextStyles.titleSmall.copyWith(
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

class _InputDate extends StatelessWidget {
  const _InputDate({required this.label, required this.onTap});

  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: _kBrCard12,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: _kBrCard12,
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
                label,
                style: AppTextStyles.bodyMedium.copyWith(fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Sticky bouton ──────────────────────────────────────────────────────

class _StickyButton extends StatelessWidget {
  const _StickyButton({required this.onTap, required this.busy});

  final VoidCallback onTap;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppDimens.pagePaddingH,
        14,
        AppDimens.pagePaddingH,
        12,
      ),
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(
          top: BorderSide(
            color: AppColors.border,
            width: AppDimens.borderThin,
          ),
        ),
      ),
      child: SizedBox(
        width: double.infinity,
        height: 48,
        child: ElevatedButton(
          onPressed: busy ? null : onTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.onPrimary,
            elevation: 0,
            shape: const RoundedRectangleBorder(borderRadius: _kBrCard12),
          ),
          child: busy
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Text(
                  'Enregistrer le lot',
                  style: AppTextStyles.labelLarge.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.onPrimary,
                  ),
                ),
        ),
      ),
    );
  }
}
