import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../theme/app_dimens.dart';
import 'dropdown_regions.dart';
import 'label_champ_inscription.dart';

/// Sous-formulaire COOPERATIVE de l'inscription : nom de la coopérative,
/// numéro d'agrément, région, ville et nombre de membres. Le nom et
/// l'agrément sont requis (validation côté state class parente).
class ChampsInscriptionCooperative extends StatelessWidget {
  const ChampsInscriptionCooperative({
    required this.nomCtrl,
    required this.agrementCtrl,
    required this.regionValue,
    required this.onRegionChanged,
    required this.villeCtrl,
    required this.membresCtrl,
    required this.loading,
    super.key,
  });

  final TextEditingController nomCtrl;
  final TextEditingController agrementCtrl;
  final String? regionValue;
  final ValueChanged<String?> onRegionChanged;
  final TextEditingController villeCtrl;
  final TextEditingController membresCtrl;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LabelChampInscription(
          label: 'Nom de la coopérative',
          child: TextField(
            controller: nomCtrl,
            textCapitalization: TextCapitalization.words,
            enabled: !loading,
            decoration:
                const InputDecoration(hintText: 'Ex : Coop Yamoussoukro'),
          ),
        ),
        AppDimens.vGap16,
        LabelChampInscription(
          label: 'Numéro d\'agrément',
          child: TextField(
            controller: agrementCtrl,
            enabled: !loading,
            decoration:
                const InputDecoration(hintText: 'Ex : MINADER-2023-001'),
          ),
        ),
        AppDimens.vGap16,
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
          label: 'Ville',
          child: TextField(
            controller: villeCtrl,
            textCapitalization: TextCapitalization.words,
            enabled: !loading,
            decoration: const InputDecoration(hintText: 'Ex : Yamoussoukro'),
          ),
        ),
        AppDimens.vGap16,
        LabelChampInscription(
          label: 'Nombre de membres (optionnel)',
          child: TextField(
            controller: membresCtrl,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            enabled: !loading,
            decoration: const InputDecoration(hintText: 'Ex : 150'),
          ),
        ),
      ],
    );
  }
}
