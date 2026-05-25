import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';

const String _kCargoPhoto =
    'https://images.unsplash.com/photo-1601493700631-2b16ec4b4716?w=200&h=200&fit=crop&auto=format';

/// Bande horizontale décrivant le cargo en cours de transport :
/// vignette photo, nom du produit et quantité + producteur (encore en
/// mock V1).
class BandeCargoMission extends StatelessWidget {
  const BandeCargoMission({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: AppDimens.borderThin),
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: CachedNetworkImage(
              imageUrl: _kCargoPhoto,
              width: 40,
              height: 40,
              fit: BoxFit.cover,
              placeholder: (_, _) => Container(
                width: 40, height: 40, color: AppColors.surfaceSoft),
              errorWidget: (_, _, _) => Container(
                width: 40,
                height: 40,
                color: AppColors.surfaceSoft,
                child: const Icon(Icons.image_outlined,
                    size: 18, color: AppColors.textSubtle),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Maïs grain blanc',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '500 kg · Yao Konan',
                  style: AppTextStyles.bodySmall.copyWith(
                    fontSize: 11,
                    color: AppColors.textSecondary,
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
