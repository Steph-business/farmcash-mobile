import 'package:flutter/material.dart';

import '../../../../theme/app_text_styles.dart';
import '../../../../theme/app_dimens.dart';

/// En-tête générique de section sur l'accueil transporteur : titre à gauche
/// + lien d'action optionnel à droite ("Voir tout").
///
/// Distincte du `SectionHead` producteur car les tailles de police diffèrent
/// (14 vs 15) pour s'aligner sur les mockups transporteur.
class SectionHeadTransporteur extends StatelessWidget {
  const SectionHeadTransporteur({
    super.key,
    required this.titre,
    this.lienTexte,
    this.onLienTap,
  });

  final String titre;
  final String? lienTexte;
  final VoidCallback? onLienTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimens.space12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              titre,
              style: AppTextStyles.titleSmall.copyWith(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (lienTexte != null)
            InkWell(
              onTap: onLienTap,
              borderRadius: BorderRadius.circular(6),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 4,
                  vertical: 2,
                ),
                child: Text(
                  lienTexte!,
                  style: AppTextStyles.link.copyWith(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
