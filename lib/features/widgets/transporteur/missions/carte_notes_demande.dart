import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';

const BorderRadius _kBrCard = BorderRadius.all(Radius.circular(12));

/// Carte « Notes » d'une demande de transport entrante : affiche le texte
/// libre ajouté par l'émetteur (instructions, particularités, etc.).
class CarteNotesDemande extends StatelessWidget {
  const CarteNotesDemande({required this.notes, super.key});

  final String notes;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: _kBrCard,
        border: Border.all(
          color: AppColors.border,
          width: AppDimens.borderThin,
        ),
      ),
      child: Text(
        notes,
        style: AppTextStyles.bodySmall.copyWith(
          fontSize: 12,
          color: AppColors.text,
          height: 1.5,
        ),
      ),
    );
  }
}
