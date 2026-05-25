import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_text_styles.dart';

/// État affiché lorsque la coopérative ne compte aucun membre.
class EtatVideMembres extends StatelessWidget {
  const EtatVideMembres({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.group_outlined,
            size: 40,
            color: AppColors.textSubtle.withValues(alpha: 0.9),
          ),
          const SizedBox(height: 12),
          Text(
            'Aucun membre pour le moment',
            style: AppTextStyles.titleSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Invite des farmers via le bouton « Inviter ».',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
