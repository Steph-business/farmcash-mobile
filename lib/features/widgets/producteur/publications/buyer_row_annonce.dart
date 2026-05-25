import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../models/negociation.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';
import 'annonce_detail_constants.dart';
import 'annonce_detail_helpers.dart';

/// Ligne « acheteur intéressé » de la section propositions sur la page
/// détail d'une annonce producteur : avatar, identifiant tronqué, quantité
/// et prix proposés, statut de négociation, bouton « Répondre ».
class BuyerRowAnnonce extends StatelessWidget {
  const BuyerRowAnnonce({
    required this.candidature,
    required this.isLast,
    required this.onRepondre,
    super.key,
  });

  final Candidature candidature;
  final bool isLast;
  final VoidCallback onRepondre;

  @override
  Widget build(BuildContext context) {
    final qte =
        NumberFormat('#,##0', 'fr_FR').format(candidature.quantiteKg);
    final prix =
        NumberFormat('#,##0', 'fr_FR').format(candidature.prixProposeKg);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: isLast ? Colors.transparent : AppColors.border,
            width: AppDimens.borderThin,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: kAnnonceDetailPrimarySoft,
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.border,
                width: AppDimens.borderThin,
              ),
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.person_outline,
              size: 18,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Acheteur ${_short(candidature.buyerId)}',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '$qte kg · $prix F/kg · '
                  '${annonceDetailNegotiationStatusLabel(candidature.status)}',
                  style: AppTextStyles.labelSmall.copyWith(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          InkWell(
            onTap: onRepondre,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.primary,
                  width: AppDimens.borderThin,
                ),
              ),
              child: Text(
                'Répondre',
                style: AppTextStyles.labelMedium.copyWith(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _short(String uuid) =>
      uuid.length >= 6 ? uuid.substring(0, 6) : uuid;
}
