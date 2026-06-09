import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';

const BorderRadius _kBrCard12 = BorderRadius.all(Radius.circular(12));

/// Champ de formulaire stylé pour les pages de création/édition de
/// véhicule et d'itinéraire (transporteur).
///
/// Affiche un label au-dessus, un `TextField` bordé et un texte d'aide
/// optionnel sous le champ.
class ChampFormulaireVehicule extends StatelessWidget {
  const ChampFormulaireVehicule({
    required this.label,
    required this.hint,
    required this.controller,
    this.keyboardType,
    this.inputFormatters,
    this.help,
    super.key,
  });

  final String label;
  final String hint;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? help;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.labelMedium.copyWith(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: _kBrCard12,
            border: Border.all(
              color: AppColors.borderStrong,
              width: AppDimens.borderThin,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            inputFormatters: inputFormatters,
            // Centre verticalement texte + hint dans le champ.
            textAlignVertical: TextAlignVertical.center,
            style: AppTextStyles.bodyMedium.copyWith(fontSize: 14),
            decoration: InputDecoration(
              isCollapsed: true,
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
              border: InputBorder.none,
              hintText: hint,
              hintStyle: AppTextStyles.hint.copyWith(
                fontSize: 13,
                color: AppColors.textSubtle,
              ),
            ),
          ),
        ),
        if (help != null) ...[
          const SizedBox(height: 4),
          Text(
            help!,
            style: AppTextStyles.labelSmall.copyWith(
              fontSize: 10,
              color: AppColors.textSubtle,
              height: 1.4,
            ),
          ),
        ],
      ],
    );
  }
}
