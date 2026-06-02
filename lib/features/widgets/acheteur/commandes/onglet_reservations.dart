import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../models/reservation.dart';
import '../../../../services/providers.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../communs/chargement.dart';
import '../../communs/vue_erreur.dart';
import 'carte_reservation_acheteur.dart';
import 'etat_vide_reservations_acheteur.dart';

// ─── Provider ────────────────────────────────────────────────────────

/// Mes précommandes (réservations sur prévisions, avec acompte versé).
/// Endpoint : `GET /marketplace/reservations/my`.
final ongletReservationsProvider =
    FutureProvider.autoDispose<List<Reservation>>((ref) async {
  return ref.read(marketplaceServiceProvider).listMyReservations();
});

/// Contenu de l'onglet « Réservations » de la page Mes commandes acheteur.
///
/// Affiche les précommandes versées sur des prévisions de récolte (acompte
/// déjà payé, livraison à venir). Aligné sur la maquette `Mes réservations`
/// du profil — l'onglet est donc une copie de cette liste, mais visible
/// directement depuis la page Mes commandes.
class OngletReservations extends ConsumerWidget {
  const OngletReservations({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(ongletReservationsProvider);
    return async.when(
      loading: () => const Padding(
        padding: EdgeInsets.only(top: 48),
        child: Chargement(size: 22),
      ),
      error: (e, _) => Padding(
        padding: const EdgeInsets.all(AppDimens.pagePaddingH),
        child: VueErreur(
          message: 'Impossible de charger les réservations. $e',
          onRetry: () => ref.invalidate(ongletReservationsProvider),
        ),
      ),
      data: (items) {
        if (items.isEmpty) {
          return ListView(
            // ListView pour garder le pull-to-refresh actif sur l'état vide.
            padding: const EdgeInsets.all(AppDimens.pagePaddingH),
            children: const [
              SizedBox(height: 24),
              EtatVideReservationsAcheteur(),
            ],
          );
        }
        return RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () async {
            ref.invalidate(ongletReservationsProvider);
            await ref.read(ongletReservationsProvider.future);
          },
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            itemCount: items.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (_, i) =>
                CarteReservationAcheteur(reservation: items[i]),
          ),
        );
      },
    );
  }
}
