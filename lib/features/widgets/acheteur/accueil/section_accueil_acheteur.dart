import 'package:flutter/material.dart';

import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';

/// En-tête de section générique pour l'accueil acheteur : un titre à
/// gauche, optionnellement un lien "Voir tout" à droite, et un [child]
/// rendu sous l'en-tête.
class SectionAccueilAcheteur extends StatelessWidget {
  const SectionAccueilAcheteur({
    super.key,
    required this.titre,
    required this.child,
    this.onVoirTout,
  });

  final String titre;
  final Widget child;
  final VoidCallback? onVoirTout;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              titre,
              style: AppTextStyles.titleSmall.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            if (onVoirTout != null)
              InkWell(
                onTap: onVoirTout,
                borderRadius: BorderRadius.circular(AppDimens.radiusS),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 2,
                  ),
                  child: Text(
                    'Voir tout',
                    style: AppTextStyles.link.copyWith(fontSize: 13),
                  ),
                ),
              ),
          ],
        ),
        AppDimens.vGap12,
        child,
      ],
    );
  }
}
