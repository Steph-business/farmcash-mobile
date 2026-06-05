import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../models/prevision.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';

/// Carte de prévision dans la grille de la page « Mes publications »
/// producteur : photo fallback + « Récolte prévue » + quantité + date +
/// prix cible + statut. Tap → ouvre le détail de la prévision.
class CartePrevisionPublication extends StatelessWidget {
  const CartePrevisionPublication({
    required this.prevision,
    required this.photoFallback,
    super.key,
  });

  final Prevision prevision;
  final String photoFallback;

  @override
  Widget build(BuildContext context) {
    final qte = NumberFormat('#,##0', 'fr_FR').format(prevision.quantitePrevKg);
    final date = prevision.dateRecoltePrev != null
        ? DateFormat('d MMM', 'fr_FR').format(prevision.dateRecoltePrev!)
        : null;
    final prixCible = prevision.prixCibleKg;

    return InkWell(
      onTap: () => context.push('/producteur/previsions/${prevision.id}'),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: AppColors.border,
            width: AppDimens.borderThin,
          ),
        ),
        clipBehavior: Clip.hardEdge,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 110,
              width: double.infinity,
              child: CachedNetworkImage(
                imageUrl: photoFallback,
                fit: BoxFit.cover,
                placeholder: (_, _) => Container(color: AppColors.surfaceSoft),
                errorWidget: (_, _, _) =>
                    Container(color: AppColors.surfaceSoft),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Récolte prévue',
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    date != null
                        ? '$qte kg prévus · $date'
                        : '$qte kg prévus',
                    style: AppTextStyles.bodySmall.copyWith(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    prixCible != null && prixCible > 0
                        ? '${NumberFormat('#,##0', 'fr_FR').format(prixCible)} F/kg'
                        : 'Prix à définir',
                    style: AppTextStyles.titleLarge.copyWith(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                      letterSpacing: -0.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  // Pill rouge compact si la coop a refusé — discret mais
                  // assez visible pour pousser le tap → détail (motif).
                  if (prevision.coopStatus == 'REJECTED') ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEE2E2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'Rejetée par la coop',
                        style: AppTextStyles.labelSmall.copyWith(
                          fontFamily: 'Poppins',
                          fontSize: 9.5,
                          fontWeight: FontWeight.w800,
                          color: AppColors.error,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                  ],
                  Text(
                    'Statut : ${_statusLabel(prevision)}',
                    style: AppTextStyles.labelSmall.copyWith(
                      fontSize: 10,
                      color: AppColors.textSubtle,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _statusLabel(Prevision p) {
    switch (p.status.apiValue) {
      case 'OPEN':
        return 'Ouverte';
      case 'CONVERTED':
        return 'Convertie';
      case 'EXPIRED':
        return 'Expirée';
      case 'CANCELLED':
        return 'Annulée';
      default:
        return p.status.apiValue;
    }
  }
}
