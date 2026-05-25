import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';

const BorderRadius _kBrInput = BorderRadius.all(Radius.circular(10));

/// Champ texte standard du formulaire « membre géré » : encadré clair,
/// pas de label flottant. Utilisé pour Nom complet et Village.
class ChampTexteManaged extends StatelessWidget {
  const ChampTexteManaged({
    super.key,
    required this.controller,
    required this.placeholder,
    required this.enabled,
    this.textCapitalization = TextCapitalization.words,
  });

  final TextEditingController controller;
  final String placeholder;
  final bool enabled;
  final TextCapitalization textCapitalization;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: _kBrInput,
        border: Border.all(
          color: AppColors.borderStrong,
          width: AppDimens.borderThin,
        ),
      ),
      child: TextField(
        controller: controller,
        enabled: enabled,
        textCapitalization: textCapitalization,
        style: AppTextStyles.bodyMedium.copyWith(fontSize: 14),
        decoration: InputDecoration(
          hintText: placeholder,
          hintStyle: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSubtle,
          ),
          border: InputBorder.none,
          isDense: true,
          contentPadding:
              const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        ),
      ),
    );
  }
}
