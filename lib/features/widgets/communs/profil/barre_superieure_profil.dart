import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';

/// Barre supérieure des pages profil acheteur / producteur / transporteur
/// (la coop utilise un `AppBar` Material avec bouton retour à la place).
///
/// Affiche "Mon profil" en titre à gauche et une icône paramètres à droite
/// qui pousse vers la sous-page `profil_settings`. Pas de bouton retour
/// car ces pages sont des onglets du shell.
class BarreSuperieureProfil extends StatelessWidget {
  /// Construit la barre.
  const BarreSuperieureProfil({
    super.key,
    required this.onParametres,
    this.titre = 'Mon profil',
  });

  /// Callback du tap sur l'icône paramètres en haut à droite.
  final VoidCallback onParametres;

  /// Titre affiché à gauche. Par défaut "Mon profil".
  final String titre;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      padding: const EdgeInsets.fromLTRB(
        AppDimens.pagePaddingH,
        AppDimens.space8,
        AppDimens.pagePaddingH,
        AppDimens.space16,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              titre,
              style: AppTextStyles.headlineMedium.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          InkWell(
            onTap: onParametres,
            borderRadius: BorderRadius.circular(18),
            child: Container(
              width: 36,
              height: 36,
              alignment: Alignment.center,
              child: const Icon(
                Icons.settings_outlined,
                size: 22,
                color: AppColors.text,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
