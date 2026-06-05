import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../models/prevision.dart';
import '../../../../models/produit.dart';
import '../../../../models/reservation_acheteur_info.dart';
import '../../../../routing/route_names.dart';
import '../../../../services/providers.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_text_styles.dart';
import '../../communs/chargement.dart';
import '../../communs/vue_erreur.dart';
import '../demandes/demande_achat_modeles.dart' show thumbForProduit;

final NumberFormat _nf = NumberFormat('#,##0', 'fr_FR');

/// Item enrichi : réservation + nom + thumb du produit lié à la prévision.
class ReservationRecueItem {
  const ReservationRecueItem({
    required this.reservation,
    required this.produitNom,
    required this.produitThumb,
  });
  final ReservationAcheteurInfo reservation;
  final String produitNom;
  final String produitThumb;
}

/// Provider partagé : agrège toutes les réservations faites par les
/// acheteurs sur les prévisions du producteur connecté. Utilisé par
/// la page autonome `MesReservationsRecuesPage` ET par l'onglet
/// « Réservations reçues » de la page commandes producteur — un seul
/// fetch parallèle partagé tant que le provider est en cache.
final reservationsRecuesProducteurProvider =
    FutureProvider.autoDispose<List<ReservationRecueItem>>((ref) async {
  final svc = ref.read(marketplaceServiceProvider);

  // 1. En parallèle : mes prévisions + catalogue produits.
  final results = await Future.wait<dynamic>([
    svc.listPrevisions(),
    svc.listProduits().catchError((_) => <Produit>[]),
  ]);
  final previsions = results[0] as List<Prevision>;
  final produits = results[1] as List<Produit>;
  final produitsMap = {for (final p in produits) p.id: p};

  if (previsions.isEmpty) return const <ReservationRecueItem>[];

  // 2. En parallèle : réservations par prévision (tolérant aux échecs).
  final reservationsLists = await Future.wait(
    previsions.map(
      (p) => svc
          .listReservationsParPrevision(p.id)
          .then<List<ReservationAcheteurInfo>>((v) => v)
          .catchError(
            (Object _) => const <ReservationAcheteurInfo>[],
          ),
    ),
  );

  // 3. Aplatir + enrichir avec nom/thumb produit.
  final items = <ReservationRecueItem>[];
  for (var i = 0; i < previsions.length; i++) {
    final p = previsions[i];
    final produitNom = produitsMap[p.produitId]?.nom ?? 'Produit';
    for (final r in reservationsLists[i]) {
      items.add(ReservationRecueItem(
        reservation: r,
        produitNom: produitNom,
        produitThumb: thumbForProduit(produitNom),
      ));
    }
  }

  // 4. Tri par date desc (les plus récentes en premier).
  items.sort((a, b) {
    final aDt = a.reservation.createdAt ?? DateTime(1970);
    final bDt = b.reservation.createdAt ?? DateTime(1970);
    return bDt.compareTo(aDt);
  });
  return items;
});

/// Corps réutilisable « Réservations reçues » — pas de Scaffold, pas
/// de header de page. Juste : loading / error / empty / list. Peut
/// vivre dans une page autonome ou un onglet.
class ContenuReservationsRecues extends ConsumerWidget {
  const ContenuReservationsRecues({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(reservationsRecuesProducteurProvider);
    return async.when(
      loading: () => const Padding(
        padding: EdgeInsets.only(top: 48),
        child: Chargement(size: 22),
      ),
      error: (e, _) => Padding(
        padding: const EdgeInsets.all(20),
        child: VueErreur(
          message: 'Impossible de charger les réservations. $e',
          onRetry: () => ref.invalidate(reservationsRecuesProducteurProvider),
        ),
      ),
      data: (items) => RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () async {
          ref.invalidate(reservationsRecuesProducteurProvider);
          await ref.read(reservationsRecuesProducteurProvider.future);
        },
        child: items.isEmpty
            ? ListView(
                padding: const EdgeInsets.all(20),
                children: const [
                  SizedBox(height: 24),
                  EtatVideReservationsRecues(),
                ],
              )
            : ListView.separated(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                itemCount: items.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (_, i) =>
                    CarteReservationRecue(item: items[i]),
              ),
      ),
    );
  }
}

// ─── Carte d'une réservation reçue ────────────────────────────────

class CarteReservationRecue extends StatelessWidget {
  const CarteReservationRecue({super.key, required this.item});
  final ReservationRecueItem item;

  @override
  Widget build(BuildContext context) {
    final r = item.reservation;
    final nom = (r.acheteurNom?.trim().isNotEmpty ?? false)
        ? r.acheteurNom!.trim()
        : 'Acheteur';
    final qte = _nf.format(r.quantiteKg.round());
    final dateLabel = r.createdAt != null
        ? DateFormat('d MMM yyyy', 'fr_FR').format(r.createdAt!)
        : '—';
    final (badgeBg, badgeColor, badgeText) = _badgeStatus(r.status);

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: () => context.push(
          RouteNames.producteurPrevisionDetailPathFor(r.previsionId),
        ),
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      width: 52,
                      height: 52,
                      color: AppColors.surfaceSoft,
                      child: Image.network(
                        item.produitThumb,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => const Icon(
                          Icons.image_outlined,
                          size: 22,
                          color: AppColors.textSubtle,
                        ),
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
                          '$qte kg de ${item.produitNom}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontFamily: 'Poppins',
                            fontSize: 14.5,
                            fontWeight: FontWeight.w800,
                            color: AppColors.text,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(
                              Icons.person_outline,
                              size: 13,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                nom,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyles.bodySmall.copyWith(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: badgeBg,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      badgeText,
                      style: AppTextStyles.labelSmall.copyWith(
                        fontFamily: 'Poppins',
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        color: badgeColor,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(
                    Icons.event_outlined,
                    size: 13,
                    color: AppColors.textSubtle,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Réservé le $dateLabel',
                    style: AppTextStyles.labelSmall.copyWith(
                      fontSize: 11.5,
                      color: AppColors.textSubtle,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'Voir la prévision',
                    style: AppTextStyles.button.copyWith(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 2),
                  const Icon(
                    Icons.chevron_right_rounded,
                    size: 18,
                    color: AppColors.primary,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── État vide ─────────────────────────────────────────────────────

class EtatVideReservationsRecues extends StatelessWidget {
  const EtatVideReservationsRecues({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.hourglass_empty_rounded,
                size: 32,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'Aucune réservation pour l\'instant',
              style: AppTextStyles.titleSmall.copyWith(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.text,
              ),
            ),
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                'Les acheteurs qui réservent une part de tes futures '
                'récoltes apparaîtront ici.',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodySmall.copyWith(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

(Color, Color, String) _badgeStatus(String status) {
  switch (status.toUpperCase()) {
    case 'CONFIRMED':
      return (
        AppColors.primary.withValues(alpha: 0.12),
        AppColors.primary,
        'CONFIRMÉE',
      );
    case 'CANCELLED':
    case 'CANCELED':
      return (
        AppColors.error.withValues(alpha: 0.12),
        AppColors.error,
        'ANNULÉE',
      );
    case 'PENDING':
    default:
      return (
        const Color(0xFFB45309).withValues(alpha: 0.12),
        const Color(0xFFB45309),
        'EN ATTENTE',
      );
  }
}
