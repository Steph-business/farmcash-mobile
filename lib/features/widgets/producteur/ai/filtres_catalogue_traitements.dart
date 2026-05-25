import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';
import 'catalogue_traitements_constants.dart';
import 'type_chip_catalogue_traitements.dart';

/// Bandeau de filtres au-dessus de la liste des traitements.
///
/// Contient : barre de recherche (debounce gere par le parent), chips
/// horizontaux pour le type backend `TreatmentType`, et toggle "Bio
/// uniquement" (filtre transversal `is_bio=true`).
class FiltresCatalogueTraitements extends StatelessWidget {
  const FiltresCatalogueTraitements({
    required this.type,
    required this.bioOnly,
    required this.searchCtrl,
    required this.onTypeChanged,
    required this.onBioChanged,
    required this.onSearchChanged,
    super.key,
  });

  final FilterTypeCatalogueTraitements type;
  final bool bioOnly;
  final TextEditingController searchCtrl;
  final ValueChanged<FilterTypeCatalogueTraitements> onTypeChanged;
  final ValueChanged<bool> onBioChanged;
  final ValueChanged<String> onSearchChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppDimens.pagePaddingH,
        AppDimens.space12,
        AppDimens.pagePaddingH,
        AppDimens.space8,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search bar
          TextField(
            controller: searchCtrl,
            onChanged: onSearchChanged,
            style: AppTextStyles.bodyMedium,
            decoration: InputDecoration(
              hintText: 'Rechercher par maladie (mildiou, pyrale…)',
              hintStyle: AppTextStyles.hint,
              filled: true,
              fillColor: AppColors.surface,
              prefixIcon: const Icon(
                Icons.search,
                color: AppColors.textSubtle,
                size: 20,
              ),
              suffixIcon: searchCtrl.text.isEmpty
                  ? null
                  : IconButton(
                      icon: const Icon(
                        Icons.close,
                        color: AppColors.textSubtle,
                        size: 18,
                      ),
                      onPressed: () {
                        searchCtrl.clear();
                        onSearchChanged('');
                      },
                    ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 0,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: AppDimens.brInput,
                borderSide: const BorderSide(
                  color: AppColors.borderStrong,
                  width: AppDimens.borderThin,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: AppDimens.brInput,
                borderSide: const BorderSide(
                  color: AppColors.primary,
                  width: AppDimens.borderThin,
                ),
              ),
            ),
          ),
          AppDimens.vGap12,
          // Type chips horizontaux — alignes sur l'enum backend
          // `TreatmentType`. Le toggle "Bio uniquement" en dessous est
          // transversal (filtre `is_bio=true` sur tous les types).
          SizedBox(
            height: 32,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                TypeChipCatalogueTraitements(
                  label: 'Tous',
                  active: type == FilterTypeCatalogueTraitements.tous,
                  onTap: () =>
                      onTypeChanged(FilterTypeCatalogueTraitements.tous),
                ),
                const SizedBox(width: 8),
                TypeChipCatalogueTraitements(
                  label: 'Fongicide',
                  active: type == FilterTypeCatalogueTraitements.fongicide,
                  onTap: () =>
                      onTypeChanged(FilterTypeCatalogueTraitements.fongicide),
                ),
                const SizedBox(width: 8),
                TypeChipCatalogueTraitements(
                  label: 'Insecticide',
                  active: type == FilterTypeCatalogueTraitements.insecticide,
                  onTap: () =>
                      onTypeChanged(FilterTypeCatalogueTraitements.insecticide),
                ),
                const SizedBox(width: 8),
                TypeChipCatalogueTraitements(
                  label: 'Herbicide',
                  active: type == FilterTypeCatalogueTraitements.herbicide,
                  onTap: () =>
                      onTypeChanged(FilterTypeCatalogueTraitements.herbicide),
                ),
                const SizedBox(width: 8),
                TypeChipCatalogueTraitements(
                  label: 'Engrais',
                  active: type == FilterTypeCatalogueTraitements.engrais,
                  onTap: () =>
                      onTypeChanged(FilterTypeCatalogueTraitements.engrais),
                ),
                const SizedBox(width: 8),
                TypeChipCatalogueTraitements(
                  label: 'Bio-stimulant',
                  active:
                      type == FilterTypeCatalogueTraitements.bioStimulant,
                  onTap: () => onTypeChanged(
                      FilterTypeCatalogueTraitements.bioStimulant),
                ),
                const SizedBox(width: 8),
                TypeChipCatalogueTraitements(
                  label: 'Autre',
                  active: type == FilterTypeCatalogueTraitements.autre,
                  onTap: () =>
                      onTypeChanged(FilterTypeCatalogueTraitements.autre),
                ),
              ],
            ),
          ),
          AppDimens.vGap8,
          Row(
            children: [
              Text(
                'Bio uniquement',
                style: AppTextStyles.labelMedium.copyWith(fontSize: 13),
              ),
              const Spacer(),
              Switch(
                value: bioOnly,
                onChanged: onBioChanged,
                activeThumbColor: AppColors.primary,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
