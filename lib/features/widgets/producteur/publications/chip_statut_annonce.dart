import 'package:flutter/material.dart';

import '../../../../models/enums.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_text_styles.dart';
import 'annonce_detail_constants.dart';
import 'annonce_detail_helpers.dart';

/// Petite chip verte indiquant l'état d'une annonce (active, en pause,
/// vendue...). Affichée sous le titre dans le hero de la page détail.
class ChipStatutAnnonce extends StatelessWidget {
  const ChipStatutAnnonce({required this.status, super.key});

  final ProductStatus status;

  @override
  Widget build(BuildContext context) {
    final label = annonceDetailStatusLabel(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: kAnnonceDetailPrimarySoft,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}
