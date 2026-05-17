import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../../routing/route_names.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';
import '../../../widgets/communs/snackbars.dart';

// ─── Constantes locales ─────────────────────────────────────────────────
const Color _kPrimarySoft = Color(0xFFE8F5E9);
const BorderRadius _kBrCard12 = BorderRadius.all(Radius.circular(12));
const BorderRadius _kBrChip = BorderRadius.all(Radius.circular(14));

const List<String> _kSources = [
  'Depuis une livraison farmer',
  'Lot externe (achat direct)',
];

const List<String> _kQualites = ['Standard', 'Premium', 'Bio', 'Équitable'];

/// Formulaire de réception d'un nouveau lot dans un entrepôt.
/// Reproduction fidèle de `mockups/cooperative/reception_lot.html`.
class ReceptionLotPage extends StatefulWidget {
  const ReceptionLotPage({super.key});

  @override
  State<ReceptionLotPage> createState() => _ReceptionLotPageState();
}

class _ReceptionLotPageState extends State<ReceptionLotPage> {
  final TextEditingController _qteCtrl = TextEditingController(text: '245');
  final TextEditingController _noteCtrl = TextEditingController();
  // Réf. auto-générée (read-only)
  static const String _refNum = 'LOT-2026-0142';
  // Date de réception (aujourd'hui)
  DateTime _date = DateTime.now();
  int _sourceIndex = 0;
  int _qualiteIndex = 0;

  @override
  void dispose() {
    _qteCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  String get _dateLabel {
    const mois = [
      'janv.',
      'févr.',
      'mars',
      'avr.',
      'mai',
      'juin',
      'juil.',
      'août',
      'sept.',
      'oct.',
      'nov.',
      'déc.',
    ];
    // Format proche de "16 mai 2026" — la maquette utilise "mai" en plein.
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
    // On garde la version courte pour les autres mois mais "mai" est court.
    final label = '${_date.day} ${moisPlein[_date.month - 1]} ${_date.year}';
    // mois inutilisé (réservé pour cas futurs).
    mois.length;
    return label;
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

  void _copierRef() {
    Clipboard.setData(const ClipboardData(text: _refNum));
    Snackbars.showInfo(context, 'Numéro de référence copié');
  }

  void _enregistrer() {
    Snackbars.showSucces(context, 'Lot $_refNum enregistré');
    if (context.canPop()) context.pop();
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
                  // ── Section "Source du lot" ─────────────────────────
                  _SectionTitle('Source du lot'),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (int i = 0; i < _kSources.length; i++)
                        _Chip(
                          label: _kSources[i],
                          active: _sourceIndex == i,
                          onTap: () => setState(() => _sourceIndex = i),
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // Sélecteur farmer mock
                  _SelectorFarmer(
                    onTap: () => Snackbars.showInfo(
                      context,
                      'Sélection farmer — à venir',
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ── Section "Détails du lot" ────────────────────────
                  _SectionTitle('Détails du lot'),
                  const SizedBox(height: 12),
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
                          label: _kQualites[i],
                          active: _qualiteIndex == i,
                          onTap: () => setState(() => _qualiteIndex = i),
                        ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _FieldLabel('Date de réception'),
                  const SizedBox(height: 6),
                  _InputDate(label: _dateLabel, onTap: _pickDate),
                  const SizedBox(height: 14),
                  _FieldLabel('Numéro de référence'),
                  const SizedBox(height: 6),
                  _InputReadOnlyRef(value: _refNum, onCopy: _copierRef),
                  const SizedBox(height: 20),

                  // ── Section Photos ──────────────────────────────────
                  _SectionTitle('Photos du lot (recommandé)'),
                  const SizedBox(height: 12),
                  const _PhotoGrid(),
                  const SizedBox(height: 20),

                  // ── Section Note ────────────────────────────────────
                  _SectionTitle('Note (optionnel)'),
                  const SizedBox(height: 12),
                  _NoteField(controller: _noteCtrl),
                ],
              ),
            ),
            _StickyButton(onTap: _enregistrer),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Réceptionner un lot',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.titleSmall.copyWith(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Entrepôt Abidjan-Treichville',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
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

// ─── Sélecteur farmer ───────────────────────────────────────────────────

class _SelectorFarmer extends StatelessWidget {
  const _SelectorFarmer({required this.onTap});

  final VoidCallback onTap;

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
            ClipOval(
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: AppColors.border,
                    width: AppDimens.borderThin,
                  ),
                  shape: BoxShape.circle,
                ),
                child: CachedNetworkImage(
                  imageUrl:
                      'https://images.unsplash.com/photo-1531123897727-8f129e1688ce'
                      '?w=200&h=200&fit=crop&auto=format',
                  fit: BoxFit.cover,
                  placeholder: (_, __) =>
                      const ColoredBox(color: _kPrimarySoft),
                  errorWidget: (_, __, ___) =>
                      const ColoredBox(color: _kPrimarySoft),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Yao Konan',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.titleSmall.copyWith(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Maïs blanc · 250 kg disponible',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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
  final VoidCallback onTap;

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

class _InputReadOnlyRef extends StatelessWidget {
  const _InputReadOnlyRef({required this.value, required this.onCopy});

  final String value;
  final VoidCallback onCopy;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceSoft,
        borderRadius: _kBrCard12,
        border: Border.all(
          color: AppColors.border,
          width: AppDimens.borderThin,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.bodyMedium.copyWith(
                fontFamily: 'Poppins',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          InkWell(
            onTap: onCopy,
            borderRadius: BorderRadius.circular(6),
            child: const Padding(
              padding: EdgeInsets.all(4),
              child: Icon(
                Icons.content_copy_outlined,
                size: 16,
                color: AppColors.textSubtle,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Photo grid ─────────────────────────────────────────────────────────

class _PhotoGrid extends StatelessWidget {
  const _PhotoGrid();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (int i = 0; i < 3; i++) ...[
          Expanded(child: _PhotoSlot(onTap: () {})),
          if (i != 2) const SizedBox(width: 10),
        ],
      ],
    );
  }
}

class _PhotoSlot extends StatelessWidget {
  const _PhotoSlot({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: InkWell(
        onTap: onTap,
        borderRadius: _kBrCard12,
        child: DottedBox(
          color: AppColors.borderStrong,
          radius: _kBrCard12,
          background: AppColors.surfaceSoft,
          child: const Center(
            child: Icon(
              Icons.add,
              size: 22,
              color: AppColors.textSubtle,
            ),
          ),
        ),
      ),
    );
  }
}

/// Boîte avec bordure pleine (simulant le dashed du HTML).
class DottedBox extends StatelessWidget {
  const DottedBox({
    super.key,
    required this.color,
    required this.radius,
    required this.background,
    required this.child,
  });

  final Color color;
  final BorderRadius radius;
  final Color background;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: background,
        borderRadius: radius,
        border: Border.all(color: color, width: AppDimens.borderThin),
      ),
      child: child,
    );
  }
}

// ─── Note ───────────────────────────────────────────────────────────────

class _NoteField extends StatelessWidget {
  const _NoteField({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: _kBrCard12,
        border: Border.all(
          color: AppColors.border,
          width: AppDimens.borderThin,
        ),
      ),
      child: TextField(
        controller: controller,
        minLines: 2,
        maxLines: 2,
        decoration: InputDecoration(
          hintText: 'Observations sur le lot…',
          border: InputBorder.none,
          isDense: true,
          contentPadding: EdgeInsets.zero,
          hintStyle: AppTextStyles.bodySmall.copyWith(
            fontSize: 13,
            color: AppColors.textSubtle,
          ),
        ),
        style: AppTextStyles.bodySmall.copyWith(
          fontSize: 13,
          color: AppColors.text,
        ),
      ),
    );
  }
}

// ─── Sticky bouton ──────────────────────────────────────────────────────

class _StickyButton extends StatelessWidget {
  const _StickyButton({required this.onTap});

  final VoidCallback onTap;

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
          onPressed: onTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.onPrimary,
            elevation: 0,
            shape: const RoundedRectangleBorder(borderRadius: _kBrCard12),
          ),
          child: Text(
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

