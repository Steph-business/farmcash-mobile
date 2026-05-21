import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../api_client/api_exception.dart';
import '../../../../models/coop_vehicle.dart';
import '../../../../models/membre_coop.dart';
import '../../../../routing/route_names.dart';
import '../../../../services/providers.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';
import '../../../widgets/communs/chargement.dart';
import '../../../widgets/communs/snackbars.dart';
import '../../../widgets/communs/vue_erreur.dart';

const BorderRadius _kBrCard12 = BorderRadius.all(Radius.circular(12));

/// Bundle données utilisées par le formulaire : membres de la coop +
/// véhicules disponibles pour assignation.
class _FormBundle {
  const _FormBundle({required this.membres, required this.vehicles});
  final List<MembreCoop> membres;
  final List<CoopVehicle> vehicles;
}

final _formBundleProvider =
    FutureProvider.autoDispose<_FormBundle>((ref) async {
  final coop = ref.read(cooperativesServiceProvider);
  final logi = ref.read(coopLogisticsServiceProvider);
  final results = await Future.wait<dynamic>([
    coop.listMembers(limit: 200),
    logi.listVehicles(),
  ]);
  final membresPage = results[0];
  final vehicles = results[1] as List<CoopVehicle>;
  return _FormBundle(
    membres: (membresPage as dynamic).data as List<MembreCoop>,
    vehicles: vehicles,
  );
});

/// Formulaire « Planifier une collecte » côté coopérative.
class CollecteCreerPage extends ConsumerStatefulWidget {
  const CollecteCreerPage({super.key});

  @override
  ConsumerState<CollecteCreerPage> createState() => _CollecteCreerPageState();
}

class _CollecteCreerPageState extends ConsumerState<CollecteCreerPage> {
  MembreCoop? _membre;
  DateTime? _scheduledAt;
  final TextEditingController _adresseCtrl = TextEditingController();
  final TextEditingController _qteCtrl = TextEditingController();
  CoopVehicle? _vehicle;
  final TextEditingController _notesCtrl = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _adresseCtrl.dispose();
    _qteCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  String get _scheduledLabel {
    final d = _scheduledAt;
    if (d == null) return 'Choisir une date';
    return DateFormat('EEEE d MMMM HH:mm', 'fr_FR').format(d);
  }

  Future<void> _pickDateTime() async {
    final now = DateTime.now();
    final base = _scheduledAt ?? now.add(const Duration(hours: 24));
    final date = await showDatePicker(
      context: context,
      initialDate: base,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(base),
    );
    if (time == null || !mounted) return;
    setState(() {
      _scheduledAt = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  Future<void> _choisirMembre(List<MembreCoop> membres) async {
    final selected = await showModalBottomSheet<MembreCoop>(
      context: context,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return SafeArea(
          top: false,
          child: SizedBox(
            height: MediaQuery.of(ctx).size.height * 0.6,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Text(
                    'Choisir un membre',
                    style: AppTextStyles.titleSmall.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Expanded(
                  child: membres.isEmpty
                      ? Center(
                          child: Text(
                            'Aucun membre dans la coop',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        )
                      : ListView.builder(
                          itemCount: membres.length,
                          itemBuilder: (_, i) {
                            final m = membres[i];
                            return ListTile(
                              title: Text(m.fullName ?? m.userId),
                              subtitle: m.phone != null
                                  ? Text(m.phone!)
                                  : null,
                              onTap: () => Navigator.of(ctx).pop(m),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
    if (selected != null && mounted) {
      setState(() => _membre = selected);
    }
  }

  Future<void> _choisirVehicule(List<CoopVehicle> vehicles) async {
    final selected = await showModalBottomSheet<CoopVehicle?>(
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
                  'Choisir un véhicule (optionnel)',
                  style: AppTextStyles.titleSmall.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.clear,
                    color: AppColors.textSecondary),
                title: const Text('Aucun (à assigner plus tard)'),
                onTap: () => Navigator.of(ctx).pop(null),
              ),
              for (final v in vehicles)
                ListTile(
                  leading: const Icon(Icons.local_shipping_outlined,
                      color: AppColors.primary),
                  title: Text(
                    (v.marque ?? '').isEmpty
                        ? '${v.type} · ${v.immatriculation ?? '—'}'
                        : '${v.marque!} ${v.type} · ${v.immatriculation ?? '—'}',
                  ),
                  subtitle: Text(
                      '${v.chargeMaxKg.round()} kg max'),
                  onTap: () => Navigator.of(ctx).pop(v),
                ),
            ],
          ),
        );
      },
    );
    if (mounted) {
      // null signal "aucun" volontaire ; on attribue (peut être null).
      setState(() => _vehicle = selected);
    }
  }

  Future<void> _enregistrer() async {
    if (_busy) return;
    final membre = _membre;
    final scheduledAt = _scheduledAt;
    final adresse = _adresseCtrl.text.trim();
    final qteText = _qteCtrl.text.replaceAll(',', '.').trim();
    final qte = double.tryParse(qteText);

    if (membre == null) {
      Snackbars.showErreur(context, 'Choisissez un membre');
      return;
    }
    if (scheduledAt == null) {
      Snackbars.showErreur(context, 'Choisissez une date de collecte');
      return;
    }
    if (adresse.isEmpty) {
      Snackbars.showErreur(context, 'Adresse de ramassage requise');
      return;
    }
    if (qte == null || qte <= 0) {
      Snackbars.showErreur(context, 'Quantité prévue invalide');
      return;
    }
    setState(() => _busy = true);
    try {
      await ref.read(coopLogisticsServiceProvider).createCollection(
            farmerId: membre.userId,
            scheduledAt: scheduledAt,
            pickupAddress: adresse,
            quantitePrevueKg: qte,
            vehicleId: _vehicle?.id,
            notes: _notesCtrl.text.trim().isEmpty
                ? null
                : _notesCtrl.text.trim(),
          );
      if (!mounted) return;
      Snackbars.showSucces(context, 'Collecte planifiée');
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
    final async = ref.watch(_formBundleProvider);
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const _Header(),
            Expanded(
              child: async.when(
                loading: () => const Padding(
                  padding: EdgeInsets.only(top: 48),
                  child: Chargement(size: 22),
                ),
                error: (e, _) => Padding(
                  padding: const EdgeInsets.all(AppDimens.pagePaddingH),
                  child: VueErreur(
                    message: 'Impossible de charger le formulaire. $e',
                    onRetry: () => ref.invalidate(_formBundleProvider),
                  ),
                ),
                data: (bundle) => _body(bundle),
              ),
            ),
            _StickyButton(onTap: _enregistrer, busy: _busy),
          ],
        ),
      ),
    );
  }

  Widget _body(_FormBundle bundle) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppDimens.pagePaddingH,
        12,
        AppDimens.pagePaddingH,
        AppDimens.space16,
      ),
      children: [
        _FieldLabel('Membre à collecter'),
        const SizedBox(height: 6),
        _Selector(
          label: _membre?.fullName ?? 'Choisir un membre',
          placeholder: _membre == null,
          onTap: _busy ? null : () => _choisirMembre(bundle.membres),
          icon: Icons.person_outline,
        ),
        const SizedBox(height: 14),
        _FieldLabel('Date et heure prévue'),
        const SizedBox(height: 6),
        _Selector(
          label: _scheduledLabel,
          placeholder: _scheduledAt == null,
          onTap: _busy ? null : _pickDateTime,
          icon: Icons.calendar_today_outlined,
        ),
        const SizedBox(height: 14),
        _FieldLabel('Adresse de ramassage'),
        const SizedBox(height: 6),
        _Input(
          controller: _adresseCtrl,
          placeholder: 'Quartier, ville, repère…',
          maxLines: 2,
        ),
        const SizedBox(height: 14),
        _FieldLabel('Quantité prévue (kg)'),
        const SizedBox(height: 6),
        _Input(
          controller: _qteCtrl,
          placeholder: '500',
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
          ],
        ),
        const SizedBox(height: 14),
        _FieldLabel('Véhicule (optionnel)'),
        const SizedBox(height: 6),
        _Selector(
          label: _vehicle == null
              ? 'À assigner plus tard'
              : ((_vehicle!.marque ?? '').isEmpty
                  ? '${_vehicle!.type} · ${_vehicle!.immatriculation ?? '—'}'
                  : '${_vehicle!.marque!} ${_vehicle!.type}'),
          placeholder: _vehicle == null,
          onTap: _busy ? null : () => _choisirVehicule(bundle.vehicles),
          icon: Icons.local_shipping_outlined,
        ),
        const SizedBox(height: 14),
        _FieldLabel('Notes (optionnel)'),
        const SizedBox(height: 6),
        _Input(
          controller: _notesCtrl,
          placeholder: 'Instructions particulières…',
          maxLines: 3,
        ),
      ],
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
              'Planifier une collecte',
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

class _Selector extends StatelessWidget {
  const _Selector({
    required this.label,
    required this.placeholder,
    required this.onTap,
    required this.icon,
  });

  final String label;
  final bool placeholder;
  final VoidCallback? onTap;
  final IconData icon;

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
            Icon(icon, size: 18, color: AppColors.textSecondary),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontSize: 14,
                  color: placeholder
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

class _Input extends StatelessWidget {
  const _Input({
    required this.controller,
    this.placeholder = '',
    this.keyboardType,
    this.inputFormatters,
    this.maxLines = 1,
  });

  final TextEditingController controller;
  final String placeholder;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final int maxLines;

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
        maxLines: maxLines,
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
                  'Planifier la collecte',
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
