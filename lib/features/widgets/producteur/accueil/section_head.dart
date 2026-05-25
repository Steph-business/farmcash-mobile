import 'package:flutter/material.dart';

import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';

/// En-tête générique de section sur l'accueil producteur : titre à gauche
/// + lien d'action optionnel à droite ("Voir tout").
///
/// Utilisé par toutes les sections (À traiter, Acheteurs, Coop, Outils IA,
/// Mes annonces, Conseils).
class SectionHead extends StatelessWidget {
  const SectionHead({super.key, required this.titre, this.lienTexte, this.onLien});

  final String titre;
  final String? lienTexte;
  final VoidCallback? onLien;

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
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (lienTexte != null)
            InkWell(
              onTap: onLien,
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
