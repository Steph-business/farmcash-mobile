import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../routing/route_names.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_dimens.dart';
import '../../../theme/app_text_styles.dart';
import '../../widgets/communs/snackbars.dart';

// ─── Couleurs / radius locaux alignés sur la maquette ─────────────────────
const Color _kPrimarySoft = Color(0xFFE8F5E9);

const BorderRadius _kBrCard12 = BorderRadius.all(Radius.circular(12));
const BorderRadius _kBrChip14 = BorderRadius.all(Radius.circular(14));

const List<String> _kTypes = [
  'Pick-up',
  'Camion 3.5t',
  'Camion 8t',
  'Camion 15t',
];

/// Formulaire « Ajouter mon véhicule » côté transporteur (solo).
/// Reproduction fidèle de `mockups/transporteur/vehicule_ajouter.html`.
class VehiculeAjouterTransporteurPage extends StatefulWidget {
  const VehiculeAjouterTransporteurPage({super.key});

  @override
  State<VehiculeAjouterTransporteurPage> createState() =>
      _VehiculeAjouterTransporteurPageState();
}

class _VehiculeAjouterTransporteurPageState
    extends State<VehiculeAjouterTransporteurPage> {
  final TextEditingController _immatCtrl = TextEditingController();
  final TextEditingController _marqueCtrl = TextEditingController();
  final TextEditingController _chargeCtrl = TextEditingController(text: '1200');
  final TextEditingController _volumeCtrl = TextEditingController();

  int _typeIndex = 0; // Pick-up actif par défaut

  @override
  void dispose() {
    _immatCtrl.dispose();
    _marqueCtrl.dispose();
    _chargeCtrl.dispose();
    _volumeCtrl.dispose();
    super.dispose();
  }

  void _enregistrer() {
    Snackbars.showSucces(context, 'Véhicule enregistré');
    if (context.canPop()) context.pop();
  }

  void _info(String message) => Snackbars.showInfo(context, message);

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
                  // ── Section "Photo du véhicule" ───────────────────────
                  const _SectionTitle('Photo du véhicule'),
                  AppDimens.vGap12,
                  _PhotoBanner(
                    onTap: () => _info('Prendre une photo — à venir'),
                  ),
                  AppDimens.vGap24,

                  // ── Section "Identification" ──────────────────────────
                  const _SectionTitle('Identification'),
                  AppDimens.vGap12,
                  const _FieldLabel('Immatriculation'),
                  const SizedBox(height: 6),
                  _InputField(
                    controller: _immatCtrl,
                    placeholder: '2345 AB 01',
                    upper: true,
                  ),
                  const SizedBox(height: 14),
                  const _FieldLabel('Marque & modèle'),
                  const SizedBox(height: 6),
                  _InputField(
                    controller: _marqueCtrl,
                    placeholder: 'Toyota Hilux 2018',
                  ),
                  const SizedBox(height: 14),
                  const _FieldLabel('Type'),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (int i = 0; i < _kTypes.length; i++)
                        _TypeChip(
                          label: _kTypes[i],
                          active: _typeIndex == i,
                          onTap: () => setState(() => _typeIndex = i),
                        ),
                    ],
                  ),
                  AppDimens.vGap24,

                  // ── Section "Capacité" ────────────────────────────────
                  const _SectionTitle('Capacité'),
                  AppDimens.vGap12,
                  const _FieldLabel('Charge utile'),
                  const SizedBox(height: 6),
                  _InputWithUnit(
                    controller: _chargeCtrl,
                    unit: 'kg',
                    placeholder: '0',
                  ),
                  const SizedBox(height: 14),
                  const _FieldLabel('Volume utile (optionnel)'),
                  const SizedBox(height: 6),
                  _InputWithUnit(
                    controller: _volumeCtrl,
                    unit: 'm³',
                    placeholder: '0',
                  ),
                  AppDimens.vGap24,

                  // ── Section "Documents (recommandé)" ──────────────────
                  const _SectionTitle('Documents (recommandé)'),
                  AppDimens.vGap12,
                  _DocRow(
                    titre: 'Carte grise',
                    sous: 'PDF ou photo',
                    onTap: () => _info('Ajouter la carte grise — à venir'),
                  ),
                  const SizedBox(height: 10),
                  _DocRow(
                    titre: 'Assurance',
                    sous: 'PDF ou photo',
                    onTap: () => _info("Ajouter l'assurance — à venir"),
                  ),
                  const SizedBox(height: 10),
                  _DocRow(
                    titre: 'Visite technique',
                    sous: 'PDF ou photo',
                    onTap: () => _info('Ajouter la visite technique — à venir'),
                  ),
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

// ─── Header (back + titre) ────────────────────────────────────────────────

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
                : context.go(RouteNames.transporteurProfilSettingsPath),
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
              'Ajouter mon véhicule',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.titleSmall.copyWith(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                height: 1.2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Section title / Field label ──────────────────────────────────────────

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

// ─── Photo banner (slot dashed) ───────────────────────────────────────────

class _PhotoBanner extends StatelessWidget {
  const _PhotoBanner({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: _kBrCard12,
      child: Container(
        height: 140,
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.surfaceSoft,
          borderRadius: _kBrCard12,
          border: Border.all(
            color: AppColors.borderStrong,
            width: AppDimens.borderThin,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.background,
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.border,
                  width: AppDimens.borderThin,
                ),
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.add,
                size: 22,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Prendre une photo ou choisir',
              style: AppTextStyles.labelMedium.copyWith(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Inputs ───────────────────────────────────────────────────────────────

class _InputField extends StatelessWidget {
  const _InputField({
    required this.controller,
    required this.placeholder,
    this.upper = false,
  });

  final TextEditingController controller;
  final String placeholder;
  final bool upper;

  @override
  Widget build(BuildContext context) {
    final baseStyle = AppTextStyles.bodyMedium.copyWith(
      fontSize: 14,
      color: AppColors.text,
    );
    final textStyle = upper
        ? baseStyle.copyWith(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            letterSpacing: 1,
          )
        : baseStyle;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: _kBrCard12,
        border: Border.all(
          color: AppColors.border,
          width: AppDimens.borderThin,
        ),
      ),
      child: TextField(
        controller: controller,
        textCapitalization:
            upper ? TextCapitalization.characters : TextCapitalization.none,
        inputFormatters: upper
            ? [
                FilteringTextInputFormatter.allow(
                  RegExp(r'[A-Za-z0-9 ]'),
                ),
                _UpperCaseFormatter(),
              ]
            : null,
        style: textStyle,
        decoration: InputDecoration(
          hintText: placeholder,
          border: InputBorder.none,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
          hintStyle: textStyle.copyWith(color: AppColors.textSubtle),
        ),
      ),
    );
  }
}

class _UpperCaseFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return newValue.copyWith(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}

class _InputWithUnit extends StatelessWidget {
  const _InputWithUnit({
    required this.controller,
    required this.unit,
    required this.placeholder,
  });

  final TextEditingController controller;
  final String unit;
  final String placeholder;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surface,
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
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
              ],
              decoration: InputDecoration(
                hintText: placeholder,
                border: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                hintStyle: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSubtle,
                ),
              ),
              style: AppTextStyles.bodyMedium.copyWith(
                fontSize: 14,
                color: AppColors.text,
              ),
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

// ─── Type chip ────────────────────────────────────────────────────────────

class _TypeChip extends StatelessWidget {
  const _TypeChip({
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
      borderRadius: _kBrChip14,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: active ? AppColors.primary : AppColors.surface,
          borderRadius: _kBrChip14,
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

// ─── Doc row (bouton "Ajouter" plein bord vert) ───────────────────────────

class _DocRow extends StatelessWidget {
  const _DocRow({
    required this.titre,
    required this.sous,
    required this.onTap,
  });

  final String titre;
  final String sous;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: _kBrCard12,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surface,
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
                Icons.description_outlined,
                size: 18,
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
                    titre,
                    style: AppTextStyles.titleSmall.copyWith(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    sous,
                    style: AppTextStyles.bodySmall.copyWith(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.primary,
                  width: AppDimens.borderThin,
                ),
              ),
              child: Text(
                'Ajouter',
                style: AppTextStyles.labelSmall.copyWith(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Sticky bouton ────────────────────────────────────────────────────────

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
            'Enregistrer mon véhicule',
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

