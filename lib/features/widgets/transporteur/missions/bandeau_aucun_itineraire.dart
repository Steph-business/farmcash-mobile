import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../routing/route_names.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';

/// Bandeau qui s'affiche sur la page Missions quand le transporteur n'a
/// AUCUN itinéraire actif. Sans itinéraire, il ne reçoit aucune mission
/// — le backend ne lui en envoie pas. Plutôt qu'une liste vide cryptique,
/// on lui dit explicitement ce qu'il doit faire et on le pousse vers la
/// page d'ajout.
class BandeauAucunItineraire extends StatelessWidget {
  const BandeauAucunItineraire({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF3C7),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFCD34D)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: const Color(0xFF92400E).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.route_rounded,
              size: 21,
              color: Color(0xFF92400E),
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Ajoute un itinéraire pour recevoir des missions',
                  style: AppTextStyles.titleSmall.copyWith(
                    fontFamily: 'Poppins',
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                    color: AppColors.text,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Sans itinéraire actif (origine → destination), '
                  'FarmCash ne t\'envoie aucune mission. '
                  'Configure au moins un trajet que tu desserts.',
                  style: AppTextStyles.bodySmall.copyWith(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 38,
                  child: ElevatedButton.icon(
                    onPressed: () => context.push(
                      RouteNames.transporteurVehiculeAjouterPath,
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF92400E),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: const RoundedRectangleBorder(
                        borderRadius: AppDimens.brButton,
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                      ),
                    ),
                    icon: const Icon(Icons.add_road_rounded, size: 17),
                    label: Text(
                      'Ajouter un itinéraire',
                      style: AppTextStyles.button.copyWith(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
