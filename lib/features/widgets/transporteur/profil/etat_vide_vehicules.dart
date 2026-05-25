import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';

/// État vide de la page « Mes véhicules » : icône camion grisé et
/// message d'invitation à ajouter un premier véhicule pour recevoir
/// des missions.
class EtatVideVehicules extends StatelessWidget {
  const EtatVideVehicules({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          0, AppDimens.space24, 0, AppDimens.space16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.local_shipping_outlined,
            size: 40,
            color: AppColors.textSubtle.withValues(alpha: 0.9),
          ),
          const SizedBox(height: AppDimens.space12),
          Text(
            'Aucun véhicule enregistré',
            style: AppTextStyles.titleSmall,
          ),
          const SizedBox(height: 4),
          Text(
            'Ajoute ton premier véhicule pour recevoir des missions.',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
