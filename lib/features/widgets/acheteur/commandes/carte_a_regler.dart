// =====================================================================
//  Carte premium « À régler » — commande créée mais non payée
//  ---------------------------------------------------------------------
//  Affichée sur le détail commande acheteur UNIQUEMENT si :
//    - status == SENT (commande créée, jamais payée)
//    - payment_mode == FULL ou non défini (pour STAGED le dépôt est
//      géré ailleurs ; ici on cible le cas issu d'une négociation acceptée
//      où l'acheteur arrive sur la page sans avoir choisi son mode)
//
//  L'utilisateur tape « Choisir le mode de paiement » → navigation
//  vers la page paiement classique. Le prix négocié (déjà sur la
//  commande backend) sera bien appliqué.
// =====================================================================

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../models/commande.dart';
import '../../../../models/enums.dart';
import '../../../../routing/route_names.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';

class CarteARegler extends StatelessWidget {
  const CarteARegler({super.key, required this.commande});

  final Commande commande;

  @override
  Widget build(BuildContext context) {
    // Cache si déjà au-delà de SENT (paiement en cours / fait).
    if (commande.status != OrderStatus.sent) {
      return const SizedBox.shrink();
    }
    // STAGED avec dépôt déjà payé : autre carte gère l'étape solde.
    if (commande.paymentMode == 'STAGED' && commande.depositPaidAt != null) {
      return const SizedBox.shrink();
    }

    final nf = NumberFormat('#,##0', 'fr_FR');
    final total = commande.montantTotal.round();
    final annonceId = commande.annonceId;

    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Material(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: () => _allerPayer(context, annonceId),
          borderRadius: BorderRadius.circular(14),
          child: Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.primary, AppColors.primaryHover],
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.30),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.20),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.payments_rounded,
                        size: 19,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Commande à régler',
                            style: AppTextStyles.bodyMedium.copyWith(
                              fontFamily: 'Poppins',
                              fontSize: 13.5,
                              fontWeight: FontWeight.w700,
                              color: Colors.white.withValues(alpha: 0.92),
                            ),
                          ),
                          const SizedBox(height: 1),
                          Text(
                            '${nf.format(total)} F CFA',
                            style: AppTextStyles.titleLarge.copyWith(
                              fontFamily: 'Poppins',
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: -0.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.13),
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.handshake_outlined,
                        size: 14,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Prix négocié verrouillé · paye pour confirmer.',
                          style: AppTextStyles.bodySmall.copyWith(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: Colors.white.withValues(alpha: 0.92),
                            height: 1.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  height: AppDimens.buttonHeightSmall,
                  child: ElevatedButton(
                    onPressed: () => _allerPayer(context, annonceId),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.primary,
                      elevation: 0,
                      shape: const RoundedRectangleBorder(
                        borderRadius: AppDimens.brButton,
                      ),
                    ),
                    child: Text(
                      'Choisir le mode de paiement',
                      style: AppTextStyles.button.copyWith(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _allerPayer(BuildContext context, String? annonceId) {
    // La page paiement actuelle attend un annonceId. La commande issue
    // d'une négo a un annonceId — sinon (cas exception) on tape sur le
    // détail commande qui affiche au moins le contexte.
    if (annonceId != null && annonceId.isNotEmpty) {
      context.push(
        RouteNames.acheteurPaiementCommandePathFor(annonceId),
      );
    }
  }
}
