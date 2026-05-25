import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';

/// Récapitulatif de la position GPS captée + ville détectée
/// avec un lien "Changer" pour réouvrir la sélection manuelle.
///
/// Affiche un indicateur de progression à la place du nom de ville
/// lorsque [isResolving] est vrai (reverse-geocoding en cours).
class RecapPosition extends StatelessWidget {
  const RecapPosition({
    required this.lat,
    required this.lng,
    required this.villeDetectee,
    required this.isResolving,
    required this.onChangerVille,
    super.key,
  });

  final double lat;
  final double lng;
  final String? villeDetectee;
  final bool isResolving;
  final VoidCallback onChangerVille;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceSoft,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.border,
          width: AppDimens.borderThin,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.location_on_outlined,
                  size: 18, color: AppColors.primary),
              const SizedBox(width: 8),
              Expanded(
                child: isResolving
                    ? Row(
                        children: [
                          Text(
                            'Détection de la ville…',
                            style: AppTextStyles.bodyMedium.copyWith(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      )
                    : Text(
                        villeDetectee ?? 'Ville inconnue',
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
              ),
              if (!isResolving)
                TextButton(
                  onPressed: onChangerVille,
                  style: TextButton.styleFrom(
                    minimumSize: const Size(0, 0),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    'Changer',
                    style: AppTextStyles.labelMedium.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'lat: ${lat.toStringAsFixed(5)} · lng: ${lng.toStringAsFixed(5)}',
            style: AppTextStyles.bodySmall.copyWith(
              fontSize: 11,
              color: AppColors.textSubtle,
            ),
          ),
        ],
      ),
    );
  }
}
