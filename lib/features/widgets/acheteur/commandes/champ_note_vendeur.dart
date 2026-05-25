import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';

/// Champ texte multilignes (3 lignes) pour la note libre à laisser au
/// vendeur lors du paiement (ex : horaires de livraison, instructions
/// d'accès).
class ChampNoteVendeur extends StatelessWidget {
  const ChampNoteVendeur({required this.controller, super.key});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: 3,
      minLines: 3,
      style: AppTextStyles.bodyMedium.copyWith(
        fontSize: 13,
        color: AppColors.text,
      ),
      decoration: InputDecoration(
        hintText: 'Ex : livrer après 14h, contacter à l\'arrivée...',
        hintStyle: AppTextStyles.bodySmall.copyWith(
          fontSize: 13,
          color: AppColors.textSubtle,
        ),
        filled: true,
        fillColor: AppColors.background,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppColors.border,
            width: AppDimens.borderThin,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppColors.border,
            width: AppDimens.borderThin,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
    );
  }
}
