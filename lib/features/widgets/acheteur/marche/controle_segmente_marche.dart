import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';

/// Onglets exposés par le marché acheteur : annonces directes ou
/// prévisions à venir. Le segment sélectionné détermine la grille
/// affichée en dessous.
enum SegmentMarche { annonces, previsions }

/// Contrôle segmenté (2 onglets) affichant les compteurs entre
/// parenthèses pour chaque onglet.
class ControleSegmenteMarche extends StatelessWidget {
  const ControleSegmenteMarche({
    required this.segment,
    required this.nbAnnonces,
    required this.nbPrevisions,
    required this.onChanged,
    super.key,
  });

  final SegmentMarche segment;
  final int nbAnnonces;
  final int nbPrevisions;
  final ValueChanged<SegmentMarche> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surfaceSoft,
        borderRadius: BorderRadius.circular(12),
        border:
            Border.all(color: AppColors.border, width: AppDimens.borderThin),
      ),
      child: Row(
        children: [
          Expanded(
            child: ItemSegmenteMarche(
              libelle: 'Annonces directes ($nbAnnonces)',
              actif: segment == SegmentMarche.annonces,
              onTap: () => onChanged(SegmentMarche.annonces),
            ),
          ),
          Expanded(
            child: ItemSegmenteMarche(
              libelle: 'Prévisions à venir ($nbPrevisions)',
              actif: segment == SegmentMarche.previsions,
              onTap: () => onChanged(SegmentMarche.previsions),
            ),
          ),
        ],
      ),
    );
  }
}

/// Une demi-cellule du contrôle segmenté. Fond vert plein si actif,
/// transparent sinon.
class ItemSegmenteMarche extends StatelessWidget {
  const ItemSegmenteMarche({
    required this.libelle,
    required this.actif,
    required this.onTap,
    super.key,
  });

  final String libelle;
  final bool actif;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(9),
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(vertical: 9),
        decoration: BoxDecoration(
          color: actif ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(9),
        ),
        child: Text(
          libelle,
          style: AppTextStyles.labelMedium.copyWith(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: actif ? AppColors.onPrimary : AppColors.textSecondary,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}
