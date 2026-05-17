import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_dimens.dart';
import '../../../theme/app_text_styles.dart';

/// Affichage d'erreur inline (sous un champ, ou dans une bannière).
///
/// Sobre : texte rouge, pas d'icône colorée prononcée. Le rouge se mérite.
class VueErreur extends StatelessWidget {
  const VueErreur({
    required this.message,
    this.onRetry,
    super.key,
  });

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.space12,
        vertical: AppDimens.space12,
      ),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: AppDimens.brInput,
        border: Border.all(color: AppColors.error, width: AppDimens.borderThin),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              message,
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.error),
            ),
          ),
          if (onRetry != null) ...[
            AppDimens.hGap8,
            TextButton(
              onPressed: onRetry,
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text('Réessayer'),
            ),
          ],
        ],
      ),
    );
  }
}
