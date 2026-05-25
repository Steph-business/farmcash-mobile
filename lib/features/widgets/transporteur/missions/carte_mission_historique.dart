import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../models/enums.dart';
import '../../../../models/livraison.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';

const Color _kPrimarySoft = Color(0xFFE8F5E9);
const Color _kErrorSoft = Color(0xFFFEE2E2);
const BorderRadius _kBrCard = BorderRadius.all(Radius.circular(12));
final NumberFormat _nf = NumberFormat('#,##0', 'fr_FR');

/// Carte représentant une mission dans l'historique du transporteur :
/// icône (check ou close selon le statut), référence, trajet, date et
/// montant gagné (vert pour livrée, gris pour annulée).
class CarteMissionHistorique extends StatelessWidget {
  const CarteMissionHistorique({
    required this.mission,
    required this.onTap,
    super.key,
  });

  final Livraison mission;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final reference = mission.reference ??
        mission.commandeId.substring(
          0,
          mission.commandeId.length < 8 ? mission.commandeId.length : 8,
        ).toUpperCase();
    final trajet = mission.itineraireLabel ??
        '${mission.pickupAddress ?? '—'} → ${mission.deliveryAddress ?? '—'}';
    final dateRef = mission.deliveredAt ?? mission.createdAt;
    final df = DateFormat('d MMM HH:mm', 'fr_FR');
    final dateLabel = dateRef != null ? df.format(dateRef.toLocal()) : '—';
    final prix = mission.prixFinal ?? mission.prixDevis;
    final livree = mission.status == ShipmentStatus.delivered;
    final gain = prix != null
        ? (livree
            ? '+${_nf.format(prix.round())} F'
            : '${_nf.format(prix.round())} F')
        : '—';
    final couleurGain = livree ? AppColors.primary : AppColors.textSecondary;

    return InkWell(
      onTap: onTap,
      borderRadius: _kBrCard,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: _kBrCard,
          border:
              Border.all(color: AppColors.border, width: AppDimens.borderThin),
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: livree ? _kPrimarySoft : _kErrorSoft,
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: Icon(
                livree ? Icons.check : Icons.close,
                size: 22,
                color: livree ? AppColors.primary : AppColors.error,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Commande #$reference',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.text,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    trajet,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodySmall.copyWith(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    dateLabel,
                    style: AppTextStyles.labelSmall.copyWith(
                      fontSize: 11,
                      color: AppColors.textSubtle,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              gain,
              style: AppTextStyles.titleSmall.copyWith(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: couleurGain,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
