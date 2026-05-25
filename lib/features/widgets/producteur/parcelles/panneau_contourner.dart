import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';

/// Panel "marcher autour" : explication, bouton démarrer/arrêter,
/// compteur de points GPS captés et aire calculée (en hectares).
///
/// L'aire est calculée par le parent (algorithme du polygone à partir
/// de [points]) et passée via [aireHa].
class PanneauContourner extends StatelessWidget {
  const PanneauContourner({
    required this.walking,
    required this.points,
    required this.aireHa,
    required this.onToggle,
    super.key,
  });

  final bool walking;
  final List<Position> points;
  final double? aireHa;
  final VoidCallback onToggle;

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
          Text(
            walking
                ? 'Marche autour de ta parcelle. Chaque pas est enregistré.'
                : 'Pars du coin de ta parcelle et fais le tour à pied. '
                    'L\'app calcule la superficie automatiquement.',
            style: AppTextStyles.bodyMedium.copyWith(
              fontSize: 13,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.border,
                    width: AppDimens.borderThin,
                  ),
                ),
                child: Text(
                  '${points.length} points',
                  style: AppTextStyles.bodySmall.copyWith(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.text,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              if (aireHa != null)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.primary,
                      width: AppDimens.borderThin,
                    ),
                  ),
                  child: Text(
                    '${aireHa!.toStringAsFixed(2)} ha',
                    style: AppTextStyles.bodySmall.copyWith(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onToggle,
              icon: Icon(walking ? Icons.stop_circle : Icons.play_arrow),
              label: Text(
                walking ? 'Terminer la marche' : 'Démarrer la marche',
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: walking ? AppColors.error : AppColors.primary,
                side: BorderSide(
                  color: walking ? AppColors.error : AppColors.primary,
                  width: 1.5,
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
