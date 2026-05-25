import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_text_styles.dart';

/// État vide affiché dans la page « Mes itinéraires » quand le
/// transporteur n'a déclaré aucune route. Encourage à en créer une
/// pour recevoir des missions.
class EtatVideItineraires extends StatelessWidget {
  const EtatVideItineraires({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        const SizedBox(height: 80),
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.alt_route_outlined,
                size: 40,
                color: AppColors.textSubtle.withValues(alpha: 0.9),
              ),
              const SizedBox(height: 12),
              Text(
                'Aucun itinéraire déclaré',
                style: AppTextStyles.titleSmall,
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  'Déclare au moins une route (origine → destination) pour recevoir des missions.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
