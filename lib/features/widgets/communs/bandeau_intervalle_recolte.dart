import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../models/publication_coop.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';

/// Bandeau « Récolté entre le X et le Y » — affiché sur la fiche d'une
/// publication coop quand au moins une contribution a renseigné sa
/// `date_recolte`. Signal de fraîcheur crucial pour produits frais
/// (manioc, tomate, banane, ...) côté acheteur.
///
/// Source : `publication.datesRecolteAnnonces` (parsé depuis le payload
/// backend `publication_contributions[].annonces_vente.date_recolte`).
/// Si la liste est vide → widget caché (SizedBox.shrink).
///
/// Réutilisable côté acheteur (fiche publication coop) ET côté coop /
/// producteur (fiche détail publication propre). Pas de dépendance UI
/// au rôle — le composant reste neutre.
class BandeauIntervalleRecolte extends StatelessWidget {
  const BandeauIntervalleRecolte({super.key, required this.publication});

  final PublicationCoop publication;

  @override
  Widget build(BuildContext context) {
    final min = publication.dateRecolteMin;
    final max = publication.dateRecolteMax;
    if (min == null || max == null) return const SizedBox.shrink();

    final fmtJour = DateFormat('d MMM', 'fr_FR');
    final memeJour = min.difference(max).inDays.abs() < 1;
    final phrase = memeJour
        ? 'Récolté le ${fmtJour.format(min)}'
        : 'Récolté entre le ${fmtJour.format(min)} et le ${fmtJour.format(max)}';

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withValues(alpha: 0.10),
            AppColors.primary.withValues(alpha: 0.04),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.25),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(9),
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.event_available_rounded,
              size: 17,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  phrase,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontFamily: 'Poppins',
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.text,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  memeJour
                      ? 'Lot récolté sur 1 journée — fraîcheur garantie.'
                      : 'Fraîcheur récente du lot agrégé.',
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
