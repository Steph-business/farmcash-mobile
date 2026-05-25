import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';
import 'sollicitation_detail.dart';

const Color _kPrimarySoft = Color(0xFFE8F5E9);

const String _kMaisThumb =
    'https://images.unsplash.com/photo-1601493700631-2b16ec4b4716?w=200&h=200&fit=crop&auto=format';

/// Carte récap de la sollicitation à laquelle le producteur répond.
///
/// Affiche le logo + nom de la coop, la date limite si présente, un
/// résumé synthétique (quantité, délai, prix min) et une vignette
/// produit (avec fallback maïs si non fournie).
class SollicitationRecapCard extends StatelessWidget {
  const SollicitationRecapCard({required this.detail, super.key});

  final SollicitationDetail detail;

  @override
  Widget build(BuildContext context) {
    final qte = detail.quantiteKg;
    final prix = detail.prixMinKg;
    final delaiJours =
        detail.expiresAt?.difference(DateTime.now()).inDays;
    final parts = <String>[
      if (qte != null) '${qte.toStringAsFixed(0)} kg ${detail.produitNom}',
      if (qte == null) detail.produitNom,
      if (delaiJours != null && delaiJours > 0) 'max ${delaiJours}j',
      if (prix != null && prix > 0) '≥ ${prix.toStringAsFixed(0)} F/kg',
    ];
    final summary = parts.isEmpty
        ? (detail.message ?? 'Sollicitation reçue')
        : parts.join(' · ');
    final thumbUrl = detail.produitThumb ?? _kMaisThumb;

    return Container(
      decoration: BoxDecoration(
        color: _kPrimarySoft,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.border,
          width: AppDimens.borderThin,
        ),
      ),
      padding: const EdgeInsets.fromLTRB(14, 14, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceSoft,
                    border: Border.all(
                      color: AppColors.border,
                      width: AppDimens.borderThin,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  clipBehavior: Clip.hardEdge,
                  child: detail.coopLogoUrl == null ||
                          detail.coopLogoUrl!.isEmpty
                      ? Container(
                          color: AppColors.surfaceSoft,
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.groups_outlined,
                            size: 16,
                            color: AppColors.primary,
                          ),
                        )
                      : CachedNetworkImage(
                          imageUrl: detail.coopLogoUrl!,
                          fit: BoxFit.cover,
                          placeholder: (_, _) =>
                              Container(color: AppColors.surfaceSoft),
                          errorWidget: (_, _, _) =>
                              Container(color: AppColors.surfaceSoft),
                        ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  detail.coopNom,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (detail.expiresAt != null)
                Text(
                  'Jusqu\'au ${DateFormat('d MMM', 'fr_FR').format(detail.expiresAt!)}',
                  style: AppTextStyles.bodySmall.copyWith(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  summary,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontSize: 13,
                    color: AppColors.text,
                    height: 1.4,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceSoft,
                    border: Border.all(
                      color: AppColors.border,
                      width: AppDimens.borderThin,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  clipBehavior: Clip.hardEdge,
                  child: CachedNetworkImage(
                    imageUrl: thumbUrl,
                    fit: BoxFit.cover,
                    placeholder: (_, _) =>
                        Container(color: AppColors.surfaceSoft),
                    errorWidget: (_, _, _) =>
                        Container(color: AppColors.surfaceSoft),
                  ),
                ),
              ),
            ],
          ),
          if (detail.message != null &&
              detail.message!.trim().isNotEmpty &&
              !summary.contains(detail.message!.trim())) ...[
            const SizedBox(height: 10),
            Text(
              detail.message!,
              style: AppTextStyles.bodySmall.copyWith(
                fontSize: 12,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
