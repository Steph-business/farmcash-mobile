import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../models/enums.dart';
import '../../../../models/publication_coop.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';

/// Vignette grille d'une publication marché coopérative.
class CartePublicationGrille extends StatelessWidget {
  const CartePublicationGrille({
    super.key,
    required this.pub,
    required this.onTap,
  });

  /// Publication à afficher.
  final PublicationCoop pub;

  /// Action déclenchée au tap sur la carte.
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final photoUrl = pub.photos.isNotEmpty ? pub.photos.first : null;
    final qteLabel = '${_fmtKg(pub.quantiteKg)} kg';
    final prixLabel = '${_fmtMontant(pub.prixParKg)} F/kg';
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.border,
              width: AppDimens.borderThin,
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AspectRatio(
                aspectRatio: 16 / 11,
                child: photoUrl != null
                    ? CachedNetworkImage(
                        imageUrl: photoUrl,
                        fit: BoxFit.cover,
                        placeholder: (_, _) =>
                            const ColoredBox(color: AppColors.surfaceSoft),
                        errorWidget: (_, _, _) => Container(
                          color: AppColors.surfaceSoft,
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.image_outlined,
                            color: AppColors.textSubtle,
                            size: 22,
                          ),
                        ),
                      )
                    : Container(
                        color: AppColors.surfaceSoft,
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.image_outlined,
                          color: AppColors.textSubtle,
                          size: 22,
                        ),
                      ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      pub.titre,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.text,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      qteLabel,
                      style: AppTextStyles.titleSmall.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.text,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      prixLabel,
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _statusLabel(pub.status),
                      style: AppTextStyles.labelSmall.copyWith(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String _fmtKg(double kg) {
  final i = kg.round();
  return _fmtMontant(i.toDouble());
}

String _fmtMontant(double v) {
  final i = v.round();
  if (i < 1000) return '$i';
  final s = '$i';
  final buf = StringBuffer();
  for (var k = 0; k < s.length; k++) {
    if (k > 0 && (s.length - k) % 3 == 0) buf.write(' ');
    buf.write(s[k]);
  }
  return buf.toString();
}

String _statusLabel(ProductStatus status) {
  switch (status) {
    case ProductStatus.active:
      return 'Active';
    case ProductStatus.paused:
      return 'En pause';
    case ProductStatus.sold:
      return 'Vendue';
    case ProductStatus.expired:
      return 'Expirée';
    case ProductStatus.draft:
      return 'Brouillon';
    case ProductStatus.unknown:
      return '';
  }
}
