import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';

const Color _kPrimarySoft = Color(0xFFE8F5E9);

/// Bandeau d'information expliquant le rôle « farmer géré » (sans
/// téléphone) en haut du formulaire d'enregistrement.
class CarteInfoManaged extends StatelessWidget {
  const CarteInfoManaged({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _kPrimarySoft,
        borderRadius: AppDimens.brCard,
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline,
            size: 18,
            color: AppColors.primary,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              "Ce membre n'aura pas de compte connectable. La coop "
              "publiera ses annonces en son nom. Tu pourras le "
              "promouvoir plus tard dès qu'il aura un téléphone.",
              style: AppTextStyles.bodySmall.copyWith(
                fontSize: 12,
                color: AppColors.text,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
