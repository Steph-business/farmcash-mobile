import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../models/commande.dart';
import '../../../../models/enums.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';

/// Photo URL utilisée comme placeholder hero quand on ne lie pas encore
/// la commande à une annonce/lot avec photo. À terme, à remplacer par la
/// première photo du lot/annonce associé.
const String _kHeroPhoto =
    'https://images.unsplash.com/photo-1601493700631-2b16ec4b4716?w=300&h=300&fit=crop&auto=format';

/// Carte hero d'une commande côté producteur : photo carrée à gauche +
/// quantité commandée + statut traduit en français. Posée en haut de la
/// page détail.
class CarteHeroCommande extends StatelessWidget {
  const CarteHeroCommande({
    required this.commande,
    super.key,
  });

  final Commande commande;

  @override
  Widget build(BuildContext context) {
    final qte = NumberFormat('#,##0', 'fr_FR').format(commande.quantiteKg);
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.border,
          width: AppDimens.borderThin,
        ),
      ),
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.surfaceSoft,
                border: Border.all(
                  color: AppColors.border,
                  width: AppDimens.borderThin,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              clipBehavior: Clip.hardEdge,
              child: CachedNetworkImage(
                imageUrl: _kHeroPhoto,
                fit: BoxFit.cover,
                placeholder: (_, _) =>
                    Container(color: AppColors.surfaceSoft),
                errorWidget: (_, _, _) =>
                    Container(color: AppColors.surfaceSoft),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$qte kg commandés',
                  style: AppTextStyles.titleMedium.copyWith(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Statut : ${_statusLabel(commande.status)}',
                  style: AppTextStyles.bodySmall.copyWith(
                    fontSize: 12,
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

/// Libellé français du statut d'une commande pour affichage utilisateur.
String _statusLabel(OrderStatus s) {
  switch (s) {
    case OrderStatus.sent:
      return 'Envoyée';
    case OrderStatus.accepted:
      return 'Acceptée';
    case OrderStatus.rejected:
      return 'Refusée';
    case OrderStatus.inProgress:
      return 'En préparation';
    case OrderStatus.delivered:
      return 'Livrée';
    case OrderStatus.completed:
      return 'Terminée';
    case OrderStatus.disputed:
      return 'Litige';
    case OrderStatus.cancelled:
      return 'Annulée';
    case OrderStatus.unknown:
      return 'Inconnue';
  }
}
