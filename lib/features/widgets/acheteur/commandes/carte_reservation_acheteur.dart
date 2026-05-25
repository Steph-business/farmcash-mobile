import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../models/reservation.dart';
import '../../../../routing/route_names.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';

const Color _kPrimarySoft = Color(0xFFE8F5E9);
final NumberFormat _nf = NumberFormat('#,##0', 'fr_FR');

/// Carte d'une réservation de prévision dans la liste acheteur.
class CarteReservationAcheteur extends StatelessWidget {
  const CarteReservationAcheteur({required this.reservation, super.key});
  final Reservation reservation;

  @override
  Widget build(BuildContext context) {
    final dateLabel = reservation.createdAt != null
        ? DateFormat('d MMM yyyy', 'fr_FR').format(reservation.createdAt!)
        : null;
    return InkWell(
      onTap: () => context.push(
        RouteNames.acheteurPrevisionDetailPathFor(reservation.previsionId),
      ),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.border,
            width: AppDimens.borderThin,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: _kPrimarySoft,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.event_available_outlined,
                    size: 18,
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
                        '${_nf.format(reservation.quantiteKg.round())} kg réservés',
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Acompte ${_nf.format(reservation.depositAmount.round())} F',
                        style: AppTextStyles.labelSmall.copyWith(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      if (dateLabel != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          'Réservé le $dateLabel',
                          style: AppTextStyles.labelSmall.copyWith(
                            fontSize: 11,
                            color: AppColors.textSubtle,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                _PuceStatutReservation(status: reservation.status),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PuceStatutReservation extends StatelessWidget {
  const _PuceStatutReservation({required this.status});
  final String status;

  @override
  Widget build(BuildContext context) {
    final upper = status.toUpperCase();
    final Color bg;
    final Color fg;
    switch (upper) {
      case 'PAID':
      case 'CONFIRMED':
      case 'DELIVERED':
        bg = _kPrimarySoft;
        fg = AppColors.primary;
        break;
      case 'CANCELLED':
      case 'CANCELED':
        bg = const Color(0xFFFEE2E2);
        fg = AppColors.error;
        break;
      case 'PENDING':
      default:
        bg = const Color(0xFFFEF3C7);
        fg = const Color(0xFFB45309);
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        upper,
        style: AppTextStyles.labelSmall.copyWith(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: fg,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}
