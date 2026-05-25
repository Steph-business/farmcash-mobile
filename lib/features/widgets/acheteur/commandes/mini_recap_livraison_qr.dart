import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../models/annonce_vente.dart';
import '../../../../models/commande.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';

final NumberFormat _nf = NumberFormat('#,##0', 'fr_FR');

/// Mini récap de la commande (produit, montant, livraison) sous le QR.
class MiniRecapLivraisonQr extends StatelessWidget {
  const MiniRecapLivraisonQr({
    required this.commande,
    required this.annonce,
    super.key,
  });
  final Commande commande;
  final AnnonceVente? annonce;

  @override
  Widget build(BuildContext context) {
    final nom = annonce?.produitLabel ?? 'Commande';
    final qte = _nf.format(commande.quantiteKg.round());
    final montant = _nf.format(commande.montantTotal.round());
    final df = DateFormat('d MMM', 'fr_FR');
    final livraison = commande.livraisonDate != null
        ? df.format(commande.livraisonDate!)
        : '—';
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceSoft,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.border,
          width: AppDimens.borderThin,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ligne('Produit', '$qte kg $nom'),
          const SizedBox(height: 6),
          _ligne('Montant', '$montant F'),
          const SizedBox(height: 6),
          _ligne('Livraison prévue', livraison),
        ],
      ),
    );
  }

  Widget _ligne(String label, String value) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Text(
          value,
          style: AppTextStyles.bodyMedium.copyWith(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.text,
          ),
        ),
      ],
    );
  }
}
