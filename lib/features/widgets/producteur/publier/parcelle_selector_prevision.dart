import 'package:flutter/material.dart';

import '../../../../models/parcelle.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_text_styles.dart';

/// Dropdown optionnel : associer la prevision a une parcelle existante
/// (tracabilite).
///
/// Premier item null « Aucune parcelle ». `superficieHa` est affichee si
/// renseignee (sinon seul le nom).
class ParcelleSelectorPrevision extends StatelessWidget {
  const ParcelleSelectorPrevision({
    required this.parcelles,
    required this.selectedId,
    required this.enabled,
    required this.onChanged,
    super.key,
  });

  final List<Parcelle> parcelles;
  final String? selectedId;
  final bool enabled;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String?>(
      initialValue: selectedId,
      isExpanded: true,
      decoration: InputDecoration(
        hintText: 'Aucune (optionnel)',
        hintStyle: AppTextStyles.hint.copyWith(fontSize: 13),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
      items: [
        const DropdownMenuItem<String?>(
          value: null,
          child: Text('— Aucune parcelle —'),
        ),
        ...parcelles.map((p) {
          // `superficieHa` est nullable cote model — si l'admin a cree une
          // parcelle sans la renseigner, on n'affiche que le nom.
          final ha = p.superficieHa;
          final label = ha != null ? '${p.nom} (${_formatHa(ha)})' : p.nom;
          return DropdownMenuItem<String?>(
            value: p.id,
            child: Text(
              label,
              style: AppTextStyles.bodyMedium.copyWith(fontSize: 14),
              overflow: TextOverflow.ellipsis,
            ),
          );
        }),
      ],
      onChanged: enabled ? onChanged : null,
    );
  }

  static String _formatHa(double ha) {
    if (ha == ha.roundToDouble()) return '${ha.toStringAsFixed(0)} ha';
    return '${ha.toStringAsFixed(1)} ha';
  }
}
