import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';

/// Sous-entete sous le titre principal de la page des previsions membres.
/// Resume textuel "12 previsions actives - 6.2 tonnes prevues" (mock V1).
class SousEntetePrevisions extends StatelessWidget {
  const SousEntetePrevisions({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppDimens.pagePaddingH,
        0,
        AppDimens.pagePaddingH,
        AppDimens.space12,
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          '12 prévisions actives · 6.2 tonnes prévues',
          style: AppTextStyles.bodySmall.copyWith(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
