import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../theme/app_dimens.dart';
import 'label_champ_inscription.dart';

final List<TextInputFormatter> _decimalFormatters = [
  FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
];

/// Sous-formulaire BUYER (acheteur professionnel) de l'inscription :
/// nom de l'entreprise, numéro RCCM, capacité d'achat mensuelle et
/// zones d'approvisionnement. Tous les champs sont optionnels côté DTO.
class ChampsInscriptionBuyer extends StatelessWidget {
  const ChampsInscriptionBuyer({
    required this.companyCtrl,
    required this.rccmCtrl,
    required this.capaciteCtrl,
    required this.zonesCtrl,
    required this.loading,
    super.key,
  });

  final TextEditingController companyCtrl;
  final TextEditingController rccmCtrl;
  final TextEditingController capaciteCtrl;
  final TextEditingController zonesCtrl;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LabelChampInscription(
          label: 'Nom de l\'entreprise (optionnel)',
          child: TextField(
            controller: companyCtrl,
            textCapitalization: TextCapitalization.words,
            enabled: !loading,
            decoration: const InputDecoration(hintText: 'Ex : Agro SARL'),
          ),
        ),
        AppDimens.vGap16,
        LabelChampInscription(
          label: 'Numéro RCCM (optionnel)',
          child: TextField(
            controller: rccmCtrl,
            enabled: !loading,
            decoration:
                const InputDecoration(hintText: 'Ex : CI-ABJ-2024-B-1234'),
          ),
        ),
        AppDimens.vGap16,
        LabelChampInscription(
          label: 'Capacité d\'achat (kg/mois) (optionnel)',
          child: TextField(
            controller: capaciteCtrl,
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: _decimalFormatters,
            enabled: !loading,
            decoration: const InputDecoration(hintText: 'Ex : 2000'),
          ),
        ),
        AppDimens.vGap16,
        LabelChampInscription(
          label: 'Zones d\'achat (optionnel)',
          child: TextField(
            controller: zonesCtrl,
            enabled: !loading,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              hintText: 'Ex : Abidjan, Bouaké',
            ),
          ),
        ),
      ],
    );
  }
}
