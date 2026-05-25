import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';
import 'groupe_profil.dart' show kRayonGroupeProfil;

/// Bouton "Se déconnecter" pour les pages profil — variante avec icône
/// `logout` rouge à gauche du label, fond blanc, bordure 1px gris border.
///
/// Différent du `BoutonDeconnexion` de `profil_settings/` qui utilise une
/// bordure rouge sans icône. Le pattern profil ajoute une icône à gauche
/// du libellé pour s'aligner sur la maquette HTML.
class BoutonDeconnexionProfil extends StatelessWidget {
  /// Construit le bouton avec son action.
  const BoutonDeconnexionProfil({
    super.key,
    required this.onTap,
    this.label = 'Se déconnecter',
  });

  /// Callback déclenché au tap (typiquement async logout + redirection).
  final VoidCallback onTap;

  /// Libellé. Par défaut "Se déconnecter".
  final String label;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: kRayonGroupeProfil,
      child: InkWell(
        onTap: onTap,
        borderRadius: kRayonGroupeProfil,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: AppDimens.space16),
          decoration: BoxDecoration(
            borderRadius: kRayonGroupeProfil,
            border: Border.all(
              color: AppColors.border,
              width: AppDimens.borderThin,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.logout,
                size: 18,
                color: AppColors.error,
              ),
              AppDimens.hGap8,
              Text(
                label,
                style: AppTextStyles.titleSmall.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.error,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
