import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';

/// Bouton outlined "Voir tous les membres" en bas de la page coop.
class BoutonMembresCoop extends StatelessWidget {
  const BoutonMembresCoop({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppDimens.buttonHeight,
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: const Icon(
          Icons.groups_outlined,
          size: 18,
          color: AppColors.primary,
        ),
        label: Text(
          'Voir tous les membres',
          style: AppTextStyles.button.copyWith(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
          ),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(
            color: AppColors.primary,
            width: AppDimens.borderThin,
          ),
          shape: const RoundedRectangleBorder(
            borderRadius: AppDimens.brButton,
          ),
        ),
      ),
    );
  }
}
