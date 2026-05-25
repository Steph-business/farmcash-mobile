import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';

const Color _kPrimarySoft = Color(0xFFE8F5E9);
const Color _kBgSoftIcon = Color(0xFFF3F4F6);

/// Représentation visuelle d'une transaction (déjà formatée). On garde un
/// modèle simple pour cette tuile — la conversion `Transaction → ItemTx`
/// est faite côté page.
class ItemTransaction {
  const ItemTransaction({
    required this.icon,
    required this.entree,
    required this.titre,
    required this.sousTitre,
    required this.montant,
  });

  /// Icône affichée dans la bulle (généralement flèche bas / haut).
  final IconData icon;

  /// `true` si la transaction est entrante (vert), `false` si sortante.
  final bool entree;

  /// Titre principal (ex : « Vente Manioc 1 t »).
  final String titre;

  /// Sous-titre (ex : « 14/05 · Orange Money »).
  final String sousTitre;

  /// Montant déjà formaté (avec préfixe « + » ou « - » et la devise).
  final String montant;
}

/// Ligne de transaction — bulle icône colorée + titre/sous-titre + montant.
///
/// Utilisée par toutes les listes wallet (producteur / acheteur /
/// transporteur / coopérative).
class TuileTransaction extends StatelessWidget {
  const TuileTransaction({
    super.key,
    required this.item,
    required this.dernier,
  });

  final ItemTransaction item;

  /// Si `true`, masque la bordure inférieure (dernière ligne d'un container).
  final bool dernier;

  @override
  Widget build(BuildContext context) {
    final bubbleBg = item.entree ? _kPrimarySoft : _kBgSoftIcon;
    final bubbleFg = item.entree ? AppColors.primary : AppColors.textSecondary;
    final amountColor = item.entree ? AppColors.primary : AppColors.text;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: dernier ? Colors.transparent : AppColors.border,
            width: AppDimens.borderThin,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(color: bubbleBg, shape: BoxShape.circle),
            alignment: Alignment.center,
            child: Icon(item.icon, size: 18, color: bubbleFg),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  item.titre,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  item.sousTitre,
                  style: AppTextStyles.bodySmall.copyWith(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Text(
            item.montant,
            style: AppTextStyles.titleSmall.copyWith(
              fontFamily: AppTextStyles.displayLarge.fontFamily,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: amountColor,
            ),
          ),
        ],
      ),
    );
  }
}
