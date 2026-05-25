import 'package:flutter/material.dart';

import '../../../../models/annonce_vente.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_text_styles.dart';
import 'annonce_detail_constants.dart';
import 'section_annonce.dart';

/// Section "Origine" : libellé localisation (ville/région) + adresse de
/// détail si fournie. Icône épingle dans pastille verte.
class SectionOrigineAnnonce extends StatelessWidget {
  const SectionOrigineAnnonce({required this.annonce, super.key});
  final AnnonceVente annonce;

  @override
  Widget build(BuildContext context) {
    final loc = annonce.localisationLabel ?? 'Localisation non précisée';
    final adresse = annonce.adresseDetail;

    return SectionAnnonce(
      title: 'Origine',
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: kAnnonceDetailPrimarySoft,
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.location_on_outlined,
              size: 18,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  loc,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (adresse != null && adresse.trim().isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    adresse,
                    style: AppTextStyles.bodySmall.copyWith(fontSize: 12),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
