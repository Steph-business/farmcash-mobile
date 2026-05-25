import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';
import 'sticky_envoi_evaluation_commande.dart';

/// Formulaire de saisie de l'evaluation transporteur :
/// note 1-5 etoiles + commentaire optionnel + bouton sticky de soumission.
class FormulaireEvaluationCommande extends StatelessWidget {
  const FormulaireEvaluationCommande({
    super.key,
    required this.note,
    required this.busy,
    required this.commentCtrl,
    required this.onNoteChanged,
    required this.onSubmit,
  });

  final int note;
  final bool busy;
  final TextEditingController commentCtrl;
  final ValueChanged<int> onNoteChanged;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              AppDimens.pagePaddingH,
              12,
              AppDimens.pagePaddingH,
              24,
            ),
            children: [
              Text(
                'Comment s\'est passé le transport ?',
                style: AppTextStyles.titleLarge.copyWith(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Votre avis aide les autres acheteurs à choisir.',
                style: AppTextStyles.bodySmall.copyWith(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              AppDimens.vGap24,
              Text(
                'Votre note',
                style: AppTextStyles.labelMedium.copyWith(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (int i = 1; i <= 5; i++)
                    InkWell(
                      onTap: busy ? null : () => onNoteChanged(i),
                      borderRadius: BorderRadius.circular(24),
                      child: Padding(
                        padding: const EdgeInsets.all(6),
                        child: Icon(
                          i <= note ? Icons.star : Icons.star_border,
                          size: 40,
                          color: i <= note
                              ? AppColors.primary
                              : AppColors.textSubtle,
                        ),
                      ),
                    ),
                ],
              ),
              AppDimens.vGap24,
              Text(
                'Commentaire (optionnel)',
                style: AppTextStyles.labelMedium.copyWith(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.border,
                    width: AppDimens.borderThin,
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: TextField(
                  controller: commentCtrl,
                  maxLines: 4,
                  enabled: !busy,
                  decoration: InputDecoration(
                    hintText: 'Délais, état des marchandises, communication…',
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    hintStyle: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSubtle,
                      fontSize: 13,
                    ),
                  ),
                  style: AppTextStyles.bodyMedium.copyWith(fontSize: 14),
                ),
              ),
            ],
          ),
        ),
        StickyEnvoiEvaluationCommande(
          busy: busy,
          onTap: onSubmit,
        ),
      ],
    );
  }
}
