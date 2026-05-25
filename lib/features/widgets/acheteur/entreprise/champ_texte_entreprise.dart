import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';

/// Champ de texte d'un formulaire d'identité business (Mon entreprise).
///
/// Présente un label en gras au-dessus, un champ stylé avec helper texte
/// optionnel, et désactivable en mode lecture seule (afficher la valeur
/// dans le champ disabled). Le mode édition expose une bordure primary
/// quand le focus est posé.
class ChampTexteEntreprise extends StatelessWidget {
  /// Construit le champ.
  const ChampTexteEntreprise({
    super.key,
    required this.label,
    required this.controller,
    this.helper,
    this.placeholder,
    this.keyboardType,
    this.maxLines = 1,
    this.activable = true,
    this.suffixIcon,
  });

  /// Libellé affiché au-dessus.
  final String label;

  /// Controller du champ — géré par la page parente.
  final TextEditingController controller;

  /// Texte d'aide affiché en petit sous le champ.
  final String? helper;

  /// Placeholder du champ.
  final String? placeholder;

  /// Type de clavier (numérique, email…). Si null = texte standard.
  final TextInputType? keyboardType;

  /// Nombre de lignes max (défaut 1, mettre 4-6 pour adresse).
  final int maxLines;

  /// Si false, le champ est désactivé (mode lecture seule).
  final bool activable;

  /// Icône suffix optionnelle.
  final Widget? suffixIcon;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.labelMedium.copyWith(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AppColors.text,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          enabled: activable,
          keyboardType: keyboardType,
          maxLines: maxLines,
          style: AppTextStyles.bodyMedium,
          decoration: InputDecoration(
            hintText: placeholder,
            hintStyle: AppTextStyles.hint,
            filled: true,
            fillColor: activable
                ? AppColors.background
                : AppColors.surfaceSoft,
            suffixIcon: suffixIcon,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppDimens.space12,
              vertical: 14,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: AppDimens.brInput,
              borderSide: BorderSide(
                color: AppColors.borderStrong,
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
            disabledBorder: OutlineInputBorder(
              borderRadius: AppDimens.brInput,
              borderSide: BorderSide(
                color: AppColors.border,
                width: AppDimens.borderThin,
              ),
            ),
          ),
        ),
        if (helper != null) ...[
          const SizedBox(height: 6),
          Text(
            helper!,
            style: AppTextStyles.bodySmall.copyWith(
              fontSize: 11,
              color: AppColors.textSubtle,
            ),
          ),
        ],
      ],
    );
  }
}
