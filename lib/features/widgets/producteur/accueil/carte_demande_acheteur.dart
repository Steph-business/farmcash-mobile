import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../models/annonce_achat.dart';
import '../../../../routing/route_names.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';
import 'accueil_constants.dart';
import 'buyer_avatar.dart';

/// Card horizontale d'une annonce d'achat ("acheteur qui cherche") sur
/// l'accueil producteur : avatar + nom + région + produit/quantité + prix
/// max. Tappable pour ouvrir l'écran "Répondre à la demande".
class CarteDemandeAcheteur extends StatelessWidget {
  const CarteDemandeAcheteur({super.key, required this.annonce});

  final AnnonceAchat annonce;

  @override
  Widget build(BuildContext context) {
    final qte = NumberFormat('#,##0', 'fr_FR').format(annonce.quantiteKg);
    final prix = NumberFormat('#,##0', 'fr_FR').format(annonce.prixMaxKg);
    // Titre : on privilégie le nom du PRODUIT (joint via `produits_agricoles`)
    // car c'est ce que le producteur reconnaît immédiatement. Fallback sur le
    // titre libre de l'annonce, puis sur "Cherche X kg" si rien.
    final produitLabel = annonce.produitLabel;
    // Le backend joint `users` avec full_name + photo_url. On NE doit jamais
    // afficher le `buyerId` (UUID) — c'est illisible. Fallback `'Acheteur'`
    // si la jointure n'a pas ramené le nom (cas très rare).
    final nom = annonce.buyerNom?.trim().isNotEmpty == true
        ? annonce.buyerNom!.trim()
        : 'Acheteur';
    final photoUrl = annonce.buyer?.photoUrl;
    // Idem pour la région : on utilise le `regions_ci.nom` joint, pas l'UUID.
    final region = annonce.regionNom?.trim().isNotEmpty == true
        ? annonce.regionNom!.trim()
        : null;

    return Material(
      color: AppColors.surface,
      borderRadius: kAccueilBrCard,
      child: InkWell(
        onTap: () => context.push(
          RouteNames.producteurDemandeAchatRepondrePathFor(annonce.id),
        ),
        borderRadius: kAccueilBrCard,
        child: Container(
          width: 250,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: kAccueilBrCard,
            border:
                Border.all(color: AppColors.border, width: AppDimens.borderThin),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Photo réelle si jointure présente, sinon initiales du nom.
                  BuyerAvatar(photoUrl: photoUrl, fallbackName: nom),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          nom,
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (region != null) ...[
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
                '$produitLabel · $qte kg',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
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
      ),
    );
  }
}
