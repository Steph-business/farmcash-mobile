import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../api_client/api_exception.dart';
import '../../../../services/providers.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../widgets/communs/snackbars.dart';
import '../../../widgets/cooperative/logistique/bouton_sticky_vehicule.dart';
import '../../../widgets/cooperative/logistique/champ_texte_collecte.dart';
import '../../../widgets/cooperative/logistique/chip_type_vehicule.dart';
import '../../../widgets/cooperative/logistique/entete_vehicule_ajouter.dart';
import '../../../widgets/cooperative/logistique/libelle_champ_collecte.dart';

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
            const EnteteVehiculeAjouter(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppDimens.pagePaddingH,
                  12,
                  AppDimens.pagePaddingH,
                  AppDimens.space16,
                ),
                children: [
                  const LibelleChampCollecte('Type de véhicule'),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (int i = 0; i < _kTypes.length; i++)
                        ChipTypeVehicule(
                          label: _kTypes[i].label,
                          active: _typeIndex == i,
                          onTap: () => setState(() => _typeIndex = i),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const LibelleChampCollecte('Immatriculation'),
                  const SizedBox(height: 6),
                  ChampTexteCollecte(
                    controller: _immatCtrl,
                    placeholder: '5125 AB 01',
                  ),
                  const SizedBox(height: 14),
                  const LibelleChampCollecte('Marque'),
                  const SizedBox(height: 6),
                  ChampTexteCollecte(
                    controller: _marqueCtrl,
                    placeholder: 'Toyota, Mercedes…',
                  ),
                  const SizedBox(height: 14),
                  const LibelleChampCollecte('Charge max (kg)'),
                  const SizedBox(height: 6),
                  ChampTexteCollecte(
                    controller: _chargeCtrl,
                    placeholder: '3500',
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                    ],
                  ),
                  const SizedBox(height: 14),
                  const LibelleChampCollecte('Chauffeur — nom'),
                  const SizedBox(height: 6),
                  ChampTexteCollecte(
                    controller: _chauffeurNomCtrl,
                    placeholder: 'Kouamé Konan',
                  ),
                  const SizedBox(height: 14),
                  const LibelleChampCollecte('Chauffeur — téléphone'),
                  const SizedBox(height: 6),
                  ChampTexteCollecte(
                    controller: _chauffeurPhoneCtrl,
                    placeholder: '+225 0700000000',
                    keyboardType: TextInputType.phone,
                  ),
                ],
              ),
            ),
            BoutonStickyVehicule(onTap: _enregistrer, busy: _busy),
          ],
        ),
      ),
    );
  }
}
