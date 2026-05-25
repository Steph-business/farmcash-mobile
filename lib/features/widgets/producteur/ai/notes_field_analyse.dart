import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';

/// TextField multi-lignes pour les notes optionnelles ("taches jaunes
/// apparues après la pluie…") jointes à une analyse plante.
class NotesFieldAnalyse extends StatelessWidget {
  const NotesFieldAnalyse({required this.controller, super.key});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      minLines: 3,
      maxLines: 5,
      style: AppTextStyles.bodyMedium,
      decoration: InputDecoration(
        hintText: 'Ex : taches jaunes apparues après la pluie…',
        hintStyle: AppTextStyles.hint,
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
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
    );
  }
}
