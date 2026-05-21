import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../models/reservation.dart';
import '../../../routing/route_names.dart';
import '../../../services/providers.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_dimens.dart';
import '../../../theme/app_text_styles.dart';
import '../../widgets/communs/chargement.dart';
import '../../widgets/communs/vue_erreur.dart';

const Color _kPrimarySoft = Color(0xFFE8F5E9);

final _reservationsProvider =
    FutureProvider.autoDispose<List<Reservation>>((ref) async {
  return ref.read(marketplaceServiceProvider).listMyReservations();
});

/// Liste des réservations de prévisions de l'acheteur.
///
/// Endpoint : `GET /marketplace/reservations/my`.
class MesReservationsAcheteurPage extends ConsumerWidget {
  const MesReservationsAcheteurPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(_reservationsProvider);
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const _Header(title: 'Mes réservations'),
            Expanded(
              child: async.when(
                loading: () => const Padding(
                  padding: EdgeInsets.only(top: AppDimens.space32),
                  child: Chargement(size: 22),
                ),
                error: (e, _) => Padding(
                  padding: const EdgeInsets.all(AppDimens.pagePaddingH),
                  child: VueErreur(
                    message: 'Impossible de charger les réservations. $e',
                    onRetry: () => ref.invalidate(_reservationsProvider),
                  ),
                ),
                data: (items) => RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: () async {
                    ref.invalidate(_reservationsProvider);
                    await ref.read(_reservationsProvider.future);
                  },
                  child: items.isEmpty
                      ? ListView(
                          padding: const EdgeInsets.all(AppDimens.pagePaddingH),
                          children: [const SizedBox(height: 24), _empty(context)],
                        )
                      : ListView.separated(
                          padding:
                              const EdgeInsets.fromLTRB(20, 16, 20, 24),
                          itemCount: items.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(height: 12),
                          itemBuilder: (_, i) =>
                              _ReservationCard(reservation: items[i]),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _empty(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimens.pagePaddingH),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.event_available_outlined,
              size: 48,
              color: AppColors.textSubtle.withValues(alpha: 0.85),
            ),
            const SizedBox(height: AppDimens.space12),
            Text(
              'Aucune réservation en cours',
              style: AppTextStyles.titleSmall,
            ),
            const SizedBox(height: AppDimens.space8),
            Text(
              'Réserve une part sur une prévision de récolte\ndepuis l\'onglet « Marché » → « Prévisions à venir ».',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: AppDimens.space24),
            InkWell(
              onTap: () => context.go(RouteNames.acheteurMarchePath),
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'Voir les prévisions',
                  style: AppTextStyles.button.copyWith(
                    fontSize: 13,
                    color: AppColors.onPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReservationCard extends StatelessWidget {
  const _ReservationCard({required this.reservation});
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
                _StatusChip(status: reservation.status),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});
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

class _Header extends StatelessWidget {
  const _Header({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 8, 16, 12),
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(
          bottom: BorderSide(
            color: AppColors.border,
            width: AppDimens.borderThin,
          ),
        ),
      ),
      child: Row(
        children: [
          InkWell(
            onTap: () => Navigator.of(context).maybePop(),
            borderRadius: BorderRadius.circular(20),
            child: const SizedBox(
              width: 40,
              height: 40,
              child: Icon(
                Icons.arrow_back_ios_new,
                size: 20,
                color: AppColors.text,
              ),
            ),
          ),
          Expanded(
            child: Text(
              title,
              style: AppTextStyles.titleSmall.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

final _nf = NumberFormat('#,##0', 'fr_FR');
