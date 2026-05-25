import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';

/// Photo de carte (annonce ou autre) avec placeholder et fallback en
/// cas d'erreur ou d'URL absente. `url` accepte `null` ou chaîne vide.
class PhotoCarteMarche extends StatelessWidget {
  const PhotoCarteMarche({required this.url, super.key});

  final String? url;

  @override
  Widget build(BuildContext context) {
    if (url == null || url!.isEmpty) {
      return Container(
        color: AppColors.surfaceSoft,
        alignment: Alignment.center,
        child: const Icon(
          Icons.image_outlined,
          size: 28,
          color: AppColors.textSubtle,
        ),
      );
    }
    return CachedNetworkImage(
      imageUrl: url!,
      fit: BoxFit.cover,
      placeholder: (_, _) => Container(color: AppColors.surfaceSoft),
      errorWidget: (_, _, _) => Container(color: AppColors.surfaceSoft),
    );
  }
}
