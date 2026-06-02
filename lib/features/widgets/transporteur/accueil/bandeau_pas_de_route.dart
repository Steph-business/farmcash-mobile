import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../routing/route_names.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';

/// Bandeau d'alerte affiché en haut de l'accueil transporteur quand
/// l'utilisateur n'a **aucune route active** déclarée.
///
/// Pourquoi : côté backend, les nouvelles missions sont push-notifiées
/// **uniquement** aux transporteurs dont une `transporter_routes` matche
/// la zone+capacité du shipment. Un transporteur sans route ne reçoit
/// donc rien (catch-22 — il ne sait jamais qu'on cherche des courses).
///
/// Solution UX (V1) : bandeau jaune insistant + CTA direct vers la page
/// Tarification où il déclare sa 1ère route. Tant qu'il ne l'a pas
/// fait, l'app n'est pas utilisable pour lui — autant le dire clair.
class BandeauPasDeRoute extends StatelessWidget {
  const BandeauPasDeRoute({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFB45309),
          width: AppDimens.borderThin,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                size: 20,
                color: Color(0xFFB45309),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Aucun itinéraire déclaré',
                  style: AppTextStyles.titleSmall.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFFB45309),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Tu ne recevras pas de missions tant que tu n\'as pas déclaré '
            'au moins un itinéraire (zone + capacité + tarif). C\'est ce '
            'qui permet aux acheteurs de te trouver.',
            style: AppTextStyles.bodySmall.copyWith(
              fontSize: 12.5,
              color: AppColors.text,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () =>
                  context.push(RouteNames.transporteurItinerairesPath),
              icon: const Icon(Icons.add_road, size: 18),
              label: const Text('Déclarer mon 1er itinéraire'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFB45309),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                textStyle: AppTextStyles.button.copyWith(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
