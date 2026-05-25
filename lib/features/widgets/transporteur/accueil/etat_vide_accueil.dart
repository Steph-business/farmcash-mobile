import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../routing/route_names.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';

/// État vide affiché quand le transporteur n'a ni mission active, ni
/// missions disponibles, ni prochains chargements — incite à déclarer un
/// itinéraire pour amorcer le matching.
class EtatVideAccueil extends StatelessWidget {
  const EtatVideAccueil({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppDimens.space32),
      child: Column(
        children: [
          Text(
            'Aucune mission pour le moment',
            style: AppTextStyles.titleMedium.copyWith(
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          AppDimens.vGap8,
          Text(
            'Déclarez un itinéraire pour recevoir des propositions.',
            style: AppTextStyles.bodySmall,
            textAlign: TextAlign.center,
          ),
          AppDimens.vGap16,
          SizedBox(
            height: AppDimens.buttonHeight,
            child: ElevatedButton(
              onPressed: () =>
                  context.push(RouteNames.transporteurItinerairesPath),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.onPrimary,
                elevation: 0,
                shape: const RoundedRectangleBorder(
                  borderRadius: AppDimens.brButton,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimens.space24,
                ),
              ),
              child: Text(
                'Déclarer un itinéraire',
                style: AppTextStyles.button,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
