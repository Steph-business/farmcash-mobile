import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';

/// Liste des régions de Côte d'Ivoire proposée dans les dropdowns
/// d'inscription (FARMER, COOPERATIVE). Volontairement statique pour
/// l'instant : le sélecteur officiel (UUID via `GET /reference/regions`)
/// arrivera dans une itération ultérieure.
const List<String> kRegionsCotedIvoire = <String>[
  'Centre',
  'Nord',
  'Sud',
  'Est',
  'Ouest',
  'Lagunes',
  'Vallée du Bandama',
  'Montagnes',
  'Lacs',
  'Zanzan',
  'Bas-Sassandra',
  'Comoé',
  'Sassandra-Marahoué',
  'Savanes',
  'Woroba',
  'Yamoussoukro',
  'Abidjan',
];

/// Dropdown générique de sélection d'une région, utilisé par les
/// sous-formulaires FARMER et COOPERATIVE de l'inscription.
///
/// Le widget est désactivé lorsque [enabled] vaut `false` (typiquement
/// pendant un appel API en cours).
class DropdownRegions extends StatelessWidget {
  const DropdownRegions({
    required this.value,
    required this.onChanged,
    this.enabled = true,
    super.key,
  });

  final String? value;
  final ValueChanged<String?> onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      isExpanded: true,
      icon: const Icon(
        Icons.keyboard_arrow_down,
        color: AppColors.textSecondary,
      ),
      hint: Text(
        'Sélectionner une région',
        style: AppTextStyles.hint,
      ),
      items: kRegionsCotedIvoire
          .map(
            (r) => DropdownMenuItem<String>(
              value: r,
              child: Text(r, style: AppTextStyles.bodyMedium),
            ),
          )
          .toList(),
      onChanged: enabled ? onChanged : null,
    );
  }
}
