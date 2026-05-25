import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../routing/route_names.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';

const BorderRadius _kBrCard = BorderRadius.all(Radius.circular(12));

/// Pied de page sticky de la Logistique coop : 2 boutons cote a cote
/// "Vehicule" (outline) et "Collecte" (primary) qui poussent vers les
/// pages de creation respectives.
class BoutonsActionsLogistique extends StatelessWidget {
  const BoutonsActionsLogistique({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(
          top: BorderSide(
            color: AppColors.border,
            width: AppDimens.borderThin,
          ),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(
        AppDimens.pagePaddingH,
        12,
        AppDimens.pagePaddingH,
        12,
      ),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 44,
              child: OutlinedButton.icon(
                onPressed: () => context.push(
                  RouteNames.cooperativeVehiculeAjouterPath,
                ),
                icon:
                    const Icon(Icons.add, size: 16, color: AppColors.primary),
                label: Text(
                  'Véhicule',
                  style: AppTextStyles.button.copyWith(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(
                    color: AppColors.primary,
                    width: AppDimens.borderThin,
                  ),
                  shape:
                      const RoundedRectangleBorder(borderRadius: _kBrCard),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: SizedBox(
              height: 44,
              child: ElevatedButton.icon(
                onPressed: () => context.push(
                  RouteNames.cooperativeCollecteCreerPath,
                ),
                icon: const Icon(Icons.add, size: 16, color: Colors.white),
                label: Text(
                  'Collecte',
                  style: AppTextStyles.button.copyWith(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: const RoundedRectangleBorder(borderRadius: _kBrCard),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
