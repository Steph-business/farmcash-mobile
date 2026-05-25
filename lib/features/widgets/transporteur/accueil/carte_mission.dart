import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../models/livraison.dart';
import '../../../../routing/route_names.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';
import '_constantes_accueil_transporteur.dart';

/// Carte compacte d'une mission listée dans "Missions disponibles" ou
/// "Prochains chargements". Affiche le trajet, l'horaire, le prix et,
/// optionnellement, un bouton "Accepter" qui ouvre le détail.
class CarteMission extends StatelessWidget {
  const CarteMission({
    super.key,
    required this.mission,
    required this.avecBoutonAccepter,
  });

  final Livraison mission;
  final bool avecBoutonAccepter;

  @override
  Widget build(BuildContext context) {
    final route = formatRouteMission(mission);
    final meta = formatMetaMission(mission);
    final prix = formatPrixMission(mission.prixDevis);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppDimens.brCard,
        border:
            Border.all(color: AppColors.border, width: AppDimens.borderThin),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      route,
                      style: AppTextStyles.titleSmall.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (meta != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        meta,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              AppDimens.hGap8,
              Text(
                prix,
                style: AppTextStyles.titleLarge.copyWith(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
          if (avecBoutonAccepter) ...[
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: SizedBox(
                height: 34,
                child: ElevatedButton(
                  onPressed: () => context.push(
                    RouteNames.transporteurMissionDetailPathFor(mission.id),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.onPrimary,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    shape: const RoundedRectangleBorder(
                      borderRadius: AppDimens.brButton,
                    ),
                    textStyle: AppTextStyles.button.copyWith(
                      fontSize: 13,
                    ),
                  ),
                  child: const Text('Accepter'),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
