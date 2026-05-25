import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_text_styles.dart';

/// Hero centre : pastille verte avec check + montant distribue + libelle
/// "N contributeurs ont ete credites".
class HeroDistributionEffectuee extends StatelessWidget {
  const HeroDistributionEffectuee({
    required this.montantLabel,
    required this.contributeursLabel,
    super.key,
  });

  /// Texte du montant principal (ex: "175 000 F distribués").
  final String montantLabel;

  /// Texte du sous-titre (ex: "4 contributeurs ont été crédités").
  final String contributeursLabel;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 14, bottom: 20),
      child: Column(
        children: [
          Container(
            width: 88,
            height: 88,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.check,
              size: 40,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            montantLabel,
            style: AppTextStyles.headlineLarge.copyWith(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.3,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            contributeursLabel,
            style: AppTextStyles.bodySmall.copyWith(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
