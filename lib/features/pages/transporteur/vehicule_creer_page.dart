import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../api_client/api_exception.dart';
import '../../../services/providers.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_dimens.dart';
import '../../../theme/app_text_styles.dart';
import '../../widgets/communs/snackbars.dart';

const BorderRadius _kBrCard12 = BorderRadius.all(Radius.circular(12));

/// Créer un véhicule du transporteur — type, capacité, immatriculation,
/// marque, volume optionnel. POST sur `/logistics/vehicles`.
///
/// Distinct de `VehiculeAjouterTransporteurPage` qui, malgré son nom
/// historique, crée des **itinéraires** (routes transporteur).
class VehiculeCreerPage extends ConsumerStatefulWidget {
  const VehiculeCreerPage({super.key});

  @override
  ConsumerState<VehiculeCreerPage> createState() => _VehiculeCreerPageState();
}

class _VehiculeCreerPageState extends ConsumerState<VehiculeCreerPage> {
  final _typeCtrl = TextEditingController();
  final _capaciteCtrl = TextEditingController(text: '1000');
  final _immatCtrl = TextEditingController();
  final _marqueCtrl = TextEditingController();
  final _volumeCtrl = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _typeCtrl.dispose();
    _capaciteCtrl.dispose();
    _immatCtrl.dispose();
    _marqueCtrl.dispose();
    _volumeCtrl.dispose();
    super.dispose();
  }

  Future<void> _enregistrer() async {
    if (_busy) return;
    final type = _typeCtrl.text.trim();
    final capacite = double.tryParse(_capaciteCtrl.text.replaceAll(',', '.'));
    final immat = _immatCtrl.text.trim();
    final marque = _marqueCtrl.text.trim();
    final volume = _volumeCtrl.text.trim().isEmpty
        ? null
        : double.tryParse(_volumeCtrl.text.replaceAll(',', '.'));

    if (type.isEmpty) {
      Snackbars.showErreur(context, 'Type de véhicule requis (ex. Pick-up).');
      return;
    }
    if (capacite == null || capacite <= 0) {
      Snackbars.showErreur(context, 'Capacité (kg) invalide.');
      return;
    }
    setState(() => _busy = true);
    try {
      await ref.read(logisticsServiceProvider).createVehicle(
            type: type,
            chargeMaxKg: capacite,
            immatriculation: immat.isEmpty ? null : immat,
            marque: marque.isEmpty ? null : marque,
            volumeM3: volume,
          );
      if (!mounted) return;
      Snackbars.showSucces(context, 'Véhicule enregistré');
      if (context.canPop()) context.pop();
    } on ApiException catch (e) {
      if (mounted) Snackbars.showErreur(context, e.message);
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
                  8,
                  AppDimens.pagePaddingH,
                  AppDimens.space16,
                ),
                children: [
                  const _SectionTitle('Identification'),
                  const SizedBox(height: 10),
                  _Field(
                    label: 'Type de véhicule',
                    hint: 'Pick-up, Camion 3T, Tricycle…',
                    controller: _typeCtrl,
                  ),
                  AppDimens.vGap12,
                  _Field(
                    label: 'Marque & modèle',
                    hint: 'Toyota Hilux 2018',
                    controller: _marqueCtrl,
                  ),
                  AppDimens.vGap12,
                  _Field(
                    label: 'Immatriculation',
                    hint: '2345 AB 01',
                    controller: _immatCtrl,
                  ),
                  AppDimens.vGap16,
                  const _SectionTitle('Capacité'),
                  const SizedBox(height: 10),
                  _Field(
                    label: 'Charge maximale (kg)',
                    hint: '1000',
                    controller: _capaciteCtrl,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                  AppDimens.vGap12,
                  _Field(
                    label: 'Volume utile (m³, optionnel)',
                    hint: '4.5',
                    controller: _volumeCtrl,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                    ],
                  ),
                  AppDimens.vGap24,
                  _PrimaryButton(
                    label: _busy ? 'Enregistrement…' : 'Enregistrer',
                    onTap: _busy ? null : _enregistrer,
                    busy: _busy,
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

// ─── Header ───────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 8, 16, 12),
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(
          bottom: BorderSide(
            color: AppColors.border,
            width: AppDimens.borderThin,
          ),
        ),
      ),
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
              'Ajouter un véhicule',
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

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;
  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: AppTextStyles.labelSmall.copyWith(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.4,
        color: AppColors.textSecondary,
      ),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({
    required this.label,
    required this.hint,
    required this.controller,
    this.keyboardType,
    this.inputFormatters,
  });

  final String label;
  final String hint;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.labelMedium.copyWith(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: _kBrCard12,
            border: Border.all(
              color: AppColors.borderStrong,
              width: AppDimens.borderThin,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            inputFormatters: inputFormatters,
            style: AppTextStyles.bodyMedium.copyWith(fontSize: 14),
            decoration: InputDecoration(
              isCollapsed: true,
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
              border: InputBorder.none,
              hintText: hint,
              hintStyle: AppTextStyles.hint.copyWith(
                fontSize: 13,
                color: AppColors.textSubtle,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({
    required this.label,
    required this.onTap,
    required this.busy,
  });
  final String label;
  final VoidCallback? onTap;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: _kBrCard12,
      child: Container(
        height: 48,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: onTap == null ? AppColors.borderStrong : AppColors.primary,
          borderRadius: _kBrCard12,
        ),
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
                label,
                style: AppTextStyles.button.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.onPrimary,
                ),
              ),
      ),
    );
  }
}
