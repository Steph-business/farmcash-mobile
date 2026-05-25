import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../models/annonce_achat.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';
import 'bouton_action_offre.dart';
import 'chip_badge_offre.dart';

const Color _kPrimarySoft = Color(0xFFE8F5E9);
final NumberFormat _nf = NumberFormat('#,##0', 'fr_FR');

/// Carte d'une offre d'achat reçue par la coopérative dans le feed
/// d'offres. Buyer anonymisé (label générique). Actions : Refuser /
/// Proposer / + Solliciter mes fournisseurs.
class CarteOffreRecue extends StatelessWidget {
  const CarteOffreRecue({
    super.key,
    required this.offre,
    required this.busy,
    required this.onRefuser,
    required this.onProposer,
    required this.onSolliciter,
  });

  final AnnonceAchat offre;
  final bool busy;
  final VoidCallback onRefuser;
  final VoidCallback onProposer;
  final VoidCallback onSolliciter;

  @override
  Widget build(BuildContext context) {
    final df = DateFormat('d MMM', 'fr_FR');
    final timing = offre.createdAt != null
        ? 'Reçue le ${df.format(offre.createdAt!)}'
        : 'Reçue récemment';
    final isPublic = offre.targetCooperativeId == null;
    final chipLabel = isPublic ? 'Public' : 'Coop ciblée';
    final demande = '${offre.produitLabel} · '
        '${_nf.format(offre.quantiteKg.round())} kg @ '
        'max ${_nf.format(offre.prixMaxKg.round())} F/kg';
    final buyerLabel = offre.buyerNom ?? 'Acheteur';

    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppDimens.radiusCard),
        border: Border.all(
          color: AppColors.border,
          width: AppDimens.borderThin,
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  color: _kPrimarySoft,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.business_outlined,
                  size: 20,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      buyerLabel,
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      timing,
                      style: AppTextStyles.bodySmall.copyWith(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              ChipBadgeOffre(label: chipLabel, isPublic: isPublic),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceSoft,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: AppColors.border,
                width: AppDimens.borderThin,
              ),
            ),
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Demande',
                  style: AppTextStyles.labelSmall.copyWith(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  demande,
                  style: AppTextStyles.titleLarge.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.text,
                  ),
                ),
              ],
            ),
          ),
          if (offre.dateLimiteLivraison != null) ...[
            const SizedBox(height: 6),
            Text(
              'Livraison avant le ${DateFormat('d MMM y', 'fr_FR').format(offre.dateLimiteLivraison!)}',
              style: AppTextStyles.labelSmall.copyWith(
                fontSize: 11,
                color: AppColors.textSubtle,
              ),
            ),
          ],
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: BoutonActionOffre(
                  label: 'Refuser',
                  primary: false,
                  onTap: busy ? null : onRefuser,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: BoutonActionOffre(
                  label: 'Proposer',
                  primary: true,
                  busy: busy,
                  onTap: busy ? null : onProposer,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(height: 1, color: AppColors.border),
          const SizedBox(height: 12),
          InkWell(
            onTap: busy ? null : onSolliciter,
            borderRadius: BorderRadius.circular(6),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text(
                '+ Solliciter mes fournisseurs (membres / autres coops)',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
