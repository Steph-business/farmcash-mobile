import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../models/commande.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';

/// Bandeau qui matérialise l'état du paiement étagé côté VENDEUR
/// (producteur ou coopérative). Visible uniquement quand la commande
/// est en mode STAGED. Cache silencieuse en mode FULL.
///
/// 3 états distincts (selon dépôt / solde) :
///
///   1) Dépôt non payé           → en attente — pas de bandeau visible
///   2) Dépôt payé / solde en
///      attente livraison         → carte ambrée « Avance reçue · Solde
///                                   attendu à la livraison »
///   3) Tout payé / non libéré    → carte verte « Tout réglé · libération
///                                   à la confirmation de réception »
///
/// Aide la coop à comprendre que l'avance reçue (80 % du dépôt) est
/// déjà créditée sur son wallet et qu'elle peut payer ses producteurs
/// sans attendre la livraison.
class CartePaiementEtageVendeur extends StatelessWidget {
  const CartePaiementEtageVendeur({super.key, required this.commande});

  final Commande commande;

  @override
  Widget build(BuildContext context) {
    final c = commande;
    if (c.paymentMode != 'STAGED') return const SizedBox.shrink();
    if (c.depositPaidAt == null) return const SizedBox.shrink();

    final deposit = c.depositAmount ?? 0;
    final solde = c.montantTotal - deposit;
    final immediat = (deposit * 0.80).roundToDouble();
    final garantie = deposit - immediat;
    final soldePaye = c.balancePaidAt != null;
    final nf = NumberFormat('#,##0', 'fr_FR');

    final color = soldePaye ? AppColors.primary : const Color(0xFFD97706);
    final colorLight = color.withValues(alpha: 0.08);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: colorLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.30)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: Icon(
                  soldePaye
                      ? Icons.verified_rounded
                      : Icons.schedule_rounded,
                  size: 16,
                  color: color,
                ),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Text(
                  soldePaye
                      ? 'Tout réglé · libération à la livraison'
                      : 'Paiement étagé · avance reçue',
                  style: AppTextStyles.titleSmall.copyWith(
                    fontFamily: 'Poppins',
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                    color: AppColors.text,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _ligne(
            label: 'Avance versée par l\'acheteur',
            valeur: '${nf.format(deposit.round())} F',
          ),
          _ligne(
            label: '└ Crédit immédiat sur ton wallet (80 %)',
            valeur: '${nf.format(immediat.round())} F',
            valeurBold: true,
            valeurColor: AppColors.primary,
          ),
          _ligne(
            label: '└ Bloqué en garantie (20 %)',
            valeur: '${nf.format(garantie.round())} F',
            valeurColor: AppColors.textSubtle,
          ),
          const SizedBox(height: 6),
          const Divider(height: 1),
          const SizedBox(height: 6),
          _ligne(
            label: soldePaye
                ? 'Solde déjà payé par l\'acheteur'
                : 'Solde attendu à la livraison',
            valeur: '${nf.format(solde.round())} F',
            valeurBold: true,
            valeurColor: soldePaye ? AppColors.primary : const Color(0xFFD97706),
          ),
          if (!soldePaye) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: color.withValues(alpha: 0.25)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.lightbulb_outline_rounded,
                    size: 14,
                    color: color,
                  ),
                  const SizedBox(width: 7),
                  Expanded(
                    child: Text(
                      'Tu peux déjà payer tes producteurs avec '
                      "l'avance reçue — sans attendre la livraison.",
                      style: AppTextStyles.bodySmall.copyWith(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w500,
                        color: AppColors.text,
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _ligne({
    required String label,
    required String valeur,
    bool valeurBold = false,
    Color? valeurColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(
                fontSize: 12,
                color: AppColors.textSecondary,
                height: 1.3,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            valeur,
            style: AppTextStyles.bodySmall.copyWith(
              fontFamily: 'Poppins',
              fontSize: 12.5,
              fontWeight: valeurBold ? FontWeight.w800 : FontWeight.w600,
              color: valeurColor ?? AppColors.text,
              letterSpacing: -0.1,
            ),
          ),
        ],
      ),
    );
  }
}
