import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../models/commande.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';

final NumberFormat _nf = NumberFormat('#,##0', 'fr_FR');

/// Carte récapitulative après une commande réussie — version « hero
/// montant ». Le montant payé est mis en valeur (grand, vert), puis les
/// 2 infos compactes (quantité + livraison) sur une seule ligne en bas.
///
/// On n'affiche **plus le N° de commande** dans cette carte : il
/// encombrait pour rien (l'utilisateur ne le lit jamais ici). Il est
/// repris en footer discret via [PiedReferenceCommandeSucces].
class CarteRecapSuccesCommande extends StatelessWidget {
  const CarteRecapSuccesCommande({required this.commande, super.key});
  final Commande commande;

  @override
  Widget build(BuildContext context) {
    final df = DateFormat('d MMM y', 'fr_FR');
    final livraisonStr = commande.livraisonDate != null
        ? df.format(commande.livraisonDate!)
        : 'À planifier';
    final qte = '${_nf.format(commande.quantiteKg.round())} kg';

    // En mode STAGED, on affiche le montant DU DÉPÔT (ce qui vient
    // d'être payé), pas le total — sinon l'acheteur croit avoir tout
    // payé alors qu'il reste le solde à la livraison.
    final estStaged = commande.paymentMode == 'STAGED' &&
        commande.depositAmount != null;
    final montantPaye = estStaged
        ? commande.depositAmount!.round()
        : commande.montantTotal.round();
    final montant = '${_nf.format(montantPaye)} F';
    final solde = estStaged
        ? (commande.montantTotal - commande.depositAmount!).round()
        : 0;

    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.22),
          width: AppDimens.borderThin,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Label discret — distingue clairement acompte vs paiement intégral
          Text(
            estStaged ? 'ACOMPTE PAYÉ' : 'MONTANT PAYÉ',
            style: AppTextStyles.bodySmall.copyWith(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 6),
          // Montant en grand — l'info la plus importante après le
          // checkmark. Poppins gras vert primary.
          Text(
            montant,
            style: AppTextStyles.headlineLarge.copyWith(
              fontFamily: 'Poppins',
              fontSize: 30,
              fontWeight: FontWeight.w800,
              color: AppColors.primary,
              height: 1.1,
            ),
          ),
          if (estStaged) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF3C7),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFFCD34D)),
              ),
              child: Text(
                'Solde ${_nf.format(solde)} F à régler à la livraison',
                style: AppTextStyles.bodySmall.copyWith(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF92400E),
                ),
              ),
            ),
          ],
          const SizedBox(height: 12),
          // Séparateur fin de la même teinte primary atténuée — relie
          // le montant aux 2 chips d'info ci-dessous.
          Container(
            height: 1,
            color: AppColors.primary.withValues(alpha: 0.15),
          ),
          const SizedBox(height: 12),
          // Quantité + Livraison en 2 mini-blocs côte à côte. Plus de
          // table verticale 4 lignes : plus compact, plus moderne.
          Row(
            children: [
              Expanded(
                child: _InfoMini(
                  icone: Icons.inventory_2_outlined,
                  label: 'Quantité',
                  valeur: qte,
                ),
              ),
              Container(
                width: 1,
                height: 28,
                color: AppColors.primary.withValues(alpha: 0.15),
              ),
              Expanded(
                child: _InfoMini(
                  icone: Icons.local_shipping_outlined,
                  label: 'Livraison',
                  valeur: livraisonStr,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Mini-bloc icône + label gris + valeur — utilisé pour quantité &
/// livraison sous le montant hero.
class _InfoMini extends StatelessWidget {
  const _InfoMini({
    required this.icone,
    required this.label,
    required this.valeur,
  });
  final IconData icone;
  final String label;
  final String valeur;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icone, size: 18, color: AppColors.primary),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            fontSize: 11,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          valeur,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.bodyMedium.copyWith(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AppColors.text,
          ),
        ),
      ],
    );
  }
}
