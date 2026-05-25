import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';
import '_constantes_accueil_coop.dart';

/// Card "outil intelligent" : photo en haut (avec gradient overlay subtil
/// et badge circulaire en bas-droite portant l'icône de l'outil), puis
/// titre + sous-titre descriptif. Utilisée dans la grille IA de l'accueil.
class CarteOutilIaCoop extends StatelessWidget {
  const CarteOutilIaCoop({
    super.key,
    required this.photoUrl,
    required this.badgeIcon,
    required this.titre,
    required this.sousTitre,
    required this.onTap,
  });

  final String photoUrl;
  final IconData badgeIcon;
  final String titre;
  final String sousTitre;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: kBrCardCoop,
      child: InkWell(
        onTap: onTap,
        borderRadius: kBrCardCoop,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: kBrCardCoop,
            border: Border.all(
              color: AppColors.border,
              width: AppDimens.borderThin,
            ),
          ),
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Photo + badge en bas-droite (overflow autorisé via Stack)
              SizedBox(
                height: 80 + 12, // 80 photo + 12 badge overflow
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned.fill(
                      bottom: 12,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            CachedNetworkImage(
                              imageUrl: photoUrl,
                              fit: BoxFit.cover,
                              placeholder: (_, __) => Container(
                                color: AppColors.surfaceSoft,
                              ),
                              errorWidget: (_, __, ___) => Container(
                                color: AppColors.surfaceSoft,
                              ),
                            ),
                            // Overlay gradient subtil (sombre en bas) pour
                            // mieux faire ressortir le badge et préparer
                            // l'arrivée éventuelle d'un texte sur photo.
                            const DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Color(0x00000000),
                                    Color(0x4D000000),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      right: 8,
                      bottom: 0,
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.border,
                            width: AppDimens.borderThin,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Icon(
                          badgeIcon,
                          size: 18,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                titre,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                sousTitre,
                style: AppTextStyles.bodySmall.copyWith(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
