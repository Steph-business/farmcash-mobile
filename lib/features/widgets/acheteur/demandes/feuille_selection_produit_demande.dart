import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_text_styles.dart';
import 'publier_demande_constants.dart';

/// Bottom-sheet de sélection produit. Affiche la liste catalogue (image,
/// nom) avec une coche sur le produit déjà choisi. Renvoie via `onPick`.
class FeuilleSelectionProduitDemande extends StatelessWidget {
  const FeuilleSelectionProduitDemande({
    required this.produits,
    required this.selectedId,
    required this.onPick,
    super.key,
  });

  final List<PublierDemandeProduitOption> produits;
  final String? selectedId;
  final ValueChanged<PublierDemandeProduitOption> onPick;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.only(bottom: 8),
        children: [
          const SizedBox(height: 12),
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Choisir un produit',
              style: AppTextStyles.titleSmall.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 8),
          for (final p in produits)
            ListTile(
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CachedNetworkImage(
                  imageUrl: p.photoUrl,
                  width: 40,
                  height: 40,
                  fit: BoxFit.cover,
                  placeholder: (_, _) =>
                      Container(color: AppColors.surfaceSoft),
                  errorWidget: (_, _, _) =>
                      Container(color: AppColors.surfaceSoft),
                ),
              ),
              title: Text(
                p.nom,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              trailing: p.id == selectedId
                  ? const Icon(Icons.check, color: AppColors.primary)
                  : null,
              onTap: () => onPick(p),
            ),
        ],
      ),
    );
  }
}
