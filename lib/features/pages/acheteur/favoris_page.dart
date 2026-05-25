import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../models/annonce_vente.dart';
import '../../../routing/route_names.dart';
import '../../../services/providers.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_dimens.dart';
import '../../widgets/acheteur/profil/etat_vide_favoris.dart';
import '../../widgets/acheteur/profil/header_favoris_acheteur.dart';
import '../../widgets/acheteur/profil/tuile_favori_annonce.dart';
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
            const HeaderFavorisAcheteur(),
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
                    return const EtatVideFavoris();
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
                        return TuileFavoriAnnonce(
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
