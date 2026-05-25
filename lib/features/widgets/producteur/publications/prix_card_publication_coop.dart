import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import 'label_value_row_publication_coop.dart';
import 'publication_coop_constants.dart';

/// Carte « Prix » : prix unitaire (info) + total membre (highlight).
class PrixCardPublicationCoop extends StatelessWidget {
  const PrixCardPublicationCoop({
    required this.prixUnitaire,
    required this.totalMembre,
    super.key,
  });

  final String prixUnitaire;
  final String totalMembre;

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
          LabelValueRowPublicationCoop(
            label: 'Prix unitaire',
            value: prixUnitaire,
            highlight: false,
          ),
          AppDimens.vGap12,
          Container(
            height: 1,
            color: AppColors.border,
          ),
          AppDimens.vGap12,
          LabelValueRowPublicationCoop(
            label: 'Total estimé pour ma part',
            value: totalMembre,
            highlight: true,
          ),
        ],
      ),
    );
  }
}
