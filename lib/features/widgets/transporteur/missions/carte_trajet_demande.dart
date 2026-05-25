import 'package:flutter/material.dart';

import '../../../../models/livraison.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';

const BorderRadius _kBrCard = BorderRadius.all(Radius.circular(12));

/// Carte « Trajet » d'une demande entrante : affiche l'origine et la
/// destination de la livraison avec leurs adresses complètes, séparées
/// par un trait vertical reliant les deux points.
class CarteTrajetDemande extends StatelessWidget {
  const CarteTrajetDemande({required this.mission, super.key});

  final Livraison mission;

  @override
  Widget build(BuildContext context) {
    final origine = mission.origineZone ?? '—';
    final dest = mission.destinationZone ?? '—';
    final pickup = mission.pickupAddress;
    final delivery = mission.deliveryAddress;
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
          _line(
            icon: Icons.trip_origin,
            color: AppColors.primary,
            titre: origine,
            sous: pickup,
          ),
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
          _line(
            icon: Icons.place,
            color: AppColors.error,
            titre: dest,
            sous: delivery,
          ),
        ],
      ),
    );
  }

  Widget _line({
    required IconData icon,
    required Color color,
    required String titre,
    String? sous,
  }) {
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
