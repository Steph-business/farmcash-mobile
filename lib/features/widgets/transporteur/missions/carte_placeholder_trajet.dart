import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';

const Color _kMapBg = Color(0xFFE5F4E8);

/// Carte placeholder affichant un fond vert clair, un marker camion
/// central, un pin destination et un bouton "recentrer". Sert d'aperçu
/// visuel tant qu'une vraie carte (Google Maps / Mapbox) n'est pas
/// branchée sur la page « En route ».
class CartePlaceholderTrajet extends StatelessWidget {
  const CartePlaceholderTrajet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 280,
      width: double.infinity,
      color: _kMapBg,
      child: Stack(
        children: [
          // Truck marker au centre
          Center(
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3),
              ),
              alignment: Alignment.center,
              child: const Icon(Icons.local_shipping,
                  size: 20, color: Colors.white),
            ),
          ),
          // Destination pin
          Positioned(
            top: 60,
            right: 80,
            child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: AppColors.error,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              alignment: Alignment.center,
              child: const Icon(Icons.place, size: 14, color: Colors.white),
            ),
          ),
          // Recentrer bouton
          Positioned(
            right: 12,
            bottom: 12,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                    color: AppColors.border, width: AppDimens.borderThin),
              ),
              alignment: Alignment.center,
              child: const Icon(Icons.my_location,
                  size: 20, color: AppColors.text),
            ),
          ),
        ],
      ),
    );
  }
}
