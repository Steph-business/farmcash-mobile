import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';

/// Filtres secondaires disponibles sur le marché acheteur.
/// Chacun est un toggle ON/OFF appliqué côté client.
enum FiltreSecondaire {
  /// Garde uniquement les annonces avec une certification bio déclarée.
  bio,

  /// Garde uniquement les annonces géolocalisées (région ou ville renseignée).
  /// Quand l'utilisateur aura un `regionId` profil, on filtrera dessus.
  presDeMoi,

  /// Trie les annonces par prix croissant (du moins cher au plus cher).
  prixBas,

  /// Garde uniquement les annonces publiées au nom d'une coopérative.
  coop,
}

extension FiltreSecondaireLabel on FiltreSecondaire {
  /// Libellé affiché dans le chip.
  String get label {
    switch (this) {
      case FiltreSecondaire.bio:
        return 'Bio';
      case FiltreSecondaire.presDeMoi:
        return 'Près de moi';
      case FiltreSecondaire.prixBas:
        return 'Prix bas';
      case FiltreSecondaire.coop:
        return 'Coop';
    }
  }
}

/// Liste horizontale de filtres secondaires (Bio, Près de moi, Prix bas,
/// Coop) + un bouton "+ Filtres" qui ouvre un bottom sheet d'options
/// avancées (tri, qualité, fourchette de prix).
///
/// Chaque chip est un toggle : tap pour activer, tap à nouveau pour
/// désactiver. Plusieurs filtres peuvent être actifs en même temps.
class FiltresSecondairesMarche extends StatelessWidget {
  /// Construit la barre de filtres.
  const FiltresSecondairesMarche({
    super.key,
    required this.selection,
    required this.onToggle,
    required this.onPlusFiltres,
  });

  /// Ensemble des filtres actuellement actifs.
  final Set<FiltreSecondaire> selection;

  /// Callback déclenché quand un filtre est tapé (toggle).
  final ValueChanged<FiltreSecondaire> onToggle;

  /// Callback du bouton "+ Filtres" (ouvre bottom sheet avancée).
  final VoidCallback onPlusFiltres;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 30,
      child: ListView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        children: [
          for (final filtre in FiltreSecondaire.values) ...[
            _ChipFiltre(
              label: filtre.label,
              actif: selection.contains(filtre),
              onTap: () => onToggle(filtre),
            ),
            const SizedBox(width: 8),
          ],
          _ChipFiltre(
            label: '+ Filtres',
            actif: false,
            onTap: onPlusFiltres,
          ),
        ],
      ),
    );
  }
}

class _ChipFiltre extends StatelessWidget {
  const _ChipFiltre({
    required this.label,
    required this.actif,
    required this.onTap,
  });

  final String label;
  final bool actif;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: actif ? AppColors.primary : AppColors.surfaceSoft,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: actif ? AppColors.primary : AppColors.border,
            width: AppDimens.borderThin,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.labelMedium.copyWith(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: actif ? AppColors.onPrimary : AppColors.text,
          ),
        ),
      ),
    );
  }
}
