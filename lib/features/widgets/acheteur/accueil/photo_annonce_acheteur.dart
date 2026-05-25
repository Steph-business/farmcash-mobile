import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_text_styles.dart';

/// Photo d'annonce dans une grid card de l'accueil acheteur.
///
/// Affiche [PhotoPlaceholderAnnonceAcheteur] si l'URL est nulle/vide,
/// ou en cas d'erreur de chargement. Sinon, [CachedNetworkImage] avec
/// `BoxFit.cover`.
class PhotoAnnonceAcheteur extends StatelessWidget {
  const PhotoAnnonceAcheteur({super.key, required this.url});

  final String? url;

  @override
  Widget build(BuildContext context) {
    if (url == null || url!.isEmpty) {
      return const PhotoPlaceholderAnnonceAcheteur();
    }
    return CachedNetworkImage(
      imageUrl: url!,
      fit: BoxFit.cover,
      placeholder: (_, __) => const PhotoPlaceholderAnnonceAcheteur(),
      errorWidget: (_, __, ___) => const PhotoPlaceholderAnnonceAcheteur(),
    );
  }
}

/// Placeholder neutre affiché en l'absence de photo. Fond surfaceSoft +
/// label "Photo" centré.
class PhotoPlaceholderAnnonceAcheteur extends StatelessWidget {
  const PhotoPlaceholderAnnonceAcheteur({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surfaceSoft,
      alignment: Alignment.center,
      child: Text(
        'Photo',
        style: AppTextStyles.labelSmall.copyWith(
          color: AppColors.textSubtle,
          fontSize: 11,
        ),
      ),
    );
  }
}
