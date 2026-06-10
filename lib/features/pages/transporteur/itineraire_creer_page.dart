import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../api_client/api_exception.dart';
import '../../../services/providers.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_dimens.dart';
import '../../widgets/communs/snackbars.dart';
import '../../widgets/transporteur/profil/bouton_principal_formulaire.dart';
import '../../widgets/transporteur/profil/champ_formulaire_vehicule.dart';
import '../../widgets/transporteur/profil/entete_ajouter_itineraire.dart';
import '../../widgets/transporteur/profil/titre_section_formulaire.dart';

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
      if (mounted) Snackbars.showErreurInattendue(context, e);
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
            const EnteteAjouterItineraire(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppDimens.pagePaddingH,
                  8,
                  AppDimens.pagePaddingH,
                  AppDimens.space16,
                ),
                children: [
                  const TitreSectionFormulaire('Itinéraire'),
                  const SizedBox(height: 10),
                  ChampFormulaireVehicule(
                    label: 'Zone d\'origine',
                    hint: 'Ex : Bouaké',
                    controller: _origineCtrl,
                  ),
                  AppDimens.vGap12,
                  ChampFormulaireVehicule(
                    label: 'Zone de destination',
                    hint: 'Ex : Abidjan',
                    controller: _destCtrl,
                  ),
                  AppDimens.vGap16,
                  const TitreSectionFormulaire('Capacité & tarif'),
                  const SizedBox(height: 10),
                  ChampFormulaireVehicule(
                    label: 'Capacité maximale (kg)',
                    hint: '1000',
                    controller: _capaciteCtrl,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                  AppDimens.vGap12,
                  ChampFormulaireVehicule(
                    label: 'Tarif au kg (F)',
                    hint: '150',
                    controller: _tarifKgCtrl,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                  AppDimens.vGap12,
                  ChampFormulaireVehicule(
                    label: 'Tarif minimum (F)',
                    hint: '10 000',
                    controller: _tarifMinCtrl,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    help:
                        'Si le calcul tarif × poids tombe sous ce seuil, on facture ce minimum.',
                  ),
                  AppDimens.vGap12,
                  ChampFormulaireVehicule(
                    label: 'Délai typique',
                    hint: 'Sous 24h',
                    controller: _delaiCtrl,
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
