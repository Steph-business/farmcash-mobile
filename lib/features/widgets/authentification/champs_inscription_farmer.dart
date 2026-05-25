import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../models/cooperative.dart';
import '../../../theme/app_dimens.dart';
import 'dropdown_regions.dart';
import 'label_champ_inscription.dart';
import 'selecteur_coop.dart';

/// Formatters pour les champs décimaux : autorise chiffres + virgule/point.
final List<TextInputFormatter> _decimalFormatters = [
  FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
];

/// Sous-formulaire FARMER de l'inscription : région, superficie cultivée,
/// années d'expérience, cultures principales et coopérative par défaut.
///
/// Les contrôleurs et l'état sélectionné restent détenus par la state class
/// parente `_InscriptionPageState` pour préserver la logique de validation
/// et la propagation au backend.
class ChampsInscriptionFarmer extends StatelessWidget {
  const ChampsInscriptionFarmer({
    required this.regionValue,
    required this.onRegionChanged,
    required this.superficieCtrl,
    required this.expCtrl,
    required this.culturesCtrl,
    required this.selectedCoop,
    required this.onCoopSelected,
    required this.loading,
    super.key,
  });

  final String? regionValue;
  final ValueChanged<String?> onRegionChanged;
  final TextEditingController superficieCtrl;
  final TextEditingController expCtrl;
  final TextEditingController culturesCtrl;
  final Cooperative? selectedCoop;
  final ValueChanged<Cooperative?> onCoopSelected;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LabelChampInscription(
          label: 'Région',
          child: DropdownRegions(
            value: regionValue,
            onChanged: onRegionChanged,
            enabled: !loading,
          ),
        ),
        AppDimens.vGap16,
        LabelChampInscription(
          label: 'Superficie cultivée (hectares)',
          child: TextField(
            controller: superficieCtrl,
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: _decimalFormatters,
            enabled: !loading,
            decoration: const InputDecoration(hintText: 'Ex : 5'),
          ),
        ),
        AppDimens.vGap16,
        LabelChampInscription(
          label: 'Années d\'expérience (optionnel)',
          child: TextField(
            controller: expCtrl,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            enabled: !loading,
            decoration: const InputDecoration(hintText: 'Ex : 10'),
          ),
        ),
        AppDimens.vGap16,
        LabelChampInscription(
          label: 'Cultures principales (optionnel)',
          child: TextField(
            controller: culturesCtrl,
            enabled: !loading,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              hintText: 'Ex : Maïs, manioc, riz',
            ),
          ),
        ),
        AppDimens.vGap16,
        SelecteurCoop(
          selectedCoopId: selectedCoop?.id,
          enabled: !loading,
          onSelected: onCoopSelected,
        ),
      ],
    );
  }
}
