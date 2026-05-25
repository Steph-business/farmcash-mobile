import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../routing/route_names.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';

/// Bandeau d'alerte non-dismissible affiché en tête de l'accueil producteur
/// tant que le farmer n'a aucune parcelle enregistrée. Le bouton
/// "Ajouter ma parcelle" pousse vers le formulaire de création (point
/// d'entrée alternatif au flow "Publier").
class BandeauParcellesVide extends StatelessWidget {
  const BandeauParcellesVide({super.key, required this.asyncCount});

  final AsyncValue<int> asyncCount;

  @override
  Widget build(BuildContext context) {
    final shouldShow = asyncCount.maybeWhen(
      data: (count) => count == 0,
      orElse: () => false,
    );
    if (!shouldShow) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimens.space24),
      child: Container(
        padding: const EdgeInsets.all(AppDimens.space16),
        decoration: BoxDecoration(
          color: AppColors.surfaceSoft,
          borderRadius: AppDimens.brCard,
          border: Border.all(
            color: AppColors.borderStrong,
            width: AppDimens.borderThin,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(
              Icons.info_outline,
              size: AppDimens.iconM,
              color: AppColors.primary,
            ),
            AppDimens.hGap12,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Tu n\'as pas encore enregistré ton champ',
                    style: AppTextStyles.titleSmall.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Indique-nous où tu cultives pour pouvoir publier '
                    'tes annonces.',
                    style: AppTextStyles.bodySmall,
                  ),
                  AppDimens.vGap12,
                  InkWell(
                    onTap: () => context.push(
                      RouteNames.producteurCreerParcellePath,
                    ),
                    borderRadius: BorderRadius.circular(6),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 4,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Ajouter ma parcelle',
                            style: AppTextStyles.link,
                          ),
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.arrow_forward,
                            size: 16,
                            color: AppColors.primary,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
