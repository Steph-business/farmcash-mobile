import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_text_styles.dart';
import 'annonce_detail_constants.dart';
import 'section_annonce.dart';

/// Section "Certifications" : Wrap de chips vertes listant les labels du
/// produit (bio, équitable, etc.). Affichée uniquement si la liste n'est
/// pas vide.
class SectionCertificationsAnnonce extends StatelessWidget {
  const SectionCertificationsAnnonce({
    required this.certifications,
    super.key,
  });

  final List<String> certifications;

  @override
  Widget build(BuildContext context) {
    return SectionAnnonce(
      title: 'Certifications',
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final c in certifications)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: kAnnonceDetailPrimarySoft,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                c,
                style: AppTextStyles.labelMedium.copyWith(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
