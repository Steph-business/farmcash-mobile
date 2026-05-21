import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../models/annonce_vente.dart';
import '../../../routing/route_names.dart';
import '../../../services/providers.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_dimens.dart';
import '../../../theme/app_text_styles.dart';
import '../../widgets/communs/chargement.dart';
import '../../widgets/communs/snackbars.dart';
import '../../widgets/communs/vue_erreur.dart';

// ─── Provider ───────────────────────────────────────────────────────────

final _favorisAcheteurProvider =
    FutureProvider.autoDispose<List<AnnonceVente>>((ref) {
  return ref.watch(marketplaceServiceProvider).listFavoris();
});

/// Page Favoris acheteur — liste des annonces sauvegardées par l'utilisateur.
///
/// Accessible depuis le profil acheteur (« Mes favoris »).
class FavorisAcheteurPage extends ConsumerWidget {
  const FavorisAcheteurPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncFavoris = ref.watch(_favorisAcheteurProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const _Header(),
            Expanded(
              child: asyncFavoris.when(
                loading: () => const Padding(
                  padding: EdgeInsets.only(top: 48),
                  child: Chargement(size: 22),
                ),
                error: (err, _) => Padding(
                  padding: const EdgeInsets.all(AppDimens.pagePaddingH),
                  child: VueErreur(
                    message: 'Impossible de charger les favoris. $err',
                    onRetry: () =>
                        ref.invalidate(_favorisAcheteurProvider),
                  ),
                ),
                data: (favoris) {
                  if (favoris.isEmpty) {
                    return const _EmptyState();
                  }
                  return RefreshIndicator(
                    onRefresh: () async {
                      ref.invalidate(_favorisAcheteurProvider);
                      await ref.read(_favorisAcheteurProvider.future);
                    },
                    color: AppColors.primary,
                    child: ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding:
                          const EdgeInsets.fromLTRB(20, 16, 20, 24),
                      itemCount: favoris.length,
                      itemBuilder: (context, i) {
                        final a = favoris[i];
                        return _FavoriTile(
                          annonce: a,
                          onTap: () => context.push(
                            RouteNames.acheteurAnnonceDetailPathFor(a.id),
                          ),
                          onRetirer: () async {
                            try {
                              await ref
                                  .read(marketplaceServiceProvider)
                                  .toggleFavori(annonceId: a.id);
                              if (!context.mounted) return;
                              Snackbars.showInfo(
                                context,
                                'Retiré des favoris',
                              );
                              ref.invalidate(_favorisAcheteurProvider);
                            } catch (_) {
                              if (!context.mounted) return;
                              Snackbars.showErreur(
                                context,
                                'Impossible de retirer ce favori',
                              );
                            }
                          },
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Header (back + titre) ──────────────────────────────────────────────

class _Header extends StatelessWidget {
  const _Header();

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
            onTap: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go(RouteNames.acheteurProfilPath);
              }
            },
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
              'Mes favoris',
              style: AppTextStyles.titleSmall.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 40, height: 40),
        ],
      ),
    );
  }
}

// ─── Tile annonce favorite ──────────────────────────────────────────────

class _FavoriTile extends StatelessWidget {
  const _FavoriTile({
    required this.annonce,
    required this.onTap,
    required this.onRetirer,
  });

  final AnnonceVente annonce;
  final VoidCallback onTap;
  final VoidCallback onRetirer;

  @override
  Widget build(BuildContext context) {
    final photoUrl =
        annonce.photos.isNotEmpty ? annonce.photos.first : '';
    final prixTxt = '${annonce.prixParKg.toStringAsFixed(0)} F/kg';
    final qteTxt = '${annonce.quantiteKg.toStringAsFixed(0)} kg disponibles';
    final vendeur = annonce.vendeurNom ?? 'Vendeur';
    final loc = annonce.localisationLabel;
    final sousTitre = loc != null ? '$vendeur · $loc' : vendeur;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.border,
            width: AppDimens.borderThin,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: SizedBox(
                width: 72,
                height: 72,
                child: photoUrl.isEmpty
                    ? Container(color: AppColors.surfaceSoft)
                    : CachedNetworkImage(
                        imageUrl: photoUrl,
                        fit: BoxFit.cover,
                        placeholder: (_, _) =>
                            Container(color: AppColors.surfaceSoft),
                        errorWidget: (_, _, _) =>
                            Container(color: AppColors.surfaceSoft),
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
                    annonce.produitLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.text,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    sousTitre,
                    style: AppTextStyles.bodySmall.copyWith(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    qteTxt,
                    style: AppTextStyles.bodySmall.copyWith(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    prixTxt,
                    style: AppTextStyles.titleSmall.copyWith(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 4),
            InkWell(
              onTap: onRetirer,
              borderRadius: BorderRadius.circular(20),
              child: const Padding(
                padding: EdgeInsets.all(6),
                child: Icon(
                  Icons.favorite,
                  size: 20,
                  color: AppColors.error,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Empty state ────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimens.space24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.favorite_border,
              size: 40,
              color: AppColors.textSubtle.withValues(alpha: 0.9),
            ),
            const SizedBox(height: AppDimens.space12),
            Text(
              'Aucun favori pour le moment',
              style: AppTextStyles.titleSmall,
            ),
            const SizedBox(height: AppDimens.space8),
            Text(
              'Ajoute des annonces à tes favoris\ndepuis la page produit.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySmall.copyWith(
                fontSize: 12,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
