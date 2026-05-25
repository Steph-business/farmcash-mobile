import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../models/coop_collection.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';

const Color _kPrimarySoft = Color(0xFFE8F5E9);
const BorderRadius _kBrCard = BorderRadius.all(Radius.circular(12));
final _nf = NumberFormat('#,##0', 'fr_FR');

/// Ligne d'une collecte planifiee ou en cours : icone primaire, nom du
/// membre, date prevue + quantite, adresse de pickup et badge de statut
/// "En cours" ou "Planifiee". Tap declenche `onAction`.
class LigneCollecte extends StatelessWidget {
  const LigneCollecte({
    required this.collection,
    required this.onAction,
    super.key,
  });

  final CoopCollection collection;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    final farmerNom = collection.farmerNom ?? 'Membre';
    final df = DateFormat('d MMM HH:mm', 'fr_FR');
    final dateLabel = collection.scheduledAt != null
        ? df.format(collection.scheduledAt!.toLocal())
        : '—';
    final qte = '${_nf.format(collection.quantitePrevueKg.round())} kg';
    final inProgress = collection.status == 'IN_PROGRESS';
    return InkWell(
      onTap: onAction,
      borderRadius: _kBrCard,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: _kBrCard,
          border: Border.all(
            color: AppColors.border,
            width: AppDimens.borderThin,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: _kPrimarySoft,
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.agriculture_outlined,
                color: AppColors.primary,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    farmerNom,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '$dateLabel · $qte',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodySmall.copyWith(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  if (collection.pickupAddress.isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Text(
                      collection.pickupAddress,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.labelSmall.copyWith(
                        fontSize: 11,
                        color: AppColors.textSubtle,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: inProgress ? _kPrimarySoft : AppColors.surfaceSoft,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                inProgress ? 'En cours' : 'Planifiée',
                style: AppTextStyles.labelSmall.copyWith(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color:
                      inProgress ? AppColors.primary : AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
