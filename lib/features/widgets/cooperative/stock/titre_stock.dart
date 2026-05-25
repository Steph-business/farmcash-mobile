import 'package:flutter/material.dart';

import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';

/// Titre principal de la page Stock coopérative.
class TitreStock extends StatelessWidget {
  const TitreStock({super.key});

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
        'Stock',
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
