import 'package:flutter/material.dart';

import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';

/// Titre principal « Missions » de la page liste transporteur.
class TitrePageMissions extends StatelessWidget {
  const TitrePageMissions({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppDimens.pagePaddingH,
        AppDimens.space8,
        AppDimens.pagePaddingH,
        AppDimens.space8,
      ),
      child: Text(
        'Missions',
        style: AppTextStyles.displayLarge.copyWith(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          height: 1.2,
          letterSpacing: -0.3,
        ),
      ),
    );
  }
}
