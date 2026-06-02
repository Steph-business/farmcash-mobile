import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';
import 'annonce_detail_constants.dart';
import 'step_btn_annonce.dart';

/// Barre sticky bas de la page détail annonce acheteur : sélecteur de
/// quantité (− / qte / +), montant total calculé, bouton outline "Ajouter
/// au panier" et bouton plein "Commander". Les bornes min/max désactivent
/// les flèches en bout de course.
class StickyBottomAnnonce extends StatelessWidget {
  const StickyBottomAnnonce({
    required this.qte,
    required this.montant,
    required this.maxQte,
    required this.minQte,
    required this.busy,
    required this.onMinus,
    required this.onPlus,
    required this.onAjouterPanier,
    this.onNegocier,
    super.key,
  });

  final int qte;
  final int montant;
  final int maxQte;
  final int minQte;
  final bool busy;
  final VoidCallback onMinus;
  final VoidCallback onPlus;
  final VoidCallback onAjouterPanier;

  /// Tap sur le lien « Négocier le prix » au-dessus du CTA. Null →
  /// le lien est caché (cas d'annonces non-négociables, à venir).
  final VoidCallback? onNegocier;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(
          top: BorderSide(
            color: AppColors.border,
            width: AppDimens.borderThin,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Text(
                  'Quantité : ',
                  style: AppTextStyles.bodySmall.copyWith(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: AppColors.border,
                      width: AppDimens.borderThin,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Row(
                    children: [
                      StepBtnAnnonce(
                        label: '−',
                        onTap: qte > minQte ? onMinus : null,
                      ),
                      Container(
                        width: 60,
                        alignment: Alignment.center,
                        child: Text(
                          '$qte kg',
                          style: AppTextStyles.titleSmall.copyWith(
                            fontFamily: 'Poppins',
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      StepBtnAnnonce(
                        label: '+',
                        onTap: qte < maxQte ? onPlus : null,
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Text(
                  '${kAnnonceDetailNumFmt.format(montant)} F',
                  style: AppTextStyles.titleSmall.copyWith(
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            // 2 CTAs côte à côte : « Négocier » (outline, gauche) +
            // « Ajouter au panier » (plein, droite). Si l'annonce
            // n'est pas négociable (onNegocier null), seul l'ajout
            // panier reste, plein largeur.
            Row(
              children: [
                if (onNegocier != null) ...[
                  Expanded(
                    child: InkWell(
                      onTap: busy ? null : onNegocier,
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        height: 46,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: AppColors.primary,
                            width: AppDimens.borderThin,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.handshake_outlined,
                              size: 18,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Négocier',
                              style: AppTextStyles.button.copyWith(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                ],
                Expanded(
                  child: InkWell(
                    onTap: busy ? null : onAjouterPanier,
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      height: 46,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: busy
                            ? AppColors.primary.withValues(alpha: 0.6)
                            : AppColors.primary,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: busy
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.shopping_cart_outlined,
                                  size: 18,
                                  color: AppColors.onPrimary,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Ajouter au panier',
                                  style: AppTextStyles.button.copyWith(
                                    fontSize: 13,
                                    color: AppColors.onPrimary,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
