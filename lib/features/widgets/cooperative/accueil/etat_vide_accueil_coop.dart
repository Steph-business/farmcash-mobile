import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';

/// État totalement vide de l'accueil coopérative : aucune métrique
/// significative (pas de membre, pas d'action, pas de stock, pas de solde).
/// Affiche un message d'encouragement + CTA "Inviter un farmer".
class EtatVideAccueilCoop extends StatelessWidget {
  const EtatVideAccueilCoop({super.key, required this.onInviter});

  final VoidCallback onInviter;

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.pagePaddingH,
        vertical: AppDimens.space32,
      ),
      children: [
        const SizedBox(height: AppDimens.space24),
        Center(
          child: Icon(
            Icons.group_outlined,
            size: 40,
            color: AppColors.textSubtle.withValues(alpha: 0.9),
          ),
        ),
        AppDimens.vGap16,
        Text(
          'Votre coopérative est prête.',
          textAlign: TextAlign.center,
          style: AppTextStyles.titleMedium,
        ),
        const SizedBox(height: 4),
        Text(
          'Invitez vos premiers producteurs pour commencer.',
          textAlign: TextAlign.center,
          style: AppTextStyles.bodySmall,
        ),
        AppDimens.vGap16,
        Center(
          child: TextButton(
            onPressed: onInviter,
            child: Text(
              'Inviter un farmer',
              style: AppTextStyles.link,
            ),
          ),
        ),
      ],
    );
  }
}
