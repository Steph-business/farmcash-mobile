import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';
import 'photo_profil.dart';

/// Rayon de la carte identité (16px — légèrement plus arrondi que les
/// groupes 14px pour la mettre en valeur).
const BorderRadius kRayonCarteIdentite =
    BorderRadius.all(Radius.circular(16));

/// Carte "identité" affichée en haut des 4 pages profil : photo 72×72 à
/// gauche, nom + sous-ligne au centre, bouton texte "Modifier" à droite.
///
/// La sous-ligne (rôle, ville, rating, etc.) est entièrement spécifique
/// au rôle — elle est passée telle quelle via [sousLigne]. La forme de
/// la photo (ronde ou carrée) est contrôlée par [photoCarree] (carrée
/// pour la coop — logo).
class CarteIdentiteProfil extends StatelessWidget {
  /// Construit la carte identité.
  const CarteIdentiteProfil({
    super.key,
    required this.nom,
    required this.initiales,
    this.photoUrl,
    this.sousLigne,
    this.onModifier,
    this.onEditPhoto,
    this.photoCarree = false,
    this.libelleModifier = 'Modifier',
  });

  /// Nom (titre principal) affiché en gras.
  final String nom;

  /// Initiales fallback si pas de photo.
  final String initiales;

  /// URL distante de la photo (optionnel).
  final String? photoUrl;

  /// Sous-ligne (rôle · ville · ★ rating, ou similaire).
  final String? sousLigne;

  /// Callback du lien texte "Modifier" à droite. Si null, le lien est masqué.
  final VoidCallback? onModifier;

  /// Callback du badge "edit" sur la photo. Si null, pas de badge.
  final VoidCallback? onEditPhoto;

  /// Photo carrée (coop) vs circulaire (autres rôles).
  final bool photoCarree;

  /// Libellé du lien à droite ("Modifier" par défaut).
  final String libelleModifier;

  @override
  Widget build(BuildContext context) {
    final hasSousLigne = sousLigne != null && sousLigne!.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(AppDimens.space16 + 4), // 20
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: kRayonCarteIdentite,
        border: Border.all(
          color: AppColors.border,
          width: AppDimens.borderThin,
        ),
      ),
      child: Row(
        children: [
          PhotoProfil(
            photoUrl: photoUrl,
            initiales: initiales,
            onEdit: onEditPhoto,
            carre: photoCarree,
          ),
          AppDimens.hGap16,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  nom,
                  style: AppTextStyles.titleMedium.copyWith(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    height: 1.2,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (hasSousLigne) ...[
                  const SizedBox(height: 4),
                  Text(
                    sousLigne!,
                    style: AppTextStyles.bodySmall.copyWith(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          if (onModifier != null) ...[
            AppDimens.hGap8,
            InkWell(
              onTap: onModifier,
              borderRadius: BorderRadius.circular(AppDimens.radiusS),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 4,
                  vertical: 6,
                ),
                child: Text(
                  libelleModifier,
                  style: AppTextStyles.link.copyWith(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
