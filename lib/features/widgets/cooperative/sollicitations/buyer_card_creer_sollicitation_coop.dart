import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';

const Color _kPrimarySoft = Color(0xFFE8F5E9);
final NumberFormat _nf = NumberFormat('#,##0', 'fr_FR');

/// Card primary-soft, read-only, affichant l'offre cliente à couvrir
/// (acheteur anonymisé « Industries A. », produit + quantité + prix max,
/// date de livraison). Présentée en haut du formulaire de création de
/// sollicitation pour rappeler le contexte de l'appel d'offres.
///
/// Tous les champs sont nullable car la coop peut accéder à la page sans
/// offre source précise (via FAB) — dans ce cas on affiche un placeholder
/// neutre.
class BuyerCardCreerSollicitationCoop extends StatelessWidget {
  const BuyerCardCreerSollicitationCoop({
    super.key,
    this.buyerNom,
    this.buyerPhotoUrl,
    this.produitNom,
    this.quantiteKg,
    this.prixMaxKg,
    this.dateLimiteLivraison,
  });

  /// Nom anonymisé de l'acheteur (anti-contournement : « Industries A. »).
  final String? buyerNom;
  final String? buyerPhotoUrl;
  final String? produitNom;
  final double? quantiteKg;
  final double? prixMaxKg;
  final DateTime? dateLimiteLivraison;

  @override
  Widget build(BuildContext context) {
    final hasOffre = produitNom != null && quantiteKg != null;
    return Container(
      decoration: BoxDecoration(
        color: _kPrimarySoft,
        borderRadius: BorderRadius.circular(AppDimens.radiusCard),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.15),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ClipOval(
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceSoft,
                    border: Border.all(
                      color: AppColors.border,
                      width: AppDimens.borderThin,
                    ),
                    shape: BoxShape.circle,
                  ),
                  clipBehavior: Clip.hardEdge,
                  child: (buyerPhotoUrl != null && buyerPhotoUrl!.isNotEmpty)
                      ? CachedNetworkImage(
                          imageUrl: buyerPhotoUrl!,
                          fit: BoxFit.cover,
                          placeholder: (_, _) =>
                              Container(color: AppColors.surfaceSoft),
                          errorWidget: (_, _, _) => const Icon(
                            Icons.person_outline,
                            color: AppColors.textSubtle,
                          ),
                        )
                      : const Icon(
                          Icons.person_outline,
                          color: AppColors.textSubtle,
                        ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      buyerNom ?? 'Acheteur',
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Coop ciblée',
                      style: AppTextStyles.labelSmall.copyWith(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            hasOffre
                ? _buildOffreLabel()
                : 'Pas d\'offre source — sollicitation libre',
            style: AppTextStyles.titleLarge.copyWith(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.text,
            ),
          ),
          if (dateLimiteLivraison != null) ...[
            const SizedBox(height: 6),
            Text(
              'Livraison souhaitée : '
              '${DateFormat('d MMM', 'fr_FR').format(dateLimiteLivraison!)}',
              style: AppTextStyles.bodySmall.copyWith(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _buildOffreLabel() {
    final qte = _nf.format(quantiteKg!.round());
    final parts = <String>['$produitNom · $qte kg'];
    if (prixMaxKg != null && prixMaxKg! > 0) {
      parts.add('max ${_nf.format(prixMaxKg!.round())} F/kg');
    }
    return parts.join(' · ');
  }
}
