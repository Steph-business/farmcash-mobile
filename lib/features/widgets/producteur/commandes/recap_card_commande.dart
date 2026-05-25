import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';
import 'commande_terminee_constants.dart';

/// Carte récapitulative en bas de la page « Commande livrée » : photo
/// héro + 6 lignes label/valeur (produit, parcelle, récolte, transporteur,
/// acheteur, montant crédité en vert).
///
/// Les valeurs sont aujourd'hui figées sur la maquette — quand le backend
/// renverra les détails enrichis de la commande, on passera la `Commande`
/// en paramètre et on dérivera ces lignes dynamiquement.
class RecapCardCommande extends StatelessWidget {
  const RecapCardCommande({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.border,
          width: AppDimens.borderThin,
        ),
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        children: [
          // Hero photo
          SizedBox(
            height: 110,
            width: double.infinity,
            child: CachedNetworkImage(
              imageUrl: kCommandeTermineeHeroPhoto,
              fit: BoxFit.cover,
              placeholder: (_, _) => Container(color: AppColors.surfaceSoft),
              errorWidget: (_, _, _) =>
                  Container(color: AppColors.surfaceSoft),
            ),
          ),
          const Divider(
            height: 1,
            thickness: AppDimens.borderThin,
            color: AppColors.border,
          ),
          const _RecapRow(
            label: 'Produit',
            value: 'Maïs grain blanc · 500 kg',
          ),
          const _RecapRow(
            label: 'Parcelle d\'origine',
            value: 'Champ derrière la maison · Yopougon',
          ),
          const _RecapRow(label: 'Récolté le', value: '8 mai 2026'),
          const _RecapRow(label: 'Transporteur', value: 'Camion Vert SARL'),
          const _RecapRow(label: 'Acheteur', value: 'Restaurant Le B.'),
          const _RecapRow(
            label: 'Montant crédité',
            value: '+ 169 750 F',
            valueGreen: true,
            isLast: true,
          ),
        ],
      ),
    );
  }
}

class _RecapRow extends StatelessWidget {
  const _RecapRow({
    required this.label,
    required this.value,
    this.valueGreen = false,
    this.isLast = false,
  });

  final String label;
  final String value;
  final bool valueGreen;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: isLast ? Colors.transparent : AppColors.border,
            width: AppDimens.borderThin,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.bodyMedium.copyWith(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: valueGreen
                  ? AppTextStyles.displayLarge.copyWith(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    )
                  : AppTextStyles.bodyMedium.copyWith(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.text,
                    ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
