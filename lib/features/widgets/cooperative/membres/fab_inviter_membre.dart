import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_text_styles.dart';

/// Bouton flottant pour lancer l'invitation d'un nouveau farmer.
class FabInviterMembre extends StatelessWidget {
  const FabInviterMembre({super.key, required this.onTap});

  /// Action déclenchée au tap sur le bouton.
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(28),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(28),
        ),
        child: Row(
          children: [
            const Icon(Icons.person_add_alt_1, size: 18, color: Colors.white),
            const SizedBox(width: 8),
            Text(
              'Inviter',
              style: AppTextStyles.button.copyWith(
                color: AppColors.onPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
