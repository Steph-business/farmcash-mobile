import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_dimens.dart';
import '../../../theme/app_text_styles.dart';

/// État affiché lorsque la liste des notifications est vide.
///
/// Centre une icône `notifications_none_outlined`, un titre court et un
/// sous-titre rassurant. Aucun callback : c'est un état purement
/// décoratif rendu par la page parente.
class EtatVideNotifications extends StatelessWidget {
  const EtatVideNotifications({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimens.space24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.notifications_none_outlined,
              size: 40,
              color: AppColors.textSubtle.withValues(alpha: 0.9),
            ),
            const SizedBox(height: AppDimens.space12),
            Text(
              'Aucune notification',
              style: AppTextStyles.titleSmall,
            ),
            const SizedBox(height: AppDimens.space4),
            Text(
              'Tu seras prévenu dès qu\'un événement arrive.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
