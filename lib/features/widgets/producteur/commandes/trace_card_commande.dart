import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';
import 'commande_terminee_constants.dart';

/// Carte informative verte sur la page « Commande livrée » producteur :
/// rassure le farmer (et son acheteur en aval) que la traçabilité est
/// signée et auditable par scan du QR.
class TraceCardCommande extends StatelessWidget {
  const TraceCardCommande({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: kCommandeTermineePrimarySoft,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.border,
          width: AppDimens.borderThin,
        ),
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.shield_outlined,
              size: 14,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: AppTextStyles.bodyMedium.copyWith(
                  fontSize: 12,
                  color: AppColors.text,
                  height: 1.5,
                ),
                children: [
                  TextSpan(
                    text: 'Traçabilité signée. ',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const TextSpan(
                    text:
                        'Tout acheteur, revendeur ou contrôleur peut scanner '
                        'ce QR pour vérifier l\'origine du produit, sa '
                        'qualité, la date de récolte et les traitements '
                        'appliqués.',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
