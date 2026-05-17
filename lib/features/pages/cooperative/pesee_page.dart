import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../routing/route_names.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_dimens.dart';
import '../../../theme/app_text_styles.dart';
import '../../widgets/communs/snackbars.dart';

// ─── Constantes locales ─────────────────────────────────────────────────
const Color _kPrimarySoft = Color(0xFFE8F5E9);
const Color _kWarn = Color(0xFFB45309);
const Color _kErrorSoftBg = Color(0xFFFEF2F2);
const Color _kErrorSoftBorder = Color(0xFFFEE2E2);

const BorderRadius _kBrCard12 = BorderRadius.all(Radius.circular(12));
const BorderRadius _kBrCard14 = BorderRadius.all(Radius.circular(14));
const BorderRadius _kBrChip = BorderRadius.all(Radius.circular(14));

const List<String> _kQualites = ['Standard', 'Premium', 'Bio', 'Équitable'];

// Poids "annoncé" — pour calculer l'écart.
const double _kPoidsAnnonce = 250;

/// Page de pesée d'une livraison farmer arrivée à la coopérative.
/// Reproduction fidèle de `mockups/cooperative/pesee.html`.
class PeseePage extends StatefulWidget {
  const PeseePage({super.key, required this.livraisonId});

  final String livraisonId;

  @override
  State<PeseePage> createState() => _PeseePageState();
}

class _PeseePageState extends State<PeseePage> {
  final TextEditingController _poidsCtrl = TextEditingController(text: '245');
  final TextEditingController _noteCtrl = TextEditingController();
  int _qualiteIndex = 0;

  @override
  void initState() {
    super.initState();
    _poidsCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _poidsCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  double? get _poidsMesure {
    final raw = _poidsCtrl.text.trim().replaceAll(',', '.');
    if (raw.isEmpty) return null;
    return double.tryParse(raw);
  }

  double? get _ecart {
    final p = _poidsMesure;
    if (p == null) return null;
    return p - _kPoidsAnnonce;
  }

  String get _ecartLabel {
    final e = _ecart;
    if (e == null) return 'Écart annoncé / mesuré : —';
    final signe = e >= 0 ? '+' : '−';
    final abs = e.abs();
    final fmt = abs == abs.roundToDouble()
        ? abs.toStringAsFixed(0)
        : abs.toStringAsFixed(1);
    return 'Écart annoncé / mesuré : $signe$fmt kg';
  }

  /// Vert si écart > -10kg (perte tolérée), sinon orange.
  Color get _ecartColor {
    final e = _ecart;
    if (e == null) return AppColors.textSecondary;
    return e > -10 ? AppColors.primary : _kWarn;
  }

  void _rejeter() {
    Snackbars.showInfo(context, 'Livraison rejetée');
    if (context.canPop()) context.pop();
  }

  void _valider() {
    Snackbars.showSucces(context, 'Pesée validée. Notification envoyée.');
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
                  const _HeroCard(),
                  const SizedBox(height: 20),
                  // ── Section poids réel ──────────────────────────────
                  _Label('Poids réel mesuré'),
                  const SizedBox(height: 10),
                  _WeightBox(
                    controller: _poidsCtrl,
                    ecartLabel: _ecartLabel,
                    ecartColor: _ecartColor,
                  ),
                  const SizedBox(height: 22),
                  // ── Section qualité ─────────────────────────────────
                  _Label('Qualité observée'),
                  const SizedBox(height: 10),
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
                  const SizedBox(height: 22),
                  // ── Section photo ───────────────────────────────────
                  _Label('Photo de la livraison (optionnel)'),
                  const SizedBox(height: 10),
                  _PhotoSlot(onTap: () {}),
                  const SizedBox(height: 22),
                  // ── Section note ────────────────────────────────────
                  _Label('Note interne (optionnel)'),
                  const SizedBox(height: 10),
                  _NoteField(controller: _noteCtrl),
                ],
              ),
            ),
            _StickyButtons(onRejeter: _rejeter, onValider: _valider),
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

// ─── Hero card avec photo full-width 140px ──────────────────────────────

class _HeroCard extends StatelessWidget {
  const _HeroCard();

  @override
  Widget build(BuildContext context) {
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
            // Cover photo 140px
            SizedBox(
              height: 140,
              width: double.infinity,
              child: CachedNetworkImage(
                imageUrl:
                    'https://images.unsplash.com/photo-1601493700631-2b16ec4b4716'
                    '?w=600&h=300&fit=crop&auto=format',
                fit: BoxFit.cover,
                placeholder: (_, __) => const ColoredBox(color: _kPrimarySoft),
                errorWidget: (_, __, ___) =>
                    const ColoredBox(color: _kPrimarySoft),
              ),
            ),
            // Body
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Yao Konan',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.titleSmall.copyWith(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Annoncé : 250 kg · Qualité Standard',
                    style: AppTextStyles.bodySmall.copyWith(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
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

// ─── Label de section ───────────────────────────────────────────────────

class _Label extends StatelessWidget {
  const _Label(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: AppTextStyles.titleSmall.copyWith(
        fontSize: 13,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

// ─── WeightBox : input grand centré + écart ─────────────────────────────

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
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 18),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: _kBrCard14,
        border: Border.all(
          color: AppColors.border,
          width: AppDimens.borderThin,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              SizedBox(
                width: 130,
                child: TextField(
                  controller: controller,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                  ],
                  textAlign: TextAlign.right,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                    hintText: '0',
                  ),
                  style: AppTextStyles.displaySmall.copyWith(
                    fontFamily: 'Poppins',
                    fontSize: 36,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -1,
                    height: 1,
                    color: AppColors.text,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'kg',
                style: AppTextStyles.titleSmall.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            ecartLabel,
            style: AppTextStyles.labelMedium.copyWith(
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

// ─── Chip qualité ───────────────────────────────────────────────────────

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

// ─── Photo slot 80×80 ───────────────────────────────────────────────────

class _PhotoSlot extends StatelessWidget {
  const _PhotoSlot({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: _kBrCard12,
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: AppColors.surfaceSoft,
          borderRadius: _kBrCard12,
          border: Border.all(
            color: AppColors.borderStrong,
            width: AppDimens.borderThin,
          ),
        ),
        child: const Center(
          child: Icon(
            Icons.add,
            size: 22,
            color: AppColors.textSubtle,
          ),
        ),
      ),
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
          hintText: 'Observations sur la livraison…',
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

// ─── Sticky bouton bas : Rejeter / Valider + note info ──────────────────

class _StickyButtons extends StatelessWidget {
  const _StickyButtons({required this.onRejeter, required this.onValider});

  final VoidCallback onRejeter;
  final VoidCallback onValider;

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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: OutlinedButton(
                    onPressed: onRejeter,
                    style: OutlinedButton.styleFrom(
                      backgroundColor: _kErrorSoftBg,
                      foregroundColor: AppColors.error,
                      side: const BorderSide(
                        color: _kErrorSoftBorder,
                        width: AppDimens.borderThin,
                      ),
                      shape: const RoundedRectangleBorder(
                        borderRadius: _kBrCard12,
                      ),
                    ),
                    child: Text(
                      'Rejeter',
                      style: AppTextStyles.labelLarge.copyWith(
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
                child: SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: onValider,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.onPrimary,
                      elevation: 0,
                      shape: const RoundedRectangleBorder(
                        borderRadius: _kBrCard12,
                      ),
                    ),
                    child: Text(
                      'Valider la pesée',
                      style: AppTextStyles.labelLarge.copyWith(
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
          const SizedBox(height: 10),
          Text(
            'Le farmer recevra une notification dès validation.',
            textAlign: TextAlign.center,
            style: AppTextStyles.labelSmall.copyWith(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

