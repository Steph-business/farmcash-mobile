import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';

/// Champ numerique grande taille pour la creation de publication (quantite
/// en kg, prix par kg). Affiche un suffixe d'unite a droite et accepte
/// uniquement des chiffres.
class ChampGrandPublication extends StatelessWidget {
  const ChampGrandPublication({
    required this.controller,
    required this.suffix,
    required this.hint,
    required this.enabled,
    super.key,
  });

  final TextEditingController controller;
  final String suffix;
  final String hint;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppDimens.radiusCard),
        border: Border.all(
          color: AppColors.border,
          width: AppDimens.borderThin,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              enabled: enabled,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: false,
              ),
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              // Centre verticalement le texte dans le champ à hauteur
              // fixe — sinon le placeholder/saisie se cale en haut.
              textAlignVertical: TextAlignVertical.center,
              style: AppTextStyles.displayLarge.copyWith(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppColors.text,
              ),
              decoration: InputDecoration(
                hintText: hint,
                border: InputBorder.none,
                focusedBorder: InputBorder.none,
                enabledBorder: InputBorder.none,
                isCollapsed: true,
                contentPadding: EdgeInsets.zero,
                hintStyle: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSubtle,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            suffix,
            style: AppTextStyles.bodyMedium.copyWith(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
