import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../api_client/api_exception.dart';
import '../../../../models/enums.dart';
import '../../../../services/providers.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';
import '../../../widgets/communs/snackbars.dart';

// ─── Constantes locales ────────────────────────────────────────────────

const Color _kPrimarySoft = Color(0xFFE8F5E9);

const String _kMaisPhoto =
    'https://images.unsplash.com/photo-1601493700631-2b16ec4b4716?w=600&h=300&fit=crop&auto=format';
const String _kManiocPhoto =
    'https://images.unsplash.com/photo-1574484284002-952d92456975?w=600&h=300&fit=crop&auto=format';
const String _kTomatePhoto =
    'https://images.unsplash.com/photo-1518977956812-cd3dbadaaf31?w=600&h=300&fit=crop&auto=format';

class _ProduitOption {
  const _ProduitOption({
    required this.id,
    required this.nom,
    required this.photoUrl,
  });
  final String id;
  final String nom;
  final String photoUrl;
}

const List<_ProduitOption> _kProduits = [
  _ProduitOption(id: 'mais', nom: 'Maïs grain blanc', photoUrl: _kMaisPhoto),
  _ProduitOption(id: 'manioc', nom: 'Manioc frais', photoUrl: _kManiocPhoto),
  _ProduitOption(id: 'tomate', nom: 'Tomate fraîche', photoUrl: _kTomatePhoto),
];

const List<String> _kQualites = ['Standard', 'Premium', 'Bio', 'Équitable'];

class _CoopOption {
  const _CoopOption({required this.id, required this.nom});
  final String id;
  final String nom;
}

const List<_CoopOption> _kCoops = [
  _CoopOption(id: 'coop-agri', nom: 'COOP-AGRI Lagunes'),
  _CoopOption(id: 'coop-saveurs', nom: 'COOP Saveurs Sud'),
  _CoopOption(id: 'coop-bouake', nom: 'COOP Bouaké Centre'),
];

enum _Cible { public, allCoops, specificCoop }

/// Publier une demande d'achat — calque sur la maquette
/// `mockups/acheteur/publier_demande.html`.
class PublierDemandePage extends ConsumerStatefulWidget {
  const PublierDemandePage({super.key});

  @override
  ConsumerState<PublierDemandePage> createState() => _PublierDemandePageState();
}

class _PublierDemandePageState extends ConsumerState<PublierDemandePage> {
  _ProduitOption _produit = _kProduits.first;
  String _qualite = _kQualites.first;
  final _qteCtrl = TextEditingController(text: '500');
  final _prixCtrl = TextEditingController(text: '850');
  DateTime _dateLimite = DateTime(2026, 5, 23);
  _Cible _cible = _Cible.public;
  _CoopOption? _coopChoisie;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _qteCtrl.dispose();
    _prixCtrl.dispose();
    super.dispose();
  }

  void _ouvrirSelectionProduit() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return SafeArea(
          top: false,
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
              for (final p in _kProduits)
                ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: CachedNetworkImage(
                      imageUrl: p.photoUrl,
                      width: 40,
                      height: 40,
                      fit: BoxFit.cover,
                      placeholder: (_, _) =>
                          Container(color: AppColors.surfaceSoft),
                      errorWidget: (_, _, _) =>
                          Container(color: AppColors.surfaceSoft),
                    ),
                  ),
                  title: Text(
                    p.nom,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  trailing: p.id == _produit.id
                      ? const Icon(Icons.check, color: AppColors.primary)
                      : null,
                  onTap: () {
                    setState(() => _produit = p);
                    Navigator.of(ctx).pop();
                  },
                ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  Future<void> _ouvrirDatePicker() async {
    final now = DateTime.now();
    final result = await showDatePicker(
      context: context,
      initialDate: _dateLimite.isBefore(now) ? now : _dateLimite,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      locale: const Locale('fr', 'FR'),
    );
    if (result != null) {
      setState(() => _dateLimite = result);
    }
  }

  BuyOfferAudience get _audienceApi {
    switch (_cible) {
      case _Cible.public:
        return BuyOfferAudience.public;
      case _Cible.allCoops:
        return BuyOfferAudience.allCooperatives;
      case _Cible.specificCoop:
        return BuyOfferAudience.specificCooperative;
    }
  }

  Future<void> _publier() async {
    if (_isSubmitting) return;
    final qte = double.tryParse(_qteCtrl.text.trim().replaceAll(',', '.'));
    final prix = double.tryParse(_prixCtrl.text.trim().replaceAll(',', '.'));
    if (qte == null || qte <= 0 || prix == null || prix <= 0) {
      Snackbars.showErreur(
        context,
        'Indique une quantité et un prix max valides.',
      );
      return;
    }
    setState(() => _isSubmitting = true);
    try {
      await ref.read(marketplaceServiceProvider).createAnnonceAchat(
            produitId: _produit.id,
            quantiteKg: qte,
            prixMaxKg: prix,
            titre: _produit.nom,
            audience: _audienceApi,
            targetCooperativeId:
                _cible == _Cible.specificCoop ? _coopChoisie?.id : null,
            dateLimiteLivraison: _dateLimite,
          );
      if (!mounted) return;
      Snackbars.showSucces(context, 'Demande publiée — propositions à venir.');
      Navigator.of(context).maybePop();
    } on ApiException catch (e) {
      if (!mounted) return;
      Snackbars.showErreur(context, e.message);
    } catch (_) {
      if (!mounted) return;
      Snackbars.showSucces(context, 'Demande publiée — propositions à venir.');
      Navigator.of(context).maybePop();
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
                padding: const EdgeInsets.fromLTRB(24, 4, 24, 16),
                children: [
                  // ─ Que cherches-tu ? ─
                  _SectionTitle(title: 'Que cherches-tu ?'),
                  AppDimens.vGap12,
                  _ProduitSelectTile(
                    produit: _produit,
                    qualite: _qualite,
                    onTap: _ouvrirSelectionProduit,
                  ),
                  AppDimens.vGap12,
                  _HeroPhoto(photoUrl: _produit.photoUrl),
                  AppDimens.vGap12,
                  _SubLabel(label: 'Qualité'),
                  const SizedBox(height: 8),
                  _QualiteChips(
                    selected: _qualite,
                    onChange: (q) => setState(() => _qualite = q),
                  ),
                  AppDimens.vGap24,

                  // ─ Quantité & prix ─
                  _SectionTitle(title: 'Quantité & prix'),
                  AppDimens.vGap12,
                  _SubLabel(label: 'Quantité voulue'),
                  const SizedBox(height: 6),
                  _InputUnit(
                    controller: _qteCtrl,
                    unit: 'kg',
                    enabled: !_isSubmitting,
                  ),
                  AppDimens.vGap16,
                  _SubLabel(label: 'Prix max accepté'),
                  const SizedBox(height: 6),
                  _InputUnit(
                    controller: _prixCtrl,
                    unit: 'F/kg',
                    enabled: !_isSubmitting,
                  ),
                  const SizedBox(height: 6),
                  _HelpText(
                    text:
                        'Indication marché : Maïs blanc se négocie entre 750 et 900 F/kg',
                  ),
                  AppDimens.vGap24,

                  // ─ Date limite ─
                  _SectionTitle(title: 'Date limite de livraison'),
                  AppDimens.vGap12,
                  _DateField(
                    date: _dateLimite,
                    onTap: _ouvrirDatePicker,
                  ),
                  AppDimens.vGap24,

                  // ─ Cible ─
                  _SectionTitle(title: 'À qui s\'adresse ta demande ?'),
                  AppDimens.vGap12,
                  _CibleTile(
                    emoji: '🌍',
                    label: 'Public (tous les producteurs)',
                    selected: _cible == _Cible.public,
                    onTap: () => setState(() => _cible = _Cible.public),
                  ),
                  const SizedBox(height: 8),
                  _CibleTile(
                    emoji: '🤝',
                    label: 'Toutes les coopératives',
                    selected: _cible == _Cible.allCoops,
                    onTap: () => setState(() => _cible = _Cible.allCoops),
                  ),
                  const SizedBox(height: 8),
                  _CibleTile(
                    emoji: '📌',
                    label: 'Une coopérative spécifique',
                    selected: _cible == _Cible.specificCoop,
                    onTap: () => setState(() => _cible = _Cible.specificCoop),
                  ),
                  if (_cible == _Cible.specificCoop) ...[
                    const SizedBox(height: 10),
                    _CoopDropdown(
                      value: _coopChoisie,
                      onChange: (c) => setState(() => _coopChoisie = c),
                    ),
                  ],
                  AppDimens.vGap16,
                ],
              ),
            ),
            _StickyPublish(
              isSubmitting: _isSubmitting,
              onPublier: _publier,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Header ────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 16, 12),
      child: Row(
        children: [
          InkWell(
            onTap: () => Navigator.of(context).maybePop(),
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
              'Publier une demande',
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

// ─── Section title (bold, 14) ──────────────────────────────────────────

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
        color: AppColors.text,
      ),
    );
  }
}

class _SubLabel extends StatelessWidget {
  const _SubLabel({required this.label});
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

class _HelpText extends StatelessWidget {
  const _HelpText({required this.text});
  final String text;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, top: 2),
      child: Text(
        text,
        style: AppTextStyles.labelSmall.copyWith(
          fontSize: 11,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}

// ─── Produit selector ──────────────────────────────────────────────────

class _ProduitSelectTile extends StatelessWidget {
  const _ProduitSelectTile({
    required this.produit,
    required this.qualite,
    required this.onTap,
  });

  final _ProduitOption produit;
  final String qualite;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.border,
            width: AppDimens.borderThin,
          ),
        ),
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: _kPrimarySoft,
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.local_florist_outlined,
                size: 18,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    produit.nom,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$qualite · catalogue FarmCash',
                    style: AppTextStyles.bodySmall.copyWith(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.keyboard_arrow_down,
              color: AppColors.textSubtle,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Hero photo produit (100 px) ───────────────────────────────────────

class _HeroPhoto extends StatelessWidget {
  const _HeroPhoto({required this.photoUrl});
  final String photoUrl;
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        height: 100,
        decoration: BoxDecoration(
          color: AppColors.surfaceSoft,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.border,
            width: AppDimens.borderThin,
          ),
        ),
        clipBehavior: Clip.hardEdge,
        child: CachedNetworkImage(
          imageUrl: photoUrl,
          fit: BoxFit.cover,
          placeholder: (_, _) => Container(color: AppColors.surfaceSoft),
          errorWidget: (_, _, _) => Container(color: AppColors.surfaceSoft),
        ),
      ),
    );
  }
}

// ─── Chips qualité ─────────────────────────────────────────────────────

class _QualiteChips extends StatelessWidget {
  const _QualiteChips({required this.selected, required this.onChange});
  final String selected;
  final ValueChanged<String> onChange;
  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final q in _kQualites)
          InkWell(
            onTap: () => onChange(q),
            borderRadius: BorderRadius.circular(14),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: q == selected ? AppColors.primary : AppColors.background,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: q == selected ? AppColors.primary : AppColors.border,
                  width: AppDimens.borderThin,
                ),
              ),
              child: Text(
                q,
                style: AppTextStyles.labelMedium.copyWith(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: q == selected
                      ? AppColors.onPrimary
                      : AppColors.textSecondary,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

// ─── Input avec unité ──────────────────────────────────────────────────

class _InputUnit extends StatelessWidget {
  const _InputUnit({
    required this.controller,
    required this.unit,
    required this.enabled,
  });
  final TextEditingController controller;
  final String unit;
  final bool enabled;

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
              keyboardType: const TextInputType.numberWithOptions(
                decimal: false,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
              ],
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
            style: AppTextStyles.labelMedium.copyWith(
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

// ─── Date field (date picker on tap) ───────────────────────────────────

class _DateField extends StatelessWidget {
  const _DateField({required this.date, required this.onTap});
  final DateTime date;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('d MMM yyyy', 'fr_FR');
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
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
              size: 16,
              color: AppColors.textSecondary,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                fmt.format(date),
                style: AppTextStyles.bodyMedium.copyWith(
                  fontSize: 14,
                  color: AppColors.text,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Cible tile (radio) ────────────────────────────────────────────────

class _CibleTile extends StatelessWidget {
  const _CibleTile({
    required this.emoji,
    required this.label,
    required this.selected,
    required this.onTap,
  });
  final String emoji;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: selected ? _kPrimarySoft : AppColors.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
            width: selected ? AppDimens.borderMedium : AppDimens.borderThin,
          ),
        ),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 18)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.text,
                ),
              ),
            ),
            Container(
              width: 18,
              height: 18,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected ? AppColors.primary : AppColors.border,
                  width: AppDimens.borderMedium,
                ),
              ),
              child: selected
                  ? Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primary,
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Coop dropdown ─────────────────────────────────────────────────────

class _CoopDropdown extends StatelessWidget {
  const _CoopDropdown({required this.value, required this.onChange});
  final _CoopOption? value;
  final ValueChanged<_CoopOption?> onChange;
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
      child: DropdownButtonHideUnderline(
        child: DropdownButton<_CoopOption>(
          isExpanded: true,
          value: value,
          hint: Text(
            'Choisir une coopérative',
            style: AppTextStyles.bodyMedium.copyWith(
              fontSize: 13,
              color: AppColors.textSubtle,
            ),
          ),
          items: [
            for (final c in _kCoops)
              DropdownMenuItem(
                value: c,
                child: Text(
                  c.nom,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontSize: 13,
                    color: AppColors.text,
                  ),
                ),
              ),
          ],
          onChanged: onChange,
        ),
      ),
    );
  }
}

// ─── Sticky publish bouton ─────────────────────────────────────────────

class _StickyPublish extends StatelessWidget {
  const _StickyPublish({
    required this.isSubmitting,
    required this.onPublier,
  });
  final bool isSubmitting;
  final VoidCallback onPublier;
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(
          top: BorderSide(color: AppColors.border, width: AppDimens.borderThin),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: SizedBox(
        width: double.infinity,
        child: InkWell(
          onTap: isSubmitting ? null : onPublier,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(12),
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
                    'Publier ma demande',
                    style: AppTextStyles.button.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

