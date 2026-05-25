import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';
import '_constantes_accueil_coop.dart';

/// Avatar circulaire affichant 2 initiales générées depuis un identifiant
/// (id farmer / buyer). Utilisé dans les listes de l'accueil coopérative
/// (acheteurs, activité membres, etc.).
class AvatarInitialesCoop extends StatelessWidget {
  const AvatarInitialesCoop({super.key, required this.seed});

  final String seed;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: kPrimarySoftCoop,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.border, width: AppDimens.borderThin),
      ),
      alignment: Alignment.center,
      child: Text(
        initialesAccueilCoop(seed),
        style: AppTextStyles.labelSmall.copyWith(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: AppColors.primary,
        ),
      ),
    );
  }
}
