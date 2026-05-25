import 'package:flutter/material.dart';

import '../../../../models/produit.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';

/// Selecteur de produit dans le formulaire de publication : carte cliquable
/// qui affiche le produit choisi (ou un placeholder) avec un chevron pour
/// ouvrir la bottom sheet de choix.
class SelecteurProduitPublication extends StatelessWidget {
  const SelecteurProduitPublication({
    required this.produit,
    required this.onTap,
    super.key,
  });

  final Produit? produit;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimens.radiusCard),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(AppDimens.radiusCard),
          border: Border.all(
            color: AppColors.border,
            width: AppDimens.borderThin,
          ),
        ),
        padding: const EdgeInsets.fromLTRB(16, 14, 14, 14),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    produit?.nom ?? 'Choisir un produit',
                    style: AppTextStyles.titleLarge.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (produit != null) ...[
                    const SizedBox(height: 3),
                    Text(
                      'Catalogue · ${produit!.slug}',
                      style: AppTextStyles.bodySmall.copyWith(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.chevron_right,
              size: 20,
              color: AppColors.textSubtle,
            ),
          ],
        ),
      ),
    );
  }
}
