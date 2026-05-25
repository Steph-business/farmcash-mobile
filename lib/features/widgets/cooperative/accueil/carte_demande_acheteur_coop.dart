import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../models/annonce_achat.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';
import '_constantes_accueil_coop.dart';
import 'avatar_initiales_coop.dart';

/// Card horizontale d'une annonce d'achat ciblant la coop. Affiche
/// l'acheteur (avatar + id court), la région, la quantité recherchée et
/// le prix maximum, avec un badge "Nouveau" en surimpression.
class CarteDemandeAcheteurCoop extends StatelessWidget {
  const CarteDemandeAcheteurCoop({super.key, required this.annonce});

  final AnnonceAchat annonce;

  @override
  Widget build(BuildContext context) {
    final qte = NumberFormat('#,##0', 'fr_FR').format(annonce.quantiteKg);
    final prix = NumberFormat('#,##0', 'fr_FR').format(annonce.prixMaxKg);
    final region = annonce.regionId;
    final produit = (annonce.titre ?? '').trim().isNotEmpty
        ? annonce.titre!.trim()
        : 'produit';

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 250,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: kBrCardCoop,
            border: Border.all(
              color: AppColors.border,
              width: AppDimens.borderThin,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  AvatarInitialesCoop(seed: annonce.buyerId),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Acheteur ${initialesAccueilCoop(annonce.buyerId)}',
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (region != null && region.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            region,
                            style: AppTextStyles.bodySmall.copyWith(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                'Cherche $qte kg $produit',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),
              Text(
                'jusqu\'à $prix F/kg',
                style: AppTextStyles.titleLarge.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                  letterSpacing: -0.2,
                  height: 1.2,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        // Petit badge "Nouveau" — opportunité acheteur ciblée sur la coop.
        Positioned(
          top: 8,
          right: 8,
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: kWarnSoftCoop,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              'Nouveau',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: kWarnAccentCoop,
                height: 1.1,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
