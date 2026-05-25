import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../models/annonce_vente.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';
import 'annonce_detail_constants.dart';
import 'annonce_detail_helpers.dart';
import 'chip_statut_annonce.dart';

/// Hero de la page détail d'une annonce producteur : photo principale,
/// titre enrichi (qualité concaténée si applicable) et chip de statut.
class HeroAnnonceDetail extends StatelessWidget {
  const HeroAnnonceDetail({required this.annonce, super.key});

  final AnnonceVente annonce;

  @override
  Widget build(BuildContext context) {
    final photoUrl = annonce.photos.isNotEmpty
        ? annonce.photos.first
        : kAnnonceDetailHeroFallback;
    final titreComplet = _titreComplet(annonce);

    return Container(
      color: AppColors.background,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: CachedNetworkImage(
              imageUrl: photoUrl,
              fit: BoxFit.cover,
              placeholder: (_, _) => Container(color: AppColors.surfaceSoft),
              errorWidget: (_, _, _) =>
                  Container(color: AppColors.surfaceSoft),
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 16),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: AppColors.border,
                  width: AppDimens.borderThin,
                ),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titreComplet,
                  style: AppTextStyles.titleLarge.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 8),
                ChipStatutAnnonce(status: annonce.status),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _titreComplet(AnnonceVente a) {
    final qualite = annonceDetailQualiteLabel(a.qualite);
    if (qualite == null) return a.titre;
    if (a.titre.toLowerCase().contains(qualite.toLowerCase())) return a.titre;
    return '${a.titre} — qualité $qualite';
  }
}
