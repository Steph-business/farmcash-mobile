import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../models/negociation.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_text_styles.dart';

/// Bandeau « Garanties » affiché sur une proposition reçue par
/// l'acheteur quand le vendeur est une **coopérative** (vs un farmer
/// individuel). Matérialise visuellement la promesse :
///
///   1. Coopérative vérifiée + nom + photo
///   2. Nombre de membres producteurs (signal de capacité collective)
///   3. Note moyenne + rating
///   4. Rappel du mécanisme escrow + refund auto si non-livraison
///
/// Réduit l'hésitation de l'acheteur sur un gros engagement coop
/// (qui peut être à 5M F+ pour des volumes industriels).
class CarteGarantiesCoop extends StatelessWidget {
  const CarteGarantiesCoop({super.key, required this.vendeur});

  final VendeurProposition vendeur;

  @override
  Widget build(BuildContext context) {
    final coop = vendeur.cooperative;
    if (coop == null) return const SizedBox.shrink();
    final nbMembres = coop.nbMembres;
    final rating = vendeur.rating;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withValues(alpha: 0.08),
            AppColors.primary.withValues(alpha: 0.03),
          ],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.30),
          width: 1.2,
        ),
      ),
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Ligne 1 : avatar + nom coop + badge vérifiée ─────────
          Row(
            children: [
              ClipOval(
                child: Container(
                  width: 40,
                  height: 40,
                  color: AppColors.primary.withValues(alpha: 0.15),
                  child: (vendeur.photoUrl != null &&
                          vendeur.photoUrl!.isNotEmpty)
                      ? CachedNetworkImage(
                          imageUrl: vendeur.photoUrl!,
                          fit: BoxFit.cover,
                          errorWidget: (_, _, _) => const Icon(
                            Icons.groups_rounded,
                            color: AppColors.primary,
                          ),
                        )
                      : const Icon(
                          Icons.groups_rounded,
                          size: 22,
                          color: AppColors.primary,
                        ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            coop.nom,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.bodyMedium.copyWith(
                              fontFamily: 'Poppins',
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: AppColors.text,
                              letterSpacing: -0.2,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(
                          Icons.verified_rounded,
                          size: 16,
                          color: AppColors.primary,
                        ),
                      ],
                    ),
                    const SizedBox(height: 1),
                    Text(
                      'Coopérative vérifiée',
                      style: AppTextStyles.bodySmall.copyWith(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // ── Ligne 2 : stats clés (membres + note) ───────────────
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  icone: Icons.groups_outlined,
                  valeur: nbMembres > 0 ? '$nbMembres' : '—',
                  label: nbMembres > 1
                      ? 'producteurs\nmembres'
                      : 'producteur\nmembre',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _StatCard(
                  icone: Icons.star_rounded,
                  valeur: rating != null && rating > 0
                      ? rating.toStringAsFixed(1)
                      : '—',
                  label: 'note\nmoyenne',
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // ── Ligne 3 : rappel garantie escrow ─────────────────────
          Container(
            padding: const EdgeInsets.fromLTRB(10, 9, 10, 9),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.25),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.shield_rounded,
                  size: 16,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Ton argent reste en escrow jusqu\'à la livraison. '
                    'Refund automatique si la coop ne livre pas.',
                    style: AppTextStyles.bodySmall.copyWith(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.text,
                      height: 1.4,
                    ),
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

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icone,
    required this.valeur,
    required this.label,
  });

  final IconData icone;
  final String valeur;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(icone, size: 22, color: AppColors.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  valeur,
                  style: AppTextStyles.titleSmall.copyWith(
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.text,
                    letterSpacing: -0.3,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  label,
                  style: AppTextStyles.bodySmall.copyWith(
                    fontSize: 10,
                    color: AppColors.textSecondary,
                    height: 1.2,
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
