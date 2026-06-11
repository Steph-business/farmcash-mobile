// =====================================================================
//  Badge Parrainage Coop (chantier 5)
//  ---------------------------------------------------------------------
//  Matérialise le parrainage local d'une coopérative par une figure de
//  confiance (chef de village, agent ANADER, ex-président reconnu).
//  Pèse plus qu'une note 4.7/5 dans la culture rurale ivoirienne.
//
//  Visible quand les 3 champs ambassadeur sont renseignés. Cache
//  silencieusement sinon.
//
//  Pattern compact (chip) OU étendu (carte premium).
// =====================================================================

import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';

class BadgeParrainageCoop extends StatelessWidget {
  const BadgeParrainageCoop({
    super.key,
    required this.ambassadeurNom,
    required this.ambassadeurTitre,
    required this.ambassadeurOrganisation,
    this.compact = false,
  });

  final String? ambassadeurNom;
  final String? ambassadeurTitre;
  final String? ambassadeurOrganisation;

  /// Si true, affiche un chip discret (pour les listes).
  /// Si false (défaut), affiche une carte complète (pour les fiches détail).
  final bool compact;

  bool get _hasParrainage =>
      (ambassadeurNom?.trim().isNotEmpty ?? false) &&
      (ambassadeurTitre?.trim().isNotEmpty ?? false) &&
      (ambassadeurOrganisation?.trim().isNotEmpty ?? false);

  @override
  Widget build(BuildContext context) {
    if (!_hasParrainage) return const SizedBox.shrink();

    if (compact) {
      // Chip discret pour les cartes de liste.
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: const Color(0xFFFEF3C7),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFFCD34D)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.verified_user_rounded,
              size: 12,
              color: Color(0xFF92400E),
            ),
            const SizedBox(width: 4),
            Text(
              'Parrainée',
              style: AppTextStyles.labelSmall.copyWith(
                fontSize: 10.5,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF92400E),
              ),
            ),
          ],
        ),
      );
    }

    // Carte complète pour les fiches détail.
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF3C7),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFCD34D)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: const Color(0xFF92400E).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.verified_user_rounded,
              size: 21,
              color: Color(0xFF92400E),
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Coopérative parrainée',
                  style: AppTextStyles.labelSmall.copyWith(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.0,
                    color: const Color(0xFF92400E),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${ambassadeurNom!.trim()} · ${ambassadeurTitre!.trim()}',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontFamily: 'Poppins',
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                    color: AppColors.text,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  ambassadeurOrganisation!.trim(),
                  style: AppTextStyles.bodySmall.copyWith(
                    fontSize: 11.5,
                    color: AppColors.textSecondary,
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
