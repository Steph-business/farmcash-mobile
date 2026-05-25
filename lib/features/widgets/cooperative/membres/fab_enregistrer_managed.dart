import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_text_styles.dart';

/// Bouton secondaire « Sans téléphone » affiché au-dessus du FAB
/// « Inviter ». Permet à la coop d'enregistrer un membre géré (qui
/// n'a pas de smartphone) — la coop publiera ses annonces en son nom.
class FabEnregistrerManaged extends StatelessWidget {
  const FabEnregistrerManaged({super.key, required this.onTap});

  /// Action déclenchée au tap.
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(28),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: AppColors.primary,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.phone_disabled_outlined,
              size: 18,
              color: AppColors.primary,
            ),
            const SizedBox(width: 8),
            Text(
              'Sans téléphone',
              style: AppTextStyles.button.copyWith(
                color: AppColors.primary,
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
