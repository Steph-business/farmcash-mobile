import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';

const Color _kPrimarySoft = Color(0xFFE8F5E9);

/// Avatar humain rond pour l'en-tête d'un chat : utilise `photoUrl` si
/// fourni (chargée via cache réseau), sinon retombe sur les initiales du
/// `fallbackName`. Taille fixe alignée sur [AvatarBot] pour cohérence
/// visuelle entre conversations IA et humaines.
class AvatarChat extends StatelessWidget {
  const AvatarChat({
    required this.photoUrl,
    required this.fallbackName,
    super.key,
  });

  final String? photoUrl;
  final String fallbackName;

  @override
  Widget build(BuildContext context) {
    final hasPhoto = photoUrl != null && photoUrl!.isNotEmpty;
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: _kPrimarySoft,
        shape: BoxShape.circle,
        border:
            Border.all(color: AppColors.border, width: AppDimens.borderThin),
      ),
      clipBehavior: Clip.antiAlias,
      child: hasPhoto
          ? CachedNetworkImage(
              imageUrl: photoUrl!,
              fit: BoxFit.cover,
              placeholder: (_, _) => const ColoredBox(color: _kPrimarySoft),
              errorWidget: (_, _, _) => _Initiales(name: fallbackName),
            )
          : _Initiales(name: fallbackName),
    );
  }
}

/// Affiche les initiales (2 lettres) extraites du nom complet — utilisé
/// comme fallback dans [AvatarChat] quand pas de photo disponible.
class _Initiales extends StatelessWidget {
  const _Initiales({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        _initiales(name),
        style: AppTextStyles.labelSmall.copyWith(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: AppColors.primary,
        ),
      ),
    );
  }
}

String _initiales(String s) {
  final t = s.trim();
  if (t.isEmpty) return '?';
  final parts = t.split(RegExp(r'[\s\-_]+'))..removeWhere((p) => p.isEmpty);
  if (parts.length >= 2) {
    return (parts[0].substring(0, 1) + parts[1].substring(0, 1)).toUpperCase();
  }
  if (t.length == 1) return t.toUpperCase();
  return t.substring(0, 2).toUpperCase();
}
