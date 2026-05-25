import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';

/// Entête de page wallet — bouton retour + titre centré + actions optionnelles.
///
/// Utilisé sur toutes les pages wallet (acheteur / producteur / transporteur /
/// coopérative) en mode liste (sans bordure inférieure) ou formulaire
/// recharger/retirer (avec [bordureBas]).
class EnteteWallet extends StatelessWidget {
  const EnteteWallet({
    super.key,
    required this.titre,
    this.onRetour,
    this.bordureBas = false,
    this.tailleTitre = 16,
    this.actions,
  });

  /// Titre affiché au centre.
  final String titre;

  /// Callback du bouton retour. Si `null`, utilise `Navigator.of(context).pop()`.
  final VoidCallback? onRetour;

  /// Active la bordure inférieure (cas des pages recharger/retirer).
  final bool bordureBas;

  /// Taille de police du titre (16 par défaut sur la page liste, 15 sur les
  /// pages formulaire pour rester fidèle aux maquettes).
  final double tailleTitre;

  /// Widgets affichés à droite (ex : bouton recherche, notifications). Le
  /// premier slot fait 40x40 par défaut côté appelant.
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    final row = Row(
      children: [
        InkWell(
          onTap: onRetour ?? () => Navigator.of(context).pop(),
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
              fontSize: tailleTitre,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        if (actions != null) ...actions! else const SizedBox(width: 40, height: 40),
      ],
    );

    const padding = EdgeInsets.fromLTRB(
      AppDimens.space16,
      AppDimens.space8,
      AppDimens.space16,
      AppDimens.space12,
    );

    if (!bordureBas) {
      return Padding(padding: padding, child: row);
    }
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(
          bottom: BorderSide(
            color: AppColors.border,
            width: AppDimens.borderThin,
          ),
        ),
      ),
      padding: padding,
      child: row,
    );
  }
}
