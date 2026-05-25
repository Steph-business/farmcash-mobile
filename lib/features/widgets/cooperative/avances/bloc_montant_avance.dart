import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_text_styles.dart';

/// Bloc de saisie du montant de l'avance : libellé « Montant à verser »,
/// champ texte large centré (digits only) et unité FCFA en sous-titre.
class BlocMontantAvance extends StatelessWidget {
  const BlocMontantAvance({required this.controller, super.key});
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'Montant à verser',
          style: AppTextStyles.bodySmall.copyWith(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          textAlign: TextAlign.center,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          style: AppTextStyles.displayLarge.copyWith(
            fontSize: 36,
            fontWeight: FontWeight.w700,
            letterSpacing: -1,
            color: AppColors.text,
          ),
          decoration: const InputDecoration(
            isDense: true,
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(vertical: 4),
            hintText: '0',
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'FCFA',
          style: AppTextStyles.labelMedium.copyWith(
            fontSize: 12,
            color: AppColors.textSubtle,
          ),
        ),
      ],
    );
  }
}
