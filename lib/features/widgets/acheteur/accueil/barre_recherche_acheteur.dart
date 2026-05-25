import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';

/// Barre de recherche compacte affichée sous le header de l'accueil
/// acheteur. Non éditable : un tap pousse vers la page recherche dédiée.
class BarreRechercheAcheteur extends StatelessWidget {
  const BarreRechercheAcheteur({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppDimens.brInput,
      child: Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: AppDimens.brInput,
          border: Border.all(
            color: AppColors.borderStrong,
            width: AppDimens.borderThin,
          ),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.search,
              size: AppDimens.iconM,
              color: AppColors.textSubtle,
            ),
            AppDimens.hGap8,
            Expanded(
              child: Text(
                'Rechercher un produit, une région…',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSubtle,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
