import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_text_styles.dart';

/// Hero de confirmation de commande — version concise.
///
/// Pastille verte + check, titre court « Commande passée ! », et une
/// seule ligne d'accroche. Pas de paragraphe explicatif : la suite de
/// la page (stepper) le dit visuellement.
class HeroCommandeSucces extends StatelessWidget {
  const HeroCommandeSucces({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 14),
      child: Column(
        children: [
          // Pastille verte avec halo léger — donne une sensation de
          // « validé » sans surcharger l'écran.
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary.withValues(alpha: 0.12),
            ),
            alignment: Alignment.center,
            child: Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary,
              ),
              alignment: Alignment.center,
              child: const Icon(Icons.check, size: 38, color: Colors.white),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Commande passée !',
            style: AppTextStyles.headlineLarge.copyWith(
              fontFamily: 'Poppins',
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Tu seras notifié à chaque étape',
            style: AppTextStyles.bodySmall.copyWith(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
