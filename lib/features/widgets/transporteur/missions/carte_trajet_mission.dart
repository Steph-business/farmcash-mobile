import 'package:flutter/material.dart';

import '../../../../models/livraison.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';

const BorderRadius _kBrCard = BorderRadius.all(Radius.circular(12));

/// Carte « Trajet » du détail mission : affiche les points d'origine et
/// destination (zone + adresse) avec une barre verticale entre les deux.
class CarteTrajetMission extends StatelessWidget {
  const CarteTrajetMission({required this.mission, super.key});
  final Livraison mission;

  @override
  Widget build(BuildContext context) {
    final origine = mission.origineZone ?? '—';
    final dest = mission.destinationZone ?? '—';
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: _kBrCard,
        border: Border.all(
          color: AppColors.border,
          width: AppDimens.borderThin,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _row(Icons.trip_origin, AppColors.primary, origine,
              mission.pickupAddress),
          const SizedBox(height: 10),
          const Padding(
            padding: EdgeInsets.only(left: 7),
            child: SizedBox(
              width: 2,
              height: 18,
              child: ColoredBox(color: AppColors.border),
            ),
          ),
          const SizedBox(height: 10),
          _row(Icons.place, AppColors.error, dest, mission.deliveryAddress),
        ],
      ),
    );
  }

  Widget _row(IconData icon, Color color, String titre, String? sous) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                titre,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (sous != null && sous.trim().isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  sous,
                  style: AppTextStyles.bodySmall.copyWith(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
