import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/reservation.dart';
import '../../../services/providers.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_dimens.dart';
import '../../widgets/acheteur/commandes/carte_reservation_acheteur.dart';
import '../../widgets/acheteur/commandes/etat_vide_reservations_acheteur.dart';
import '../../widgets/communs/chargement.dart';
import '../../widgets/communs/entete_page_standard.dart';
import '../../widgets/communs/vue_erreur.dart';

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
            const EntetePageStandard(titre: 'Mes réservations'),
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
                          children: const [
                            SizedBox(height: 24),
                            EtatVideReservationsAcheteur(),
                          ],
                        )
                      : ListView.separated(
                          padding:
                              const EdgeInsets.fromLTRB(20, 16, 20, 24),
                          itemCount: items.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(height: 12),
                          itemBuilder: (_, i) =>
                              CarteReservationAcheteur(reservation: items[i]),
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
