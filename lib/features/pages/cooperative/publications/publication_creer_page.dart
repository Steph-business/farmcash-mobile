import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';

/// Création d'une publication coopérative — étape 1/2.
///
/// Maquette : `mockups/cooperative/publication_creer.html`. Le formulaire
/// permet à la coop de publier un lot sur le marché à partir de son stock
/// (sans agrégation membres ici). Étape 2 (photos avancées + audience)
/// est annoncée via snackbar pour l'instant.
class PublicationCreerPage extends StatefulWidget {
  const PublicationCreerPage({super.key});

  @override
  State<PublicationCreerPage> createState() => _PublicationCreerPageState();
}

class _PublicationCreerPageState extends State<PublicationCreerPage> {
  final _quantiteCtrl = TextEditingController(text: '500');
  final _prixCtrl = TextEditingController(text: '350');
  int _qualiteIndex = 0;

  static const List<String> _qualites = [
    'Standard',
    'Premium',
    'Bio',
    'Équitable',
  ];

  @override
  void dispose() {
    _quantiteCtrl.dispose();
    _prixCtrl.dispose();
    super.dispose();
  }

  void _suivant() {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Étape 2 à venir')),
    );
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
                  // ── Étape ──────────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: Text(
                      'Étape 1/2',
                      style: AppTextStyles.labelSmall.copyWith(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),

                  // ── Produit à publier ──────────────────────────────
                  _SectionLabel(label: 'Produit à publier'),
                  AppDimens.vGap8,
                  const _ProduitSelector(),
                  AppDimens.vGap24,

                  // ── Quantité à publier ─────────────────────────────
                  _SectionLabel(label: 'Quantité à publier'),
                  AppDimens.vGap8,
                  _InputBig(
                    controller: _quantiteCtrl,
                    suffix: 'kg',
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: false,
                    ),
                    formatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                    ],
                  ),
                  AppDimens.vGap24,

                  // ── Prix par kg ────────────────────────────────────
                  _SectionLabel(label: 'Prix par kg'),
                  AppDimens.vGap8,
                  _InputBig(
                    controller: _prixCtrl,
                    suffix: 'F CFA / kg',
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: false,
                    ),
                    formatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                    ],
                  ),
                  AppDimens.vGap24,

                  // ── Qualité ────────────────────────────────────────
                  _SectionLabel(label: 'Qualité'),
                  AppDimens.vGap8,
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: List.generate(_qualites.length, (i) {
                      return _ChipQualite(
                        label: _qualites[i],
                        selected: _qualiteIndex == i,
                        onTap: () => setState(() => _qualiteIndex = i),
                      );
                    }),
                  ),
                  AppDimens.vGap24,

                  // ── Photos ─────────────────────────────────────────
                  _SectionLabel(label: 'Photos'),
                  AppDimens.vGap8,
                  const _GridPhotosVides(),
                ],
              ),
            ),
            _Sticky(onTap: _suivant),
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

// ─── Section label ───────────────────────────────────────────────────────

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

// ─── Produit selector (chevron) ──────────────────────────────────────────

class _ProduitSelector extends StatelessWidget {
  const _ProduitSelector();

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
      padding: const EdgeInsets.fromLTRB(16, 14, 14, 14),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Maïs grain blanc',
                  style: AppTextStyles.titleLarge.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '1 200 kg disponible dans 3 entrepôts',
                  style: AppTextStyles.bodySmall.copyWith(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
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
    );
  }
}

// ─── Input grand (numérique + suffix) ────────────────────────────────────

class _InputBig extends StatelessWidget {
  const _InputBig({
    required this.controller,
    required this.suffix,
    this.keyboardType,
    this.formatters,
  });

  final TextEditingController controller;
  final String suffix;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? formatters;

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
              keyboardType: keyboardType,
              inputFormatters: formatters,
              style: AppTextStyles.displayLarge.copyWith(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppColors.text,
              ),
              decoration: const InputDecoration(
                border: InputBorder.none,
                focusedBorder: InputBorder.none,
                enabledBorder: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                isDense: true,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            suffix,
            style: AppTextStyles.bodyMedium.copyWith(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Chip qualité (rond, primary plein si actif) ─────────────────────────

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
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.background,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
            width: AppDimens.borderThin,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: selected ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

// ─── Grille photos (3 slots vides) ───────────────────────────────────────

class _GridPhotosVides extends StatelessWidget {
  const _GridPhotosVides();

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      children: const [
        _SlotPhotoVide(),
        _SlotPhotoVide(),
        _SlotPhotoVide(),
      ],
    );
  }
}

class _SlotPhotoVide extends StatelessWidget {
  const _SlotPhotoVide();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceSoft,
        borderRadius: BorderRadius.circular(AppDimens.radiusCard),
        border: Border.all(
          color: AppColors.borderStrong,
          width: AppDimens.borderThin,
          style: BorderStyle.solid,
        ),
      ),
      alignment: Alignment.center,
      child: const Icon(
        Icons.add,
        size: 24,
        color: AppColors.textSubtle,
      ),
    );
  }
}

// ─── Sticky bouton ───────────────────────────────────────────────────────

class _Sticky extends StatelessWidget {
  const _Sticky({required this.onTap});

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
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 12),
      child: SizedBox(
        width: double.infinity,
        child: InkWell(
          onTap: onTap,
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
            child: Text(
              'Suivant →',
              style: AppTextStyles.button.copyWith(
                fontSize: 15,
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


