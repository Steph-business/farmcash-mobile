import 'package:flutter/material.dart';

import '../../../../models/traitement.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';
import 'detail_line_catalogue_traitements.dart';
import 'type_badge_catalogue_traitements.dart';

/// Dialog detaille pour un traitement du catalogue.
///
/// Affiche nom + badge, description, dosage, mode d'application, maladies
/// et cultures concernees, dans un scroll vertical limite a 80% de la
/// hauteur. Bouton « Fermer » en bas a droite.
class TraitementDetailDialogCatalogue extends StatelessWidget {
  const TraitementDetailDialogCatalogue({
    required this.traitement,
    super.key,
  });

  final Traitement traitement;

  @override
  Widget build(BuildContext context) {
    final description = traitement.description?.trim();
    final dosage = traitement.dosage?.trim();
    final mode = traitement.mode?.trim();
    final type = traitement.type?.trim();
    final maladies = traitement.maladies;
    final produits = traitement.produits;
    return Dialog(
      shape: const RoundedRectangleBorder(borderRadius: AppDimens.brCard),
      backgroundColor: AppColors.surface,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimens.space16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      traitement.nom,
                      style: AppTextStyles.titleLarge.copyWith(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  if (type != null && type.isNotEmpty) ...[
                    const SizedBox(width: 8),
                    TypeBadgeCatalogueTraitements(
                      type: type,
                      isBio: traitement.isBio,
                    ),
                  ],
                ],
              ),
              if (description != null && description.isNotEmpty) ...[
                AppDimens.vGap12,
                Text(description, style: AppTextStyles.bodyMedium),
              ],
              if (dosage != null && dosage.isNotEmpty) ...[
                AppDimens.vGap12,
                DetailLineCatalogueTraitements(
                  label: 'Dosage',
                  value: dosage,
                ),
              ],
              if (mode != null && mode.isNotEmpty) ...[
                AppDimens.vGap8,
                DetailLineCatalogueTraitements(
                  label: "Mode d'application",
                  value: mode,
                ),
              ],
              if (maladies.isNotEmpty) ...[
                AppDimens.vGap8,
                DetailLineCatalogueTraitements(
                  label: 'Maladies traitées',
                  value: maladies.join(', '),
                ),
              ],
              if (produits.isNotEmpty) ...[
                AppDimens.vGap8,
                DetailLineCatalogueTraitements(
                  label: 'Cultures concernées',
                  value: produits.join(', '),
                ),
              ],
              AppDimens.vGap16,
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Fermer'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
