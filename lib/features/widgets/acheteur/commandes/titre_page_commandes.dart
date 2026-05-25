import 'package:flutter/material.dart';

import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';

/// Titre de la page « Mes commandes » côté acheteur (sous le header).
class TitrePageCommandes extends StatelessWidget {
  const TitrePageCommandes({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          20, AppDimens.space8, 20, AppDimens.space12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Mes commandes',
              style: AppTextStyles.headlineSmall.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
