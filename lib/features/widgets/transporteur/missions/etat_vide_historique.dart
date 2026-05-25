import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';
import 'onglet_historique.dart';

/// État vide affiché dans la page d'historique des missions, avec un
/// message différent selon l'onglet sélectionné (livrées ou annulées).
class EtatVideHistorique extends StatelessWidget {
  const EtatVideHistorique({required this.tab, super.key});

  final OngletHistorique tab;

  @override
  Widget build(BuildContext context) {
    final msg = tab == OngletHistorique.livrees
        ? 'Aucune mission livrée pour le moment'
        : 'Aucune mission annulée';
    return Padding(
      padding: const EdgeInsets.all(AppDimens.space24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.history,
            size: 40,
            color: AppColors.textSubtle.withValues(alpha: 0.9),
          ),
          const SizedBox(height: AppDimens.space12),
          Text(
            msg,
            textAlign: TextAlign.center,
            style: AppTextStyles.titleSmall,
          ),
        ],
      ),
    );
  }
}
