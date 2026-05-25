import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../models/parcelle.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';

/// Sélecteur de parcelle pour rattacher une proposition.
///
/// Si le producteur n'a pas encore déclaré de parcelle, on affiche un
/// bandeau gris d'information à la place du dropdown.
class DemandeParcelleSelector extends StatelessWidget {
  const DemandeParcelleSelector({
    required this.parcelles,
    required this.selectedId,
    required this.onChanged,
    required this.enabled,
    super.key,
  });

  final List<Parcelle> parcelles;
  final String? selectedId;
  final ValueChanged<String?> onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    if (parcelles.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surfaceSoft,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: AppColors.border,
            width: AppDimens.borderThin,
          ),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.info_outline,
              size: 16,
              color: AppColors.textSubtle,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Aucune parcelle déclarée — déclare-en une pour rattacher tes offres.',
                style: AppTextStyles.bodySmall.copyWith(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      );
    }
    return DropdownButtonFormField<String>(
      initialValue: selectedId,
      isExpanded: true,
      onChanged: enabled ? onChanged : null,
      decoration: InputDecoration(
        filled: true,
        fillColor: AppColors.background,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
            color: AppColors.borderStrong,
            width: AppDimens.borderThin,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
            color: AppColors.borderStrong,
            width: AppDimens.borderThin,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
            color: AppColors.primary,
            width: AppDimens.borderMedium,
          ),
        ),
      ),
      items: [
        for (final p in parcelles)
          DropdownMenuItem<String>(
            value: p.id,
            child: Text(
              '${p.nom} · ${_fmt(p.superficieHa ?? 0)} ha',
            ),
          ),
      ],
    );
  }
}

String _fmt(double v) => NumberFormat('#,##0', 'fr_FR').format(v.round());
