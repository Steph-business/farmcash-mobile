import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import 'label_value_row_publication_coop.dart';
import 'publication_coop_constants.dart';

/// Carte « Quantite agregee » : totale (info) + ma part (highlight).
///
/// Separateur fin entre les deux lignes.
class QuantiteCardPublicationCoop extends StatelessWidget {
  const QuantiteCardPublicationCoop({
    required this.agregee,
    required this.maPart,
    super.key,
  });

  final String agregee;
  final String maPart;

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
            label: 'Quantité totale',
            value: agregee,
            highlight: false,
          ),
          AppDimens.vGap12,
          Container(
            height: 1,
            color: AppColors.border,
          ),
          AppDimens.vGap12,
          LabelValueRowPublicationCoop(
            label: 'Dont ma part',
            value: maPart,
            highlight: true,
          ),
        ],
      ),
    );
  }
}
