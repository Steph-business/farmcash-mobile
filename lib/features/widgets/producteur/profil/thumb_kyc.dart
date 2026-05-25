import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'icon_box_kyc.dart';
import 'kyc_doc_type_kyc.dart';

/// Vignette d'un document KYC : affiche l'image si l'URL ressemble a une
/// image (`.jpg/.jpeg/.png/.webp/.heic` ou contient `/image`), sinon une
/// IconBoxKyc de fallback.
///
/// L'erreur de chargement reseau retombe automatiquement sur l'icone.
class ThumbKyc extends StatelessWidget {
  const ThumbKyc({required this.url, required this.icon, super.key});

  final String url;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final hasUrl = url.isNotEmpty &&
        (url.startsWith('http://') || url.startsWith('https://'));
    final isImageLike = hasUrl &&
        (url.toLowerCase().endsWith('.jpg') ||
            url.toLowerCase().endsWith('.jpeg') ||
            url.toLowerCase().endsWith('.png') ||
            url.toLowerCase().endsWith('.webp') ||
            url.toLowerCase().endsWith('.heic') ||
            url.toLowerCase().contains('/image'));

    if (isImageLike) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: SizedBox(
          width: 44,
          height: 44,
          child: CachedNetworkImage(
            imageUrl: url,
            fit: BoxFit.cover,
            placeholder: (_, _) => Container(color: kPrimarySoftKyc),
            errorWidget: (_, _, _) => IconBoxKyc(icon: icon),
          ),
        ),
      );
    }
    return IconBoxKyc(icon: icon);
  }
}
