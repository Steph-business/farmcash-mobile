import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../models/sollicitation.dart';
import '../../../../routing/route_names.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';

const Color _kWarnSoft = Color(0xFFFFF8E1);
const Color _kWarn = Color(0xFFB26A00);

const String _kFallbackThumb =
    'https://images.unsplash.com/photo-1601493700631-2b16ec4b4716?w=200&h=200&fit=crop&auto=format';

/// Carte d'une sollicitation recue par le producteur depuis sa coop.
///
/// Affiche le header (avatar coop + chip urgent), le besoin + vignette
/// produit, la progression (farmers ayant repondu + kg engages) et un
/// bouton "Je peux fournir" qui navigue vers la page de reponse.
class SollicitationRecueCard extends StatelessWidget {
  const SollicitationRecueCard({required this.sol, super.key});

  final Sollicitation sol;

  @override
  Widget build(BuildContext context) {
    final quantite = sol.quantiteCibleKg ?? 0;
    final offerte = sol.totalQuantiteOfferte;
    final dejaRepondu = sol.totalResponses;
    final total = sol.totalRecipients;

    final besoin = sol.message?.isNotEmpty == true
        ? sol.message!
        : 'Besoin de ${quantite.toStringAsFixed(0)} kg';

    final timing = _formatTiming(sol.createdAt);

    final urgent = _isUrgent(sol.expiresAt);

    final progression =
        '$dejaRepondu / $total farmers ont répondu '
        '(${offerte.toStringAsFixed(0)} kg engagés sur '
        '${quantite.toStringAsFixed(0)} kg)';

    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.border,
          width: AppDimens.borderThin,
        ),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header card (avatar + nom coop + chip urgent)
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.groups_outlined,
                  size: 18,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Ma coopérative',
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontSize: 13,
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
              if (urgent) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _kWarnSoft,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    'Urgent',
                    style: AppTextStyles.labelSmall.copyWith(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: _kWarn,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),

          // Besoin + vignette produit
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  besoin,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    height: 1.4,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceSoft,
                    border: Border.all(
                      color: AppColors.border,
                      width: AppDimens.borderThin,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  clipBehavior: Clip.hardEdge,
                  child: CachedNetworkImage(
                    imageUrl: _kFallbackThumb,
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
          const SizedBox(height: 10),

          // Progression
          Text(
            progression,
            style: AppTextStyles.bodySmall.copyWith(
              fontSize: 12,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 14),

          Align(
            alignment: Alignment.centerRight,
            child: InkWell(
              onTap: () => context.push(
                RouteNames.producteurSollicitationRepondrePathFor(sol.id),
              ),
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: AppColors.primary,
                    width: AppDimens.borderThin,
                  ),
                ),
                child: Text(
                  'Je peux fournir',
                  style: AppTextStyles.button.copyWith(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTiming(DateTime? createdAt) {
    if (createdAt == null) return 'Sollicitation reçue';
    final now = DateTime.now();
    final diff = now.difference(createdAt);
    if (diff.inMinutes < 60) return 'Reçue il y a ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'Reçue il y a ${diff.inHours} h';
    if (diff.inDays == 1) return 'Reçue hier';
    if (diff.inDays < 7) return 'Reçue il y a ${diff.inDays} j';
    return 'Reçue le ${DateFormat('d MMM', 'fr_FR').format(createdAt)}';
  }

  bool _isUrgent(DateTime? expiresAt) {
    if (expiresAt == null) return false;
    final remaining = expiresAt.difference(DateTime.now());
    return remaining.inHours <= 48 && remaining.inSeconds > 0;
  }
}
