import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';

const Color _kPrimarySoft = Color(0xFFE8F5E9);

/// Bandeau primary-soft affichant le nombre de demandes actives et le
/// total de propositions reçues, en haut de la page « Mes demandes ».
class CompteurMesDemandes extends StatelessWidget {
  const CompteurMesDemandes({
    required this.actives,
    required this.totalPropositions,
    super.key,
  });

  /// Nombre de demandes actives.
  final int actives;

  /// Total de propositions reçues sur l'ensemble des demandes.
  final int totalPropositions;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 14),
      child: Container(
        decoration: BoxDecoration(
          color: _kPrimarySoft,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.border,
            width: AppDimens.borderThin,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: RichText(
          text: TextSpan(
            style: AppTextStyles.bodySmall.copyWith(
              fontSize: 12,
              color: AppColors.text,
              fontWeight: FontWeight.w500,
            ),
            children: [
              TextSpan(
                text: '$actives demandes actives',
                style: AppTextStyles.bodySmall.copyWith(
                  fontSize: 12,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const TextSpan(text: ' · '),
              TextSpan(text: '$totalPropositions propositions reçues'),
            ],
          ),
        ),
      ),
    );
  }
}
