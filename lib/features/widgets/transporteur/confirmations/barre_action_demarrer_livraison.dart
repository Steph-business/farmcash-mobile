import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../routing/route_names.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';

/// Barre d'action collée en bas de la page d'enlèvement confirmé :
/// CTA "Démarrer la livraison" qui pousse vers la page mission en route.
/// Le bouton est désactivé si [missionId] est vide.
class BarreActionDemarrerLivraison extends StatelessWidget {
  const BarreActionDemarrerLivraison({required this.missionId, super.key});

  final String missionId;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(
          top: BorderSide(
              color: AppColors.border, width: AppDimens.borderThin),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton.icon(
          onPressed: missionId.isEmpty
              ? null
              : () => context.push(
                    RouteNames.transporteurMissionEnRoutePathFor(missionId),
                  ),
          icon: const Icon(Icons.local_shipping, size: 20),
          label: Text(
            'Démarrer la livraison',
            style: AppTextStyles.button.copyWith(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)),
          ),
        ),
      ),
    );
  }
}
