import 'package:flutter/material.dart';

import '../../../../models/ville.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';

/// Dropdown de selection de ville/region dans l'edition du profil producteur.
/// Affiche un etat chargement, puis le selecteur une fois les villes pretes.
class VilleDropdownProfilEditer extends StatelessWidget {
  const VilleDropdownProfilEditer({
    required this.villes,
    required this.loading,
    required this.enabled,
    required this.selectedId,
    required this.onChanged,
    super.key,
  });

  final List<Ville> villes;
  final bool loading;
  final bool enabled;
  final String? selectedId;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppDimens.brInput,
          border: Border.all(
            color: AppColors.border,
            width: AppDimens.borderThin,
          ),
        ),
        child: Row(
          children: [
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            const SizedBox(width: 10),
            Text(
              'Chargement des villes…',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSubtle,
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
        hintText: 'Choisir une ville',
        hintStyle: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.textSubtle,
        ),
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: AppDimens.brInput,
          borderSide: const BorderSide(
            color: AppColors.border,
            width: AppDimens.borderThin,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppDimens.brInput,
          borderSide: const BorderSide(
            color: AppColors.border,
            width: AppDimens.borderThin,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppDimens.brInput,
          borderSide: const BorderSide(
            color: AppColors.primary,
            width: AppDimens.borderMedium,
          ),
        ),
      ),
      items: [
        for (final v in villes)
          DropdownMenuItem<String>(
            value: v.id,
            child: Text(v.nom),
          ),
      ],
    );
  }
}
