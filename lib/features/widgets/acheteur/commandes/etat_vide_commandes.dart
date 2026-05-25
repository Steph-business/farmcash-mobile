import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../routing/route_names.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';

/// Pastel vert pour le rond d'icône hero.
const Color _kPastelVert = Color(0xFFE8F5E9);

/// État vide de la liste « Mes commandes » côté acheteur. Au lieu d'un
/// simple message frustrant, on offre une **explication contextuelle**
/// + un **bouton d'action** qui ramène l'utilisateur vers le marché.
/// L'objectif : transformer un cul-de-sac en une opportunité.
class EtatVideCommandes extends StatelessWidget {
  const EtatVideCommandes({this.titre, this.sousTitre, super.key});

  /// Titre principal personnalisable (par défaut « Aucune commande »).
  final String? titre;

  /// Sous-titre explicatif personnalisable.
  final String? sousTitre;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.space16,
        vertical: 32,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: const BoxDecoration(
              color: _kPastelVert,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.shopping_bag_outlined,
              size: 38,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            titre ?? 'Aucune commande ici',
            textAlign: TextAlign.center,
            style: AppTextStyles.titleMedium.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            sousTitre ??
                'Découvre les annonces des producteurs et lance ta première commande.',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodySmall.copyWith(
              fontSize: 13,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: InkWell(
              onTap: () => context.go(RouteNames.acheteurMarchePath),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 13),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.storefront_outlined,
                      size: 18,
                      color: AppColors.onPrimary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Découvrir le marché',
                      style: AppTextStyles.button.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.onPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
