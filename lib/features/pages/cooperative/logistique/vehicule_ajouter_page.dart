import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../api_client/api_exception.dart';
import '../../../../routing/route_names.dart';
import '../../../../services/providers.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';
import '../../../widgets/communs/snackbars.dart';

const BorderRadius _kBrCard12 = BorderRadius.all(Radius.circular(12));

/// Types de véhicules acceptés côté backend coop (alignés sur la
/// nomenclature transporteur).
const List<({String label, String apiType})> _kTypes = [
  (label: 'Pick-up', apiType: 'PICKUP'),
  (label: 'Camion 3.5 t', apiType: 'CAMION_3_5T'),
  (label: 'Camion 8 t', apiType: 'CAMION_8T'),
  (label: 'Camion 15 t', apiType: 'CAMION_15T'),
];

/// Formulaire d'ajout d'un véhicule au parc coopérative.
class VehiculeAjouterCooperativePage extends ConsumerStatefulWidget {
  const VehiculeAjouterCooperativePage({super.key});

  @override
  ConsumerState<VehiculeAjouterCooperativePage> createState() =>
      _VehiculeAjouterCooperativePageState();
}

class _VehiculeAjouterCooperativePageState
    extends ConsumerState<VehiculeAjouterCooperativePage> {
  int _typeIndex = 0;
  final TextEditingController _immatCtrl = TextEditingController();
  final TextEditingController _marqueCtrl = TextEditingController();
  final TextEditingController _chargeCtrl = TextEditingController();
  final TextEditingController _chauffeurNomCtrl = TextEditingController();
  final TextEditingController _chauffeurPhoneCtrl = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _immatCtrl.dispose();
    _marqueCtrl.dispose();
    _chargeCtrl.dispose();
    _chauffeurNomCtrl.dispose();
    _chauffeurPhoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _enregistrer() async {
    if (_busy) return;
    final chargeText = _chargeCtrl.text.replaceAll(',', '.').trim();
    final charge = double.tryParse(chargeText);
    if (charge == null || charge <= 0) {
      Snackbars.showErreur(context, 'Charge max invalide');
      return;
    }
    setState(() => _busy = true);
    try {
      await ref.read(coopLogisticsServiceProvider).createVehicle(
            type: _kTypes[_typeIndex].apiType,
            chargeMaxKg: charge,
            immatriculation: _immatCtrl.text.trim().isEmpty
                ? null
                : _immatCtrl.text.trim(),
            marque: _marqueCtrl.text.trim().isEmpty
                ? null
                : _marqueCtrl.text.trim(),
            chauffeurNom: _chauffeurNomCtrl.text.trim().isEmpty
                ? null
                : _chauffeurNomCtrl.text.trim(),
            chauffeurPhone: _chauffeurPhoneCtrl.text.trim().isEmpty
                ? null
                : _chauffeurPhoneCtrl.text.trim(),
          );
      if (!mounted) return;
      Snackbars.showSucces(context, 'Véhicule ajouté');
      if (context.canPop()) context.pop();
    } on ApiException catch (e) {
      if (!mounted) return;
      Snackbars.showErreur(context, e.message);
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
                  12,
                  AppDimens.pagePaddingH,
                  AppDimens.space16,
                ),
                children: [
                  _FieldLabel('Type de véhicule'),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (int i = 0; i < _kTypes.length; i++)
                        _Chip(
                          label: _kTypes[i].label,
                          active: _typeIndex == i,
                          onTap: () => setState(() => _typeIndex = i),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _FieldLabel('Immatriculation'),
                  const SizedBox(height: 6),
                  _Input(
                    controller: _immatCtrl,
                    placeholder: '5125 AB 01',
                  ),
                  const SizedBox(height: 14),
                  _FieldLabel('Marque'),
                  const SizedBox(height: 6),
                  _Input(
                    controller: _marqueCtrl,
                    placeholder: 'Toyota, Mercedes…',
                  ),
                  const SizedBox(height: 14),
                  _FieldLabel('Charge max (kg)'),
                  const SizedBox(height: 6),
                  _Input(
                    controller: _chargeCtrl,
                    placeholder: '3500',
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _FieldLabel('Chauffeur — nom'),
                  const SizedBox(height: 6),
                  _Input(
                    controller: _chauffeurNomCtrl,
                    placeholder: 'Kouamé Konan',
                  ),
                  const SizedBox(height: 14),
                  _FieldLabel('Chauffeur — téléphone'),
                  const SizedBox(height: 6),
                  _Input(
                    controller: _chauffeurPhoneCtrl,
                    placeholder: '+225 0700000000',
                    keyboardType: TextInputType.phone,
                  ),
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
                : context.go(RouteNames.cooperativeLogistiquePath),
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
              'Ajouter un véhicule',
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
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: active ? AppColors.primary : AppColors.background,
          borderRadius: BorderRadius.circular(14),
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

class _Input extends StatelessWidget {
  const _Input({
    required this.controller,
    this.placeholder = '',
    this.keyboardType,
    this.inputFormatters,
  });

  final TextEditingController controller;
  final String placeholder;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
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
    );
  }
}

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
                  'Ajouter au parc',
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
