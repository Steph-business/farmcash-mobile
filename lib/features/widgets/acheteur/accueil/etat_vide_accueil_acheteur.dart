import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';
import 'accueil_acheteur_constants.dart';

/// État vide global de l'accueil acheteur — affiché si on n'a ni
/// catégories, ni annonces, ni demandes (marché complètement vide).
/// Embarque son propre `RefreshIndicator` pour permettre un pull-to-refresh
/// même quand la page n'a aucun contenu scrollable.
class EtatVideAccueilAcheteur extends StatelessWidget {
  const EtatVideAccueilAcheteur({super.key, required this.onRefresh});

  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      color: AppColors.primary,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          AppDimens.pagePaddingH,
          AppDimens.space48,
          AppDimens.pagePaddingH,
          AppDimens.space24,
        ),
        children: [
          Text(
            'Aucun produit pour le moment',
            style: AppTextStyles.headlineSmall,
            textAlign: TextAlign.center,
          ),
          AppDimens.vGap8,
          Text(
            'Le marché est vide. Reviens dans quelques instants.',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          AppDimens.vGap24,
          Center(
            child: SizedBox(
              height: AppDimens.buttonHeightSmall,
              child: OutlinedButton(
                onPressed: onRefresh,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(
                    color: AppColors.borderStrong,
                    width: AppDimens.borderThin,
                  ),
                  shape: const RoundedRectangleBorder(
                    borderRadius: AppDimens.brButton,
                  ),
                ),
                child: const Text('Actualiser'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Placeholder neutre affiché à l'intérieur d'une section quand elle n'a
/// rien à montrer (filtre catégorie vide). Petite carte surfaceSoft avec
/// un message centré.
class EtatVideSectionAccueil extends StatelessWidget {
  const EtatVideSectionAccueil({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.space16,
        vertical: AppDimens.space24,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceSoft,
        borderRadius: kAccueilBrCard,
        border: Border.all(
          color: AppColors.border,
          width: AppDimens.borderThin,
        ),
      ),
      child: Text(
        message,
        style: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.textSecondary,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
