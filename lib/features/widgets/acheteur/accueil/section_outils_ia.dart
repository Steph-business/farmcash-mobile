import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';
import 'accueil_acheteur_constants.dart';
import 'section_accueil_acheteur.dart';

/// Section "Outils intelligents" — grille 2 colonnes avec deux cards
/// (Assistant achat, Alertes prix). Chaque card a une photo Unsplash et
/// un badge icône circulaire en bas-droite.
class SectionOutilsIa extends StatelessWidget {
  const SectionOutilsIa({
    super.key,
    required this.onAssistant,
    required this.onAlertes,
  });

  final VoidCallback onAssistant;
  final VoidCallback onAlertes;

  @override
  Widget build(BuildContext context) {
    return SectionAccueilAcheteur(
      titre: 'Outils intelligents',
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: CarteOutilIa(
              photoUrl: kAccueilPhotoAssistantAchat,
              badgeIcon: Icons.chat_bubble_outline,
              titre: 'Assistant achat',
              sousTitre: 'Quel produit, quand acheter, à quel prix',
              onTap: onAssistant,
            ),
          ),
          AppDimens.hGap12,
          Expanded(
            child: CarteOutilIa(
              photoUrl: kAccueilPhotoAlertesPrix,
              badgeIcon: Icons.trending_up,
              titre: 'Alertes prix',
              sousTitre: 'Sois prévenu quand un produit baisse',
              onTap: onAlertes,
            ),
          ),
        ],
      ),
    );
  }
}

/// Card individuelle "outil intelligent" : photo en haut avec badge
/// circulaire en bas-droite, puis titre et sous-titre.
class CarteOutilIa extends StatelessWidget {
  const CarteOutilIa({
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
      borderRadius: kAccueilBrCard,
      child: InkWell(
        onTap: onTap,
        borderRadius: kAccueilBrCard,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: kAccueilBrCard,
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
                        child: CachedNetworkImage(
                          imageUrl: photoUrl,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => Container(
                            color: AppColors.surfaceSoft,
                          ),
                          errorWidget: (_, __, ___) => Container(
                            color: AppColors.surfaceSoft,
                          ),
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
