import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';

/// Bouton incrémenter / décrémenter du sélecteur de quantité dans la barre
/// sticky du détail annonce acheteur. Carré 36×36, fond surfaceSoft, texte
/// grisé quand `onTap` est `null` (état désactivé aux bornes min/max).
class StepBtnAnnonce extends StatelessWidget {
  const StepBtnAnnonce({
    required this.label,
    required this.onTap,
    super.key,
  });

  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        color: AppColors.surfaceSoft,
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: enabled ? AppColors.text : AppColors.textSubtle,
          ),
        ),
      ),
    );
  }
}
