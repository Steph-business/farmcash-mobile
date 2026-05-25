import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../routing/route_names.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';
import 'modele_demande_affichage.dart';

const Color _kPrimarySoft = Color(0xFFE8F5E9);

/// Carte cliquable représentant une demande d'achat dans la liste
/// « Mes demandes » côté acheteur. Tap conduit vers les propositions reçues.
class CarteDemandeAcheteur extends StatelessWidget {
  const CarteDemandeAcheteur({required this.demande, super.key});

  /// Modèle d'affichage de la demande (déjà formaté).
  final ModeleDemandeAffichage demande;

  @override
  Widget build(BuildContext context) {
    final hasProps = demande.propositions > 0;
    return InkWell(
      onTap: () => context.push(
        RouteNames.acheteurPropositionsRecuesPathFor(demande.id),
      ),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: AppColors.border,
            width: AppDimens.borderThin,
          ),
        ),
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Photo produit 60×60
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: CachedNetworkImage(
                imageUrl: demande.photoUrl,
                width: 60,
                height: 60,
                fit: BoxFit.cover,
                placeholder: (_, _) => Container(
                  width: 60,
                  height: 60,
                  color: AppColors.surfaceSoft,
                ),
                errorWidget: (_, _, _) => Container(
                  width: 60,
                  height: 60,
                  color: AppColors.surfaceSoft,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${demande.produitNom} · ${demande.quantite}',
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${demande.prixMaxLabel} · ${demande.villeLabel}',
                    style: AppTextStyles.bodySmall.copyWith(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${demande.propositions} propositions reçues · ${demande.publieIlYa}',
                    style: AppTextStyles.labelSmall.copyWith(
                      fontSize: 11,
                      color: AppColors.textSubtle,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: hasProps ? _kPrimarySoft : AppColors.surfaceSoft,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    hasProps
                        ? '${demande.propositions} propositions'
                        : 'En attente',
                    style: AppTextStyles.labelSmall.copyWith(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color:
                          hasProps ? AppColors.primary : AppColors.textSecondary,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                const Icon(
                  Icons.chevron_right,
                  size: 18,
                  color: AppColors.textSubtle,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
