import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../models/annonce_vente.dart';
import '../../../../theme/app_colors.dart';

/// Photo « hero » d'une commande côté acheteur : grande image plein
/// largeur en haut de la page de détail. Tirée de la première photo de
/// l'annonce associée. Placeholder gris si pas de photo (annonce
/// dépubliée ou champ vide côté backend).
class PhotoHeroCommande extends StatelessWidget {
  const PhotoHeroCommande({
    required this.annonce,
    super.key,
  });

  /// Annonce associée à la commande. `null` si la commande n'a plus
  /// d'annonce liée (dépubliée).
  final AnnonceVente? annonce;

  @override
  Widget build(BuildContext context) {
    final photo = (annonce?.photos.isNotEmpty == true)
        ? annonce!.photos.first
        : null;
    return SizedBox(
      width: double.infinity,
      height: 160,
      child: photo != null
          ? CachedNetworkImage(
              imageUrl: photo,
              fit: BoxFit.cover,
              placeholder: (_, _) => Container(color: AppColors.surfaceSoft),
              errorWidget: (_, _, _) => Container(color: AppColors.surfaceSoft),
            )
          : Container(
              color: AppColors.surfaceSoft,
              alignment: Alignment.center,
              child: const Icon(
                Icons.shopping_bag_outlined,
                size: 48,
                color: AppColors.textSubtle,
              ),
            ),
    );
  }
}
