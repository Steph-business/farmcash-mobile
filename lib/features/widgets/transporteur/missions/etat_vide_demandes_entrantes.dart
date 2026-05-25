import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_text_styles.dart';

/// État vide affiché quand aucune demande entrante ne correspond aux
/// itinéraires actifs du transporteur. Scrollable pour conserver le
/// `RefreshIndicator` au pull-to-refresh.
class EtatVideDemandesEntrantes extends StatelessWidget {
  const EtatVideDemandesEntrantes({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        const SizedBox(height: 80),
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.inbox_outlined,
                size: 40,
                color: AppColors.textSubtle.withValues(alpha: 0.9),
              ),
              const SizedBox(height: 12),
              Text(
                'Aucune demande en attente',
                style: AppTextStyles.titleSmall,
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  'Les missions correspondant à tes itinéraires actifs apparaîtront ici.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
