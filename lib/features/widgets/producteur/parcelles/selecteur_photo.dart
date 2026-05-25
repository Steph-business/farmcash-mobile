import 'dart:io';

import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';

/// Sélecteur de photo de parcelle (optionnel).
///
/// Affiche un placeholder cliquable quand [photo] est `null`, ou
/// l'aperçu de l'image avec un bouton de suppression en haut à droite.
class SelecteurPhoto extends StatelessWidget {
  const SelecteurPhoto({
    required this.photo,
    required this.enabled,
    required this.onTap,
    required this.onRemove,
    super.key,
  });

  final File? photo;
  final bool enabled;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    if (photo == null) {
      return InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 100,
          decoration: BoxDecoration(
            color: AppColors.surfaceSoft,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.borderStrong,
              width: AppDimens.borderThin,
              style: BorderStyle.solid,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.add_a_photo_outlined,
                size: 24,
                color: AppColors.textSecondary,
              ),
              const SizedBox(height: 6),
              Text(
                'Ajouter une photo',
                style: AppTextStyles.bodySmall.copyWith(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      );
    }
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.file(
            photo!,
            width: double.infinity,
            height: 160,
            fit: BoxFit.cover,
          ),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: InkWell(
            onTap: enabled ? onRemove : null,
            borderRadius: BorderRadius.circular(20),
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.text.withValues(alpha: 0.6),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.close,
                size: 18,
                color: AppColors.onPrimary,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
