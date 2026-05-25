import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';
import 'assistant_constants.dart';

/// Etat vide de l'assistant : invite l'utilisateur a poser sa premiere
/// question (avatar + titre + description courte).
class EmptyAssistant extends StatelessWidget {
  const EmptyAssistant({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimens.space24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: const BoxDecoration(
                color: kPrimarySoftAssistant,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.auto_awesome_outlined,
                size: 26,
                color: AppColors.primary,
              ),
            ),
            AppDimens.vGap12,
            Text(
              'Pose ta question',
              style: AppTextStyles.titleSmall.copyWith(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            AppDimens.vGap4,
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                "L'assistant FarmCash répond aux questions agricoles : "
                'semis, traitements, prix, conseils.',
                style: AppTextStyles.bodySmall,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
