import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';
import 'section_prevision.dart';

/// Section "Comment ça marche ?" en 3 cartes numérotées : étape réservation,
/// récolte, livraison.
class SectionCommentCaMarchePrevision extends StatelessWidget {
  const SectionCommentCaMarchePrevision({super.key});

  @override
  Widget build(BuildContext context) {
    return const SectionPrevision(
      title: 'Comment ça marche ?',
      child: Row(
        children: [
          Expanded(
            child: _StepCardPrevision(
              num: '1',
              label: 'Réserve avec 10% d\'acompte',
            ),
          ),
          SizedBox(width: 8),
          Expanded(
            child: _StepCardPrevision(
              num: '2',
              label: 'Le producteur récolte',
            ),
          ),
          SizedBox(width: 8),
          Expanded(
            child: _StepCardPrevision(
              num: '3',
              label: 'Paie le solde à la livraison',
            ),
          ),
        ],
      ),
    );
  }
}

/// Carte d'étape numérotée — pastille verte + libellé centré en dessous.
class _StepCardPrevision extends StatelessWidget {
  const _StepCardPrevision({required this.num, required this.label});

  final String num;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceSoft,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.border,
          width: AppDimens.borderThin,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary,
            ),
            alignment: Alignment.center,
            child: Text(
              num,
              style: AppTextStyles.labelSmall.copyWith(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.onPrimary,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: AppTextStyles.labelSmall.copyWith(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.text,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}
