import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';
import 'onglet_marche_publications.dart';

/// État vide affiché lorsque le marché coop n'a pas de publication.
class EtatVideMarche extends StatelessWidget {
  const EtatVideMarche({super.key, required this.tab});

  /// Onglet courant — module le message vide.
  final OngletMarcheCoop tab;

  @override
  Widget build(BuildContext context) {
    final msg = tab == OngletMarcheCoop.actives
        ? 'Aucune publication active.'
        : 'Aucune publication archivée.';
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimens.space24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.storefront_outlined,
              size: 40,
              color: AppColors.textSubtle.withValues(alpha: 0.9),
            ),
            const SizedBox(height: AppDimens.space12),
            Text(
              msg,
              style: AppTextStyles.titleSmall,
            ),
          ],
        ),
      ),
    );
  }
}
