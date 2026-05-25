import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_text_styles.dart';

/// Libellé textuel au-dessus d'un champ de saisie dans le formulaire
/// d'invitation d'un farmer (Téléphone, Message personnalisé...).
class LibelleChampInvitation extends StatelessWidget {
  const LibelleChampInvitation(this.label, {super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: AppTextStyles.labelMedium.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: AppColors.text,
      ),
    );
  }
}
