import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import 'publication_coop_constants.dart';
import 'simple_row_publication_coop.dart';

/// Carte « Ma contribution » : quantite engagee, qualite annoncee,
/// statut d'engagement (« en attente de livraison »…).
class ContributionCardPublicationCoop extends StatelessWidget {
  const ContributionCardPublicationCoop({
    required this.quantite,
    required this.qualite,
    required this.statut,
    super.key,
  });

  final String quantite;
  final String qualite;
  final String statut;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: kBrCardPublicationCoop,
        border: Border.all(
          color: AppColors.border,
          width: AppDimens.borderThin,
        ),
      ),
      child: Column(
        children: [
          SimpleRowPublicationCoop(label: 'Quantité', value: quantite),
          AppDimens.vGap8,
          SimpleRowPublicationCoop(label: 'Qualité', value: qualite),
          AppDimens.vGap8,
          SimpleRowPublicationCoop(label: 'Statut', value: statut),
        ],
      ),
    );
  }
}
