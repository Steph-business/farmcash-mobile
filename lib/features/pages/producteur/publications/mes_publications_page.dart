import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../models/annonce_vente.dart';
import '../../../../models/prevision.dart';
import '../../../../routing/route_names.dart';
import '../../../../services/providers.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_text_styles.dart';
import '../../../state/auth_state.dart';
import '../../../widgets/producteur/publications/body_annonces_publications.dart';
import '../../../widgets/producteur/publications/body_previsions_publications.dart';
import '../../../widgets/producteur/publications/header_mes_publications.dart';
import '../../../widgets/producteur/publications/segmented_mes_publications.dart';

/// Provider — liste des annonces du farmer connecté (filtrage client-side).
final _mesAnnoncesProvider = FutureProvider.autoDispose<List<AnnonceVente>>(
  (ref) async {
    final svc = ref.watch(marketplaceServiceProvider);
    final user = ref.watch(currentUserProvider);
    final farmerId = user?.id;
    final paginated = await svc.listAnnoncesVente(limit: 50);
    if (farmerId == null) return paginated.data;
    return paginated.data
        .where((a) => a.farmerId == farmerId)
        .toList(growable: false);
  },
);

/// Provider — liste des prévisions du farmer connecté. Le backend filtre
/// déjà côté serveur (par `farmer_id` du JWT) mais on refiltre côté client
/// pour être robuste si l'endpoint élargit son scope.
final _mesPrevisionsProvider = FutureProvider.autoDispose<List<Prevision>>(
  (ref) async {
    final svc = ref.watch(marketplaceServiceProvider);
    final user = ref.watch(currentUserProvider);
    final farmerId = user?.id;
    final list = await svc.listPrevisions();
    if (farmerId == null) return list;
    return list
        .where((p) => p.farmerId == farmerId)
        .toList(growable: false);
  },
);

/// Mes publications producteur — toggle entre Annonces actives et Prévisions.
///
/// La maquette montre un compteur dans chaque onglet (« Annonces actives (5) »
/// et « Prévisions (3) »). On les calcule dynamiquement : annonces depuis
/// l'API, prévisions en mock (l'endpoint actuel ne filtre pas par farmer).
class MesPublicationsPage extends ConsumerStatefulWidget {
  const MesPublicationsPage({super.key});

  @override
  ConsumerState<MesPublicationsPage> createState() =>
      _MesPublicationsPageState();
}

class _MesPublicationsPageState extends ConsumerState<MesPublicationsPage> {
  /// 0 = Annonces actives, 1 = Prévisions.
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final asyncAnnonces = ref.watch(_mesAnnoncesProvider);
    final asyncPrevisions = ref.watch(_mesPrevisionsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      // FAB contextuel : visible uniquement sur l'onglet Prévisions (le
      // chemin de création d'annonce passe par "Publier une annonce" depuis
      // l'accueil → pas besoin de doubler ce CTA ici). Au retour de la page
      // de création, on invalide le provider pour rafraîchir la liste.
      floatingActionButton: _index == 1
          ? FloatingActionButton.extended(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.onPrimary,
              elevation: 0,
              icon: const Icon(Icons.add),
              label: const Text(
                'Nouvelle prévision',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              onPressed: () async {
                final created = await context.push<dynamic>(
                  RouteNames.producteurCreerPrevisionPath,
                );
                if (!context.mounted) return;
                if (created == true) {
                  ref.invalidate(_mesPrevisionsProvider);
                }
              },
            )
          : null,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const HeaderMesPublications(),
            SegmentedMesPublications(
              index: _index,
              annoncesCount: asyncAnnonces.maybeWhen(
                data: (a) => a.length,
                orElse: () => 0,
              ),
              previsionsCount: asyncPrevisions.maybeWhen(
                data: (p) => p.length,
                orElse: () => 0,
              ),
              onChanged: (i) => setState(() => _index = i),
            ),
            // Bandeau accès rapide « Réservations reçues » — visible
            // UNIQUEMENT sur l'onglet Prévisions, c'est là que c'est
            // pertinent (les prévisions reçoivent des réservations).
            if (_index == 1) const _BandeauReservationsRecues(),
            Expanded(
              child: _index == 0
                  ? BodyAnnoncesPublications(
                      async: asyncAnnonces,
                      onRetry: () => ref.invalidate(_mesAnnoncesProvider),
                    )
                  : BodyPrevisionsPublications(
                      async: asyncPrevisions,
                      onRetry: () => ref.invalidate(_mesPrevisionsProvider),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Bandeau d'accès « Réservations reçues » ──────────────────────

/// Bandeau cliquable affiché en haut de l'onglet Prévisions — emmène
/// vers la page agrégée des réservations faites par les acheteurs sur
/// les prévisions du producteur. C'est la seule porte d'entrée pour
/// cette vue (l'accueil et la grille d'actions sont déjà saturés).
class _BandeauReservationsRecues extends StatelessWidget {
  const _BandeauReservationsRecues();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      child: Material(
        color: AppColors.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: () =>
              context.push(RouteNames.producteurReservationsRecuesPath),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.fromLTRB(12, 10, 10, 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.25),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(9),
                  ),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.inbox_outlined,
                    size: 17,
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
                        'Réservations reçues',
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontFamily: 'Poppins',
                          fontSize: 13.5,
                          fontWeight: FontWeight.w800,
                          color: AppColors.text,
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        'Qui a réservé sur tes prévisions ?',
                        style: AppTextStyles.bodySmall.copyWith(
                          fontSize: 11.5,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  size: 22,
                  color: AppColors.primary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
