import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';
import 'groupe_settings.dart' show kRayonGroupeSettings;

/// Bouton "Se déconnecter" rouge bordé, plein largeur, centré.
///
/// Affiché en bas de la page "Profil & paramètres". Texte et bordure
/// `AppColors.error`, fond `AppColors.background`. Le callback [onTap]
/// est typiquement asynchrone (logout puis go vers `bienvenuePath`).
class BoutonDeconnexion extends StatelessWidget {
  /// Construit le bouton avec son action de déconnexion.
  const BoutonDeconnexion({super.key, required this.onTap, this.label = 'Se déconnecter'});

  /// Callback déclenché au tap.
  final VoidCallback onTap;

  /// Libellé du bouton. Par défaut "Se déconnecter".
  final String label;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.background,
      borderRadius: kRayonGroupeSettings,
      child: InkWell(
        onTap: onTap,
        borderRadius: kRayonGroupeSettings,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            borderRadius: kRayonGroupeSettings,
            border: Border.all(
              color: AppColors.error,
              width: AppDimens.borderThin,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: AppTextStyles.titleSmall.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.error,
            ),
          ),
        ),
      ),
    );
  }
}
