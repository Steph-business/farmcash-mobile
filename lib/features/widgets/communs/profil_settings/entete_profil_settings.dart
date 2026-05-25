import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';

/// En-tête commun de la page "Profil & paramètres".
///
/// Affiche un bouton retour à gauche, un titre centré "Profil & paramètres",
/// et un espace réservé symétrique à droite. Le bouton retour utilise
/// `context.pop()` si la stack le permet, sinon `context.go(fallbackPath)`.
///
/// Pattern utilisé identiquement par les 4 rôles
/// (acheteur, producteur, transporteur, coopérative).
class EnteteProfilSettings extends StatelessWidget {
  /// Construit l'en-tête avec un chemin de repli pour le bouton retour
  /// lorsque la pile de navigation est vide (ex. deep-link).
  const EnteteProfilSettings({
    super.key,
    required this.fallbackPath,
    this.titre = 'Profil & paramètres',
  });

  /// Chemin go_router utilisé si `context.canPop()` est faux.
  final String fallbackPath;

  /// Titre affiché au centre. Par défaut "Profil & paramètres".
  final String titre;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppDimens.space16,
        AppDimens.space8,
        AppDimens.space16,
        AppDimens.space12,
      ),
      child: Row(
        children: [
          InkWell(
            onTap: () => context.canPop()
                ? context.pop()
                : context.go(fallbackPath),
            borderRadius: BorderRadius.circular(20),
            child: const SizedBox(
              width: 40,
              height: 40,
              child: Icon(
                Icons.arrow_back_ios_new,
                size: 20,
                color: AppColors.text,
              ),
            ),
          ),
          Expanded(
            child: Text(
              titre,
              style: AppTextStyles.titleSmall.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 40, height: 40),
        ],
      ),
    );
  }
}
