import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_text_styles.dart';

/// Bannière rouge soft affichée au producteur quand sa coopérative a
/// refusé une annonce de vente ou une prévision de récolte
/// (`coopStatus == REJECTED`). Reprend la couleur AppColors.error en
/// version atténuée + icône cancel + label uppercase + motif texte.
///
/// Si le motif est null/vide → message générique « Pas de motif précisé »
/// pour éviter une bannière fantôme sans contenu utile.
class BanniereMotifRejet extends StatelessWidget {
  const BanniereMotifRejet({super.key, required this.motif});

  /// Motif tel que stocké côté backend (colonne `rejected_reason`).
  /// Nullable car certaines coops historiques ont refusé sans motif.
  final String? motif;

  @override
  Widget build(BuildContext context) {
    final texte = (motif != null && motif!.trim().isNotEmpty)
        ? motif!.trim()
        : 'Pas de motif précisé par la coopérative.';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFEE2E2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.error.withValues(alpha: 0.30),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.cancel_outlined,
            size: 22,
            color: AppColors.error,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'MOTIF DE REJET',
                  style: AppTextStyles.labelSmall.copyWith(
                    fontFamily: 'Poppins',
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                    color: AppColors.error,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  texte,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontSize: 13,
                    height: 1.4,
                    color: AppColors.text,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
