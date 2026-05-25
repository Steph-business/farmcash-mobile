import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../models/annonce_vente.dart';
import '../../../../models/commande.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';

/// Carte affichant le titre principal de la commande côté acheteur :
/// quantité + nom du produit en gros, et sous-titre composite avec la
/// localisation et la date de passation. Posée directement sous la
/// photo hero, avec une bordure en bas qui sépare du reste de la page.
class CarteTitreCommande extends StatelessWidget {
  const CarteTitreCommande({
    required this.commande,
    required this.annonce,
    super.key,
  });

  final Commande commande;

  /// Annonce associée pour récupérer le nom du produit et la
  /// localisation. `null` si l'annonce a été dépubliée.
  final AnnonceVente? annonce;

  @override
  Widget build(BuildContext context) {
    final nf = NumberFormat('#,##0', 'fr_FR');
    final nom = annonce?.produitLabel ?? 'Commande';
    final qte = nf.format(commande.quantiteKg.round());
    final loc = annonce?.localisationLabel;
    final df = DateFormat('d MMM', 'fr_FR');
    final passe = commande.createdAt != null
        ? 'Passée le ${df.format(commande.createdAt!)}'
        : null;
    final sousTitre = [
      if (loc != null) loc,
      if (passe != null) passe,
    ].join(' · ');
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 14),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppColors.border,
            width: AppDimens.borderThin,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$qte kg $nom',
            style: AppTextStyles.titleMedium.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.text,
            ),
          ),
          if (sousTitre.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              sousTitre,
              style: AppTextStyles.bodySmall.copyWith(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
