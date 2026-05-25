import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';
import 'prevision_detail_constants.dart';

/// Card vert pâle qui explique "10% d'acompte aujourd'hui, le reste à la
/// livraison" — message marketing clé de la page prévision.
class InfoAcompteCardPrevision extends StatelessWidget {
  const InfoAcompteCardPrevision({required this.acompte, super.key});

  final int acompte;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 14, 20, 0),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: kPrevisionDetailPrimarySoft,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.border,
          width: AppDimens.borderThin,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              color: AppColors.background,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.info_outline,
              size: 16,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: AppTextStyles.bodySmall.copyWith(
                  fontSize: 12,
                  height: 1.5,
                  color: AppColors.text,
                ),
                children: [
                  const TextSpan(text: 'Tu peux '),
                  TextSpan(
                    text: 'réserver dès maintenant',
                    style: AppTextStyles.bodySmall.copyWith(
                      fontSize: 12,
                      height: 1.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                  const TextSpan(text: '. Tu paies juste '),
                  TextSpan(
                    text:
                        '10% d\'acompte (${kPrevisionDetailNumFmt.format(acompte)} F)',
                    style: AppTextStyles.bodySmall.copyWith(
                      fontSize: 12,
                      height: 1.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                  const TextSpan(text: ', le reste à la livraison.'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
