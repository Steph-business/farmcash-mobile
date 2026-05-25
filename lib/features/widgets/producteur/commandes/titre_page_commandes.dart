import 'package:flutter/material.dart';

import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';

/// Titre principal de la page "Commandes" du producteur.
class TitrePageCommandes extends StatelessWidget {
  const TitrePageCommandes({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppDimens.pagePaddingH,
        AppDimens.space8,
        AppDimens.pagePaddingH,
        AppDimens.space8,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Commandes',
              style: AppTextStyles.displayLarge.copyWith(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                height: 1.2,
                letterSpacing: -0.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
