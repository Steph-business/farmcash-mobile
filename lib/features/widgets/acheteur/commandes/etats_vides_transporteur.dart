import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';
import 'args_devis_transporteur.dart';

/// État affiché lorsque la page « Choisir mon transporteur » est ouverte
/// directement sans args (sans passer par le flow paiement).
class EtatArgsManquantsTransporteur extends StatelessWidget {
  const EtatArgsManquantsTransporteur({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimens.space24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.local_shipping_outlined,
              size: 44,
              color: AppColors.textSubtle.withValues(alpha: 0.9),
            ),
            const SizedBox(height: AppDimens.space12),
            Text(
              'Devis transport indisponibles',
              style: AppTextStyles.titleSmall,
            ),
            const SizedBox(height: AppDimens.space8),
            Text(
              'Ouvre cette page depuis l\'écran de paiement\nd\'une commande pour comparer les transporteurs.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySmall.copyWith(
                fontSize: 12,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// État affiché quand aucun transporteur ne couvre le trajet demandé.
class EtatAucunDevisTransporteur extends StatelessWidget {
  const EtatAucunDevisTransporteur({required this.args, super.key});

  /// Arguments du trajet (origine, destination) — utilisés pour l'affichage.
  final ArgsDevisTransporteur args;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimens.space24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.search_off_outlined,
              size: 44,
              color: AppColors.textSubtle.withValues(alpha: 0.9),
            ),
            const SizedBox(height: AppDimens.space12),
            Text(
              'Aucun devis pour ce trajet',
              style: AppTextStyles.titleSmall,
            ),
            const SizedBox(height: AppDimens.space8),
            Text(
              'Aucun transporteur n\'a déclaré une route\n${args.origineZone} → ${args.destinationZone}.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySmall.copyWith(
                fontSize: 12,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
