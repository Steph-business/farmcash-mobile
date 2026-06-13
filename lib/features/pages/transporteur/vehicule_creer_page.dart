import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../api_client/api_exception.dart';
import '../../../services/providers.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_dimens.dart';
import '../../widgets/communs/entete_page_standard.dart';
import '../../widgets/communs/snackbars.dart';
import '../../widgets/transporteur/profil/bouton_principal_formulaire.dart';
import '../../widgets/transporteur/profil/champ_formulaire_vehicule.dart';
import '../../widgets/transporteur/profil/titre_section_formulaire.dart';

/// Créer un véhicule du transporteur — type, capacité, immatriculation,
/// marque, volume optionnel. POST sur `/logistics/vehicles`.
///
/// Distinct de `ItineraireCreerPage` qui crée des **itinéraires**
/// (routes origine ↔ destination avec tarif).
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
            const EntetePageStandard(titre: 'Ajouter un véhicule'),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppDimens.pagePaddingH,
                  8,
                  AppDimens.pagePaddingH,
                  AppDimens.space16,
                ),
                children: [
                  const TitreSectionFormulaire('Identification'),
                  const SizedBox(height: 10),
                  ChampFormulaireVehicule(
                    label: 'Type de véhicule',
                    hint: 'Pick-up, Camion 3T, Tricycle…',
                    controller: _typeCtrl,
                  ),
                  AppDimens.vGap12,
                  ChampFormulaireVehicule(
                    label: 'Marque & modèle',
                    hint: 'Toyota Hilux 2018',
                    controller: _marqueCtrl,
                  ),
                  AppDimens.vGap12,
                  ChampFormulaireVehicule(
                    label: 'Immatriculation',
                    hint: '2345 AB 01',
                    controller: _immatCtrl,
                  ),
                  AppDimens.vGap16,
                  const TitreSectionFormulaire('Capacité'),
                  const SizedBox(height: 10),
                  ChampFormulaireVehicule(
                    label: 'Charge maximale (kg)',
                    hint: '1000',
                    controller: _capaciteCtrl,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                  AppDimens.vGap12,
                  ChampFormulaireVehicule(
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
                  BoutonPrincipalFormulaire(
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
