import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_text_styles.dart';
import 'mission_tab.dart';

/// État vide de la liste des missions transporteur, avec message
/// contextualisé en fonction de l'onglet actif (En cours / Disponibles /
/// Terminées).
class EtatVideMissions extends StatelessWidget {
  const EtatVideMissions({super.key, required this.tab});

  final MissionTab tab;

  @override
  Widget build(BuildContext context) {
    final msg = switch (tab) {
      MissionTab.enCours =>
        'Aucune mission en cours. Accepte une mission depuis « Disponibles ».',
      MissionTab.disponibles =>
        'Aucune mission disponible dans tes zones. Vérifie tes itinéraires.',
      MissionTab.terminees => 'Tu n\'as pas encore livré de mission.',
    };
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 32,
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.local_shipping_outlined,
              size: 40,
              color: AppColors.textSubtle.withValues(alpha: 0.9),
            ),
            const SizedBox(height: 12),
            Text(
              msg,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
