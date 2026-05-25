import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../models/enums.dart';
import '../../../../models/livraison.dart';
import '../../../../routing/route_names.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';
import '_constantes_accueil_transporteur.dart';
import 'bouton_primaire_mission.dart';
import 'bouton_secondaire_mission.dart';

/// Carte en avant qui résume la mission en cours (LOADING ou IN_TRANSIT)
/// du transporteur — statut + trajet + ETA + actions "Suivre" / "Marquer
/// livré".
///
/// Affichée tout en haut de l'accueil quand une mission est active. Le CTA
/// "Marquer livré" route vers le scanner pour confirmer la livraison.
class CarteMissionActive extends StatelessWidget {
  const CarteMissionActive({super.key, required this.mission});

  final Livraison mission;

  @override
  Widget build(BuildContext context) {
    final route = formatRouteMission(mission);
    final meta = formatMetaMission(mission);
    final eta = _formatEta(mission);

    return Container(
      padding: const EdgeInsets.all(AppDimens.space16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppDimens.brCard,
        border: Border.all(color: AppColors.primary, width: AppDimens.borderThin),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    AppDimens.hGap8,
                    Flexible(
                      child: Text(
                        _labelStatut(mission.status),
                        style: AppTextStyles.labelSmall.copyWith(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.4,
                          color: AppColors.primary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              if (eta != null)
                Text(
                  eta,
                  style: AppTextStyles.labelSmall.copyWith(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w400,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            route,
            style: AppTextStyles.titleMedium.copyWith(
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          if (meta != null) ...[
            const SizedBox(height: 4),
            Text(
              meta,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: BoutonSecondaireMission(
                  label: 'Suivre',
                  onTap: () => context.push(
                    RouteNames.transporteurMissionEnRoutePathFor(mission.id),
                  ),
                ),
              ),
              AppDimens.hGap8,
              Expanded(
                child: BoutonPrimaireMission(
                  label: 'Marquer livré',
                  onTap: () =>
                      context.push(RouteNames.transporteurScannerPath),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _labelStatut(ShipmentStatus s) {
    switch (s) {
      case ShipmentStatus.inTransit:
        return 'EN TRANSIT';
      case ShipmentStatus.loading:
        return 'CHARGEMENT';
      case ShipmentStatus.accepted:
        return 'ACCEPTÉE';
      case ShipmentStatus.requested:
        return 'EN ATTENTE';
      case ShipmentStatus.delivered:
        return 'LIVRÉE';
      case ShipmentStatus.cancelled:
        return 'ANNULÉE';
      case ShipmentStatus.unknown:
        return 'EN COURS';
    }
  }

  String? _formatEta(Livraison m) {
    final dt = m.scheduledAt;
    if (dt == null) return null;
    return 'Arrivée ${DateFormat('HH:mm', 'fr_FR').format(dt.toLocal())}';
  }
}
