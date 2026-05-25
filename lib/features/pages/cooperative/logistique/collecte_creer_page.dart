import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../api_client/api_exception.dart';
import '../../../../models/coop_vehicle.dart';
import '../../../../models/membre_coop.dart';
import '../../../../services/providers.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../widgets/communs/chargement.dart';
import '../../../widgets/communs/snackbars.dart';
import '../../../widgets/communs/vue_erreur.dart';
import '../../../widgets/cooperative/logistique/bouton_sticky_collecte.dart';
import '../../../widgets/cooperative/logistique/champ_texte_collecte.dart';
import '../../../widgets/cooperative/logistique/entete_collecte_creer.dart';
import '../../../widgets/cooperative/logistique/feuille_choix_membre_collecte.dart';
import '../../../widgets/cooperative/logistique/feuille_choix_vehicule_collecte.dart';
import '../../../widgets/cooperative/logistique/libelle_champ_collecte.dart';
import '../../../widgets/cooperative/logistique/selecteur_champ_collecte.dart';

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
    final selected = await ouvrirFeuilleChoixMembreCollecte(
      context,
      membres: membres,
    );
    if (selected != null && mounted) {
      setState(() => _membre = selected);
    }
  }

  Future<void> _choisirVehicule(List<CoopVehicle> vehicles) async {
    final selected = await ouvrirFeuilleChoixVehiculeCollecte(
      context,
      vehicles: vehicles,
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
            const EnteteCollecteCreer(),
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
            BoutonStickyCollecte(onTap: _enregistrer, busy: _busy),
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
        const LibelleChampCollecte('Membre à collecter'),
        const SizedBox(height: 6),
        SelecteurChampCollecte(
          label: _membre?.fullName ?? 'Choisir un membre',
          placeholder: _membre == null,
          onTap: _busy ? null : () => _choisirMembre(bundle.membres),
          icon: Icons.person_outline,
        ),
        const SizedBox(height: 14),
        const LibelleChampCollecte('Date et heure prévue'),
        const SizedBox(height: 6),
        SelecteurChampCollecte(
          label: _scheduledLabel,
          placeholder: _scheduledAt == null,
          onTap: _busy ? null : _pickDateTime,
          icon: Icons.calendar_today_outlined,
        ),
        const SizedBox(height: 14),
        const LibelleChampCollecte('Adresse de ramassage'),
        const SizedBox(height: 6),
        ChampTexteCollecte(
          controller: _adresseCtrl,
          placeholder: 'Quartier, ville, repère…',
          maxLines: 2,
        ),
        const SizedBox(height: 14),
        const LibelleChampCollecte('Quantité prévue (kg)'),
        const SizedBox(height: 6),
        ChampTexteCollecte(
          controller: _qteCtrl,
          placeholder: '500',
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
          ],
        ),
        const SizedBox(height: 14),
        const LibelleChampCollecte('Véhicule (optionnel)'),
        const SizedBox(height: 6),
        SelecteurChampCollecte(
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
        const LibelleChampCollecte('Notes (optionnel)'),
        const SizedBox(height: 6),
        ChampTexteCollecte(
          controller: _notesCtrl,
          placeholder: 'Instructions particulières…',
          maxLines: 3,
        ),
      ],
    );
  }
}
