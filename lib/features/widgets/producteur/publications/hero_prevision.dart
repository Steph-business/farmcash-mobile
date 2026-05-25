import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../models/prevision.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';
import 'chip_prevision.dart';
import 'prevision_detail_constants.dart';

/// Hero du détail prévision : photo de récolte (placeholder pour V1) + titre
/// composé "Récolte prévue · X kg · date" + chip de prévision.
class HeroPrevision extends StatelessWidget {
  const HeroPrevision({required this.prevision, super.key});

  final Prevision prevision;

  @override
  Widget build(BuildContext context) {
    final qte = NumberFormat('#,##0', 'fr_FR').format(prevision.quantitePrevKg);
    final date = prevision.dateRecoltePrev != null
        ? DateFormat('d MMM y', 'fr_FR').format(prevision.dateRecoltePrev!)
        : null;
    final titre = date != null
        ? 'Récolte prévue · $qte kg · $date'
        : 'Récolte prévue · $qte kg';

    return Container(
      color: AppColors.background,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: CachedNetworkImage(
              imageUrl: kPrevisionDetailHeroFallback,
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
                  titre,
                  style: AppTextStyles.titleLarge.copyWith(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 8),
                ChipPrevision(prevision: prevision),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
