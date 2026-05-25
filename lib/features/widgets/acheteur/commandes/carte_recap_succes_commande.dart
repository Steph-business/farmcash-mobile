import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../models/commande.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';

final NumberFormat _nf = NumberFormat('#,##0', 'fr_FR');

/// Carte récapitulative affichée après une commande réussie.
class CarteRecapSuccesCommande extends StatelessWidget {
  const CarteRecapSuccesCommande({required this.commande, super.key});
  final Commande commande;

  @override
  Widget build(BuildContext context) {
    final df = DateFormat('d MMM y', 'fr_FR');
    final reference =
        commande.reference.isNotEmpty ? commande.reference : commande.id;
    final livraisonStr = commande.livraisonDate != null
        ? df.format(commande.livraisonDate!)
        : 'À planifier';
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: AppColors.border, width: AppDimens.borderThin),
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        children: [
          _LigneRecap(label: 'N° commande', value: '#$reference'),
          _LigneRecap(
            label: 'Quantité',
            value: '${_nf.format(commande.quantiteKg.round())} kg',
          ),
          _LigneRecap(
            label: 'Montant',
            value: '${_nf.format(commande.montantTotal.round())} F',
            valueGreen: true,
          ),
          _LigneRecap(
            label: 'Livraison estimée',
            value: livraisonStr,
            isLast: true,
          ),
        ],
      ),
    );
  }
}

class _LigneRecap extends StatelessWidget {
  const _LigneRecap({
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
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
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
              style: AppTextStyles.bodySmall.copyWith(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: valueGreen
                  ? AppTextStyles.bodyMedium.copyWith(
                      fontFamily: 'Poppins',
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
