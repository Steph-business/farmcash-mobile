import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../models/annonce_achat.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';

const Color _kPrimarySoft = Color(0xFFE8F5E9);
const Color _kWarn = Color(0xFFB45309);

/// Carte de récapitulatif d'une demande d'achat (lecture seule).
///
/// Affiche le buyer (avatar + nom + région), la quantité demandée, le
/// prix max accepté, la date limite de livraison, et la description si
/// présente. Coordonnées de l'acheteur masquées : on indique seulement
/// que le transporteur les recevra.
class DemandeRecapCard extends StatelessWidget {
  const DemandeRecapCard({required this.demande, super.key});

  final AnnonceAchat demande;

  @override
  Widget build(BuildContext context) {
    final nomProduit = demande.produitLabel;
    final qte = '${_fmt(demande.quantiteKg)} kg';
    final prixMax = '${_fmt(demande.prixMaxKg)} F/kg';
    final region = demande.regionNom;
    final buyer = demande.buyerNom ?? 'Acheteur';
    final photo = demande.buyer?.photoUrl;
    final dateLimite = demande.dateLimiteLivraison;
    final dateLabel = dateLimite != null
        ? 'Livraison avant le ${DateFormat('d MMM y', 'fr_FR').format(dateLimite)}'
        : 'Date de livraison à confirmer';

    return Container(
      decoration: BoxDecoration(
        color: _kPrimarySoft,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.border,
          width: AppDimens.borderThin,
        ),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipOval(
                child: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceSoft,
                    border: Border.all(
                      color: AppColors.border,
                      width: AppDimens.borderThin,
                    ),
                    shape: BoxShape.circle,
                  ),
                  clipBehavior: Clip.hardEdge,
                  child: photo != null && photo.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: photo,
                          fit: BoxFit.cover,
                          placeholder: (_, _) =>
                              Container(color: AppColors.surfaceSoft),
                          errorWidget: (_, _, _) =>
                              Container(color: AppColors.surfaceSoft),
                        )
                      : Container(
                          color: AppColors.background,
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.person_outline,
                            size: 22,
                            color: AppColors.primary,
                          ),
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
                      buyer,
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (region != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        region,
                        style: AppTextStyles.bodySmall.copyWith(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        border: Border.all(
                          color: AppColors.border,
                          width: AppDimens.borderThin,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Coordonnées partagées avec le transporteur uniquement',
                        style: AppTextStyles.labelSmall.copyWith(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '$qte de $nomProduit',
            style: AppTextStyles.displayLarge.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Prix max accepté : $prixMax',
            style: AppTextStyles.displayLarge.copyWith(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            dateLabel,
            style: AppTextStyles.labelSmall.copyWith(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: _kWarn,
            ),
          ),
          if (demande.description != null &&
              demande.description!.trim().isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              demande.description!,
              style: AppTextStyles.bodySmall.copyWith(
                fontSize: 11,
                color: AppColors.text,
                height: 1.5,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

String _fmt(double v) => NumberFormat('#,##0', 'fr_FR').format(v.round());
