import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';

/// Rayon de bordure standard pour les cartes "groupe" du profil (14px,
/// entre le 12 standard des `Settings` et le 16 des cartes "identité").
const BorderRadius kRayonGroupeProfil =
    BorderRadius.all(Radius.circular(14));

/// Bloc "TITRE UPPERCASE + carte regroupant des tuiles" — pattern iOS
/// Settings utilisé sur toutes les pages profil (acheteur, producteur,
/// transporteur, coopérative).
///
/// Trace un titre gris secondaire au-dessus, puis une carte fond blanc +
/// bordure 1px + radius 14, dans laquelle un `Divider` 1px est intercalé
/// entre chaque enfant. Le contenu est clippé pour que les `InkWell` des
/// tuiles respectent l'arrondi.
class GroupeProfil extends StatelessWidget {
  /// Construit le groupe avec son titre et ses lignes.
  const GroupeProfil({
    super.key,
    required this.titre,
    required this.enfants,
  });

  /// Titre de la section (affiché en MAJUSCULES).
  final String titre;

  /// Lignes du groupe (typiquement des [TuileProfil] / [TuileToggleProfil]).
  final List<Widget> enfants;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(
            left: 4,
            right: 4,
            bottom: AppDimens.space8,
          ),
          child: Text(
            titre.toUpperCase(),
            style: AppTextStyles.labelSmall.copyWith(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.4,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: kRayonGroupeProfil,
            border: Border.all(
              color: AppColors.border,
              width: AppDimens.borderThin,
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              for (var i = 0; i < enfants.length; i++) ...[
                enfants[i],
                if (i < enfants.length - 1)
                  const Divider(
                    height: 1,
                    thickness: 1,
                    color: AppColors.border,
                  ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
