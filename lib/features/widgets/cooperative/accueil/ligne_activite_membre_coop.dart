import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../models/annonce_vente.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';
import 'avatar_initiales_coop.dart';

/// Ligne d'activité d'un membre : avatar + texte « Préfixe a publié
/// `<produit>` » avec sous-titre « qté kg · en attente de validation ».
/// Utilisé dans la section « Activité récente des membres » de l'accueil
/// coopérative.
class LigneActiviteMembreCoop extends StatelessWidget {
  const LigneActiviteMembreCoop({super.key, required this.annonce});

  final AnnonceVente annonce;

  @override
  Widget build(BuildContext context) {
    final qte = NumberFormat('#,##0', 'fr_FR').format(annonce.quantiteKg);
    final produit = annonce.titre.trim().isNotEmpty
        ? annonce.titre.trim()
        : 'un produit';
    final prefixe = _prefixeId(annonce.farmerId);

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.space16,
        vertical: AppDimens.space12,
      ),
      child: Row(
        children: [
          AvatarInitialesCoop(seed: annonce.farmerId),
          AppDimens.hGap12,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$prefixe a publié $produit',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$qte kg · en attente de validation',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodySmall.copyWith(
                    fontSize: 11,
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

/// Prefixe d'un id pour affichage utilisateur (ex: "user_abc123" → "Abc12").
String _prefixeId(String id) {
  final trimmed = id.trim();
  if (trimmed.isEmpty) return 'Un membre';
  // Si l'id contient un underscore, on prend ce qui suit le 1er underscore.
  final apres = trimmed.contains('_') ? trimmed.split('_').last : trimmed;
  if (apres.isEmpty) return 'Un membre';
  final court = apres.length > 5 ? apres.substring(0, 5) : apres;
  return court[0].toUpperCase() + court.substring(1);
}
