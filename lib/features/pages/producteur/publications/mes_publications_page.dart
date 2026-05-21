import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../models/annonce_vente.dart';
import '../../../../models/prevision.dart';
import '../../../../services/providers.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';
import '../../../state/auth_state.dart';
import '../../../widgets/communs/chargement.dart';
import '../../../widgets/communs/vue_erreur.dart';

// ─── Photos d'illustration (fallback Unsplash) ───────────────────────────

const List<String> _kAnnoncePhotosFallback = [
  'https://images.unsplash.com/photo-1601493700631-2b16ec4b4716?w=400&h=300&fit=crop&auto=format',
  'https://images.unsplash.com/photo-1518977956812-cd3dbadaaf31?w=400&h=300&fit=crop&auto=format',
  'https://images.unsplash.com/photo-1574484284002-952d92456975?w=400&h=300&fit=crop&auto=format',
  'https://images.unsplash.com/photo-1567521464027-f127ff144326?w=400&h=300&fit=crop&auto=format',
  'https://images.unsplash.com/photo-1488459716781-31db52582fe9?w=400&h=300&fit=crop&auto=format',
  'https://images.unsplash.com/photo-1464226184884-fa280b87c399?w=400&h=300&fit=crop&auto=format',
];

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
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const _Header(),
            _Segmented(
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
            Expanded(
              child: _index == 0
                  ? _AnnoncesBody(async: asyncAnnonces)
                  : _PrevisionsBody(async: asyncPrevisions),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Header ──────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppDimens.pagePaddingH,
        AppDimens.space8,
        AppDimens.pagePaddingH,
        AppDimens.space12,
      ),
      child: Row(
        children: [
          InkWell(
            onTap: () => Navigator.of(context).pop(),
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
              'Mes publications',
              style: AppTextStyles.titleSmall.copyWith(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Segmented control 2 segments ────────────────────────────────────────

class _Segmented extends StatelessWidget {
  const _Segmented({
    required this.index,
    required this.annoncesCount,
    required this.previsionsCount,
    required this.onChanged,
  });

  final int index;
  final int annoncesCount;
  final int previsionsCount;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppDimens.pagePaddingH,
        0,
        AppDimens.pagePaddingH,
        AppDimens.space16,
      ),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: AppColors.surfaceSoft,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.border,
            width: AppDimens.borderThin,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: _Seg(
                label: 'Annonces actives ($annoncesCount)',
                active: index == 0,
                onTap: () => onChanged(0),
              ),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: _Seg(
                label: 'Prévisions ($previsionsCount)',
                active: index == 1,
                onTap: () => onChanged(1),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Seg extends StatelessWidget {
  const _Seg({
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(9),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 8),
        decoration: BoxDecoration(
          color: active ? AppColors.surface : Colors.transparent,
          borderRadius: BorderRadius.circular(9),
          border: active
              ? Border.all(
                  color: AppColors.border,
                  width: AppDimens.borderThin,
                )
              : null,
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: AppTextStyles.labelMedium.copyWith(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: active ? AppColors.text : AppColors.textSecondary,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}

// ─── Body : Annonces (depuis l'API) ──────────────────────────────────────

class _AnnoncesBody extends ConsumerWidget {
  const _AnnoncesBody({required this.async});

  final AsyncValue<List<AnnonceVente>> async;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return async.when(
      loading: () => const Padding(
        padding: EdgeInsets.only(top: AppDimens.space32),
        child: Chargement(size: 22),
      ),
      error: (e, _) => Padding(
        padding: const EdgeInsets.all(AppDimens.pagePaddingH),
        child: VueErreur(
          message: 'Impossible de charger tes annonces.',
          onRetry: () => ref.invalidate(_mesAnnoncesProvider),
        ),
      ),
      data: (annonces) {
        if (annonces.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(AppDimens.pagePaddingH),
            child: Center(
              child: Text(
                'Aucune annonce active pour l\'instant.',
                style: AppTextStyles.bodySmall,
                textAlign: TextAlign.center,
              ),
            ),
          );
        }
        return GridView.builder(
          padding: const EdgeInsets.fromLTRB(
            AppDimens.pagePaddingH,
            0,
            AppDimens.pagePaddingH,
            AppDimens.space16,
          ),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.74,
          ),
          itemCount: annonces.length,
          itemBuilder: (_, i) => _AnnonceCard(
            annonce: annonces[i],
            photoFallback:
                _kAnnoncePhotosFallback[i % _kAnnoncePhotosFallback.length],
          ),
        );
      },
    );
  }
}

class _AnnonceCard extends StatelessWidget {
  const _AnnonceCard({required this.annonce, required this.photoFallback});

  final AnnonceVente annonce;
  final String photoFallback;

  @override
  Widget build(BuildContext context) {
    final photoUrl = annonce.photos.isNotEmpty
        ? annonce.photos.first
        : photoFallback;
    final qte = NumberFormat('#,##0', 'fr_FR').format(annonce.quantiteKg);
    final prix = NumberFormat('#,##0', 'fr_FR').format(annonce.prixParKg);

    return InkWell(
      onTap: () => context.push('/producteur/annonces/${annonce.id}'),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: AppColors.border,
            width: AppDimens.borderThin,
          ),
        ),
        clipBehavior: Clip.hardEdge,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 110,
              width: double.infinity,
              child: CachedNetworkImage(
                imageUrl: photoUrl,
                fit: BoxFit.cover,
                placeholder: (_, _) => Container(color: AppColors.surfaceSoft),
                errorWidget: (_, _, _) =>
                    Container(color: AppColors.surfaceSoft),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    annonce.titre,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$qte kg dispo',
                    style: AppTextStyles.bodySmall.copyWith(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '$prix F/kg',
                    style: AppTextStyles.titleLarge.copyWith(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                      letterSpacing: -0.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '👁 ${annonce.viewsCount} vues · 0 msg',
                    style: AppTextStyles.labelSmall.copyWith(
                      fontSize: 10,
                      color: AppColors.textSubtle,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Body : Prévisions (depuis l'API) ────────────────────────────────────

class _PrevisionsBody extends ConsumerWidget {
  const _PrevisionsBody({required this.async});

  final AsyncValue<List<Prevision>> async;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return async.when(
      loading: () => const Padding(
        padding: EdgeInsets.only(top: AppDimens.space32),
        child: Chargement(size: 22),
      ),
      error: (_, _) => Padding(
        padding: const EdgeInsets.all(AppDimens.pagePaddingH),
        child: VueErreur(
          message: 'Impossible de charger tes prévisions.',
          onRetry: () => ref.invalidate(_mesPrevisionsProvider),
        ),
      ),
      data: (previsions) {
        if (previsions.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(AppDimens.pagePaddingH),
            child: Center(
              child: Text(
                'Aucune prévision pour l\'instant.',
                style: AppTextStyles.bodySmall,
                textAlign: TextAlign.center,
              ),
            ),
          );
        }
        return GridView.builder(
          padding: const EdgeInsets.fromLTRB(
            AppDimens.pagePaddingH,
            0,
            AppDimens.pagePaddingH,
            AppDimens.space16,
          ),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.74,
          ),
          itemCount: previsions.length,
          itemBuilder: (_, i) => _PrevisionCard(
            prevision: previsions[i],
            photoFallback:
                _kAnnoncePhotosFallback[i % _kAnnoncePhotosFallback.length],
          ),
        );
      },
    );
  }
}

class _PrevisionCard extends StatelessWidget {
  const _PrevisionCard({
    required this.prevision,
    required this.photoFallback,
  });

  final Prevision prevision;
  final String photoFallback;

  @override
  Widget build(BuildContext context) {
    final qte = NumberFormat('#,##0', 'fr_FR').format(prevision.quantitePrevKg);
    final date = prevision.dateRecoltePrev != null
        ? DateFormat('d MMM', 'fr_FR').format(prevision.dateRecoltePrev!)
        : null;
    final prixCible = prevision.prixCibleKg;

    return InkWell(
      onTap: () => context.push('/producteur/previsions/${prevision.id}'),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: AppColors.border,
            width: AppDimens.borderThin,
          ),
        ),
        clipBehavior: Clip.hardEdge,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 110,
              width: double.infinity,
              child: CachedNetworkImage(
                imageUrl: photoFallback,
                fit: BoxFit.cover,
                placeholder: (_, _) => Container(color: AppColors.surfaceSoft),
                errorWidget: (_, _, _) =>
                    Container(color: AppColors.surfaceSoft),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Récolte prévue',
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    date != null
                        ? '$qte kg prévus · $date'
                        : '$qte kg prévus',
                    style: AppTextStyles.bodySmall.copyWith(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    prixCible != null && prixCible > 0
                        ? '${NumberFormat('#,##0', 'fr_FR').format(prixCible)} F/kg'
                        : 'Prix à définir',
                    style: AppTextStyles.titleLarge.copyWith(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                      letterSpacing: -0.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Statut : ${_statusLabel(prevision)}',
                    style: AppTextStyles.labelSmall.copyWith(
                      fontSize: 10,
                      color: AppColors.textSubtle,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _statusLabel(Prevision p) {
    switch (p.status.apiValue) {
      case 'OPEN':
        return 'Ouverte';
      case 'CONVERTED':
        return 'Convertie';
      case 'EXPIRED':
        return 'Expirée';
      case 'CANCELLED':
        return 'Annulée';
      default:
        return p.status.apiValue;
    }
  }
}

