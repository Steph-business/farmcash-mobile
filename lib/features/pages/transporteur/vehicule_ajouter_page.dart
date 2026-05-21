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

/// Ajouter un itinéraire (route transporteur) — origine, destination,
/// capacité kg, tarif kg, tarif minimum optionnel, délai typique.
///
/// Le titre historique de la page est "Véhicule" mais côté backend c'est
/// une **route** qui se déclare (capacité = caractéristique de la route).
class VehiculeAjouterTransporteurPage extends ConsumerStatefulWidget {
  const VehiculeAjouterTransporteurPage({super.key});

  @override
  ConsumerState<VehiculeAjouterTransporteurPage> createState() =>
      _VehiculeAjouterTransporteurPageState();
}

class _VehiculeAjouterTransporteurPageState
    extends ConsumerState<VehiculeAjouterTransporteurPage> {
  final _origineCtrl = TextEditingController();
  final _destCtrl = TextEditingController();
  final _capaciteCtrl = TextEditingController(text: '1000');
  final _tarifKgCtrl = TextEditingController(text: '150');
  final _tarifMinCtrl = TextEditingController(text: '10000');
  final _delaiCtrl = TextEditingController(text: 'Sous 24h');
  bool _busy = false;

  @override
  void dispose() {
    _origineCtrl.dispose();
    _destCtrl.dispose();
    _capaciteCtrl.dispose();
    _tarifKgCtrl.dispose();
    _tarifMinCtrl.dispose();
    _delaiCtrl.dispose();
    super.dispose();
  }

  Future<void> _enregistrer() async {
    if (_busy) return;
    final origine = _origineCtrl.text.trim();
    final dest = _destCtrl.text.trim();
    final capacite = double.tryParse(_capaciteCtrl.text.replaceAll(',', '.'));
    final tarifKg = double.tryParse(_tarifKgCtrl.text.replaceAll(',', '.'));
    final tarifMin = double.tryParse(_tarifMinCtrl.text.replaceAll(',', '.'));
    if (origine.isEmpty || dest.isEmpty) {
      Snackbars.showErreur(context, 'Origine et destination requises.');
      return;
    }
    if (origine == dest) {
      Snackbars.showErreur(context, 'Origine et destination doivent différer.');
      return;
    }
    if (capacite == null || capacite <= 0) {
      Snackbars.showErreur(context, 'Capacité (kg) invalide.');
      return;
    }
    if (tarifKg == null || tarifKg < 0) {
      Snackbars.showErreur(context, 'Tarif au kg invalide.');
      return;
    }
    setState(() => _busy = true);
    try {
      await ref.read(logisticsServiceProvider).createRoute(
            origineZone: origine,
            destinationZone: dest,
            capaciteMaxKg: capacite,
            tarifKg: tarifKg,
            tarifMinimum: tarifMin,
            delaiTypique: _delaiCtrl.text.trim().isEmpty
                ? null
                : _delaiCtrl.text.trim(),
          );
      if (!mounted) return;
      Snackbars.showSucces(context, 'Itinéraire enregistré');
      if (context.canPop()) context.pop();
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
                  const _SectionTitle('Itinéraire'),
                  const SizedBox(height: 10),
                  _Field(
                    label: 'Zone d\'origine',
                    hint: 'Ex : Bouaké',
                    controller: _origineCtrl,
                  ),
                  AppDimens.vGap12,
                  _Field(
                    label: 'Zone de destination',
                    hint: 'Ex : Abidjan',
                    controller: _destCtrl,
                  ),
                  AppDimens.vGap16,
                  const _SectionTitle('Capacité & tarif'),
                  const SizedBox(height: 10),
                  _Field(
                    label: 'Capacité maximale (kg)',
                    hint: '1000',
                    controller: _capaciteCtrl,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                  AppDimens.vGap12,
                  _Field(
                    label: 'Tarif au kg (F)',
                    hint: '150',
                    controller: _tarifKgCtrl,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                  AppDimens.vGap12,
                  _Field(
                    label: 'Tarif minimum (F)',
                    hint: '10 000',
                    controller: _tarifMinCtrl,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    help:
                        'Si le calcul tarif × poids tombe sous ce seuil, on facture ce minimum.',
                  ),
                  AppDimens.vGap12,
                  _Field(
                    label: 'Délai typique',
                    hint: 'Sous 24h',
                    controller: _delaiCtrl,
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
              'Ajouter un itinéraire',
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

// ─── Field ────────────────────────────────────────────────────────

class _Field extends StatelessWidget {
  const _Field({
    required this.label,
    required this.hint,
    required this.controller,
    this.keyboardType,
    this.inputFormatters,
    this.help,
  });

  final String label;
  final String hint;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? help;

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
        if (help != null) ...[
          const SizedBox(height: 4),
          Text(
            help!,
            style: AppTextStyles.labelSmall.copyWith(
              fontSize: 10,
              color: AppColors.textSubtle,
              height: 1.4,
            ),
          ),
        ],
      ],
    );
  }
}

// ─── CTA principal ────────────────────────────────────────────────

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
