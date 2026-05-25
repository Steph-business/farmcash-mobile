import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_dimens.dart';
import '../../../theme/app_text_styles.dart';
import 'label_champ_inscription.dart';

final List<TextInputFormatter> _decimalFormatters = [
  FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
];

/// Option de la liste déroulante des types de véhicule.
///
/// `apiValue` est la valeur exacte attendue par l'enum backend
/// `ProfilTransporteurDto.TypeVehicule`.
class OptionTypeVehicule {
  const OptionTypeVehicule({required this.apiValue, required this.label});

  final String apiValue;
  final String label;
}

/// Types de véhicule supportés par le DTO backend
/// `ProfilTransporteurDto.TypeVehicule`. L'ordre est conservé identique
/// à celui de l'API pour faciliter la maintenance.
const List<OptionTypeVehicule> kTypesVehicule = <OptionTypeVehicule>[
  OptionTypeVehicule(apiValue: 'MOTO', label: 'Moto'),
  OptionTypeVehicule(apiValue: 'TRICYCLE', label: 'Tricycle'),
  OptionTypeVehicule(apiValue: 'PICKUP', label: 'Pickup'),
  OptionTypeVehicule(apiValue: 'FOURGON', label: 'Fourgon'),
  OptionTypeVehicule(apiValue: 'CAMION', label: 'Camion'),
  OptionTypeVehicule(apiValue: 'CAMION_FRIGO', label: 'Camion frigorifique'),
  OptionTypeVehicule(apiValue: 'REMORQUE', label: 'Remorque'),
];

/// Sous-formulaire TRANSPORTER de l'inscription : numéro de permis,
/// immatriculation, type de véhicule, capacité maximale, marque/modèle
/// et nom d'entreprise. Les 4 premiers champs sont requis par le backend
/// au premier upsert (validation côté state class parente).
class ChampsInscriptionTransporter extends StatelessWidget {
  const ChampsInscriptionTransporter({
    required this.permisCtrl,
    required this.immatCtrl,
    required this.typeVehiculeValue,
    required this.onTypeVehiculeChanged,
    required this.capaciteCtrl,
    required this.marqueCtrl,
    required this.entrepriseCtrl,
    required this.loading,
    super.key,
  });

  final TextEditingController permisCtrl;
  final TextEditingController immatCtrl;
  final String? typeVehiculeValue;
  final ValueChanged<String?> onTypeVehiculeChanged;
  final TextEditingController capaciteCtrl;
  final TextEditingController marqueCtrl;
  final TextEditingController entrepriseCtrl;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LabelChampInscription(
          label: 'Numéro de permis',
          child: TextField(
            controller: permisCtrl,
            enabled: !loading,
            decoration: const InputDecoration(
              hintText: 'Ex : CI-PERM-2020-456789',
            ),
          ),
        ),
        AppDimens.vGap16,
        LabelChampInscription(
          label: 'Immatriculation',
          child: TextField(
            controller: immatCtrl,
            enabled: !loading,
            textCapitalization: TextCapitalization.characters,
            decoration: const InputDecoration(hintText: 'Ex : 4567 AB 01'),
          ),
        ),
        AppDimens.vGap16,
        LabelChampInscription(
          label: 'Type de véhicule',
          child: DropdownButtonFormField<String>(
            initialValue: typeVehiculeValue,
            isExpanded: true,
            icon: const Icon(
              Icons.keyboard_arrow_down,
              color: AppColors.textSecondary,
            ),
            hint: Text(
              'Sélectionner un type',
              style: AppTextStyles.hint,
            ),
            items: kTypesVehicule
                .map(
                  (t) => DropdownMenuItem<String>(
                    value: t.apiValue,
                    child: Text(t.label, style: AppTextStyles.bodyMedium),
                  ),
                )
                .toList(),
            onChanged: loading ? null : onTypeVehiculeChanged,
          ),
        ),
        AppDimens.vGap16,
        LabelChampInscription(
          label: 'Capacité maximale (kg)',
          child: TextField(
            controller: capaciteCtrl,
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: _decimalFormatters,
            enabled: !loading,
            decoration: const InputDecoration(hintText: 'Ex : 3000'),
          ),
        ),
        AppDimens.vGap16,
        LabelChampInscription(
          label: 'Marque et modèle (optionnel)',
          child: TextField(
            controller: marqueCtrl,
            enabled: !loading,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              hintText: 'Ex : Isuzu N-Series 2020',
            ),
          ),
        ),
        AppDimens.vGap16,
        LabelChampInscription(
          label: 'Nom d\'entreprise (optionnel)',
          child: TextField(
            controller: entrepriseCtrl,
            enabled: !loading,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              hintText: 'Ex : Transport Yao Express',
            ),
          ),
        ),
      ],
    );
  }
}
