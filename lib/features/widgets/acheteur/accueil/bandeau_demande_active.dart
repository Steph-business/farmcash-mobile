import 'package:flutter/material.dart';

import '../../../../models/annonce_achat.dart';
import '../../../../models/produit.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';
import 'accueil_acheteur_constants.dart';
import 'accueil_acheteur_formats.dart';

/// Bandeau affichant la (les) demande(s) d'achat active(s) de l'acheteur.
///
/// Affiche le titre de la première demande (quantité + produit) et un
/// compteur en pilule à droite. Tap → page liste des demandes.
class BandeauDemandeActive extends StatelessWidget {
  const BandeauDemandeActive({
    super.key,
    required this.demandes,
    required this.produitsParId,
    required this.onTap,
  });

  final List<AnnonceAchat> demandes;
  final Map<String, Produit> produitsParId;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final premiere = demandes.first;
    final produitNom = produitsParId[premiere.produitId]?.nom;
    final qte = formatKgAccueil(premiere.quantiteKg);

    final titre = produitNom != null
        ? 'Ma demande : $qte de $produitNom'
        : 'Ma demande : $qte';
    final sousTitre = demandes.length > 1
        ? '${demandes.length} demandes actives'
        : 'Demande active';

    return InkWell(
      onTap: onTap,
      borderRadius: AppDimens.brCard,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimens.space16,
          vertical: AppDimens.space12,
        ),
        decoration: BoxDecoration(
          color: AppColors.surfaceSoft,
          borderRadius: AppDimens.brCard,
          border: Border.all(
            color: AppColors.border,
            width: AppDimens.borderThin,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(AppDimens.radiusS),
                border: Border.all(
                  color: AppColors.border,
                  width: AppDimens.borderThin,
                ),
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.shopping_cart_outlined,
                size: AppDimens.iconM,
                color: AppColors.textSecondary,
              ),
            ),
            AppDimens.hGap12,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    titre,
                    style: AppTextStyles.titleSmall.copyWith(fontSize: 13),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    sousTitre,
                    style: AppTextStyles.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            AppDimens.hGap8,
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: kAccueilPrimarySoft,
                borderRadius: BorderRadius.circular(AppDimens.radiusPill),
              ),
              child: Text(
                '${demandes.length}',
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
