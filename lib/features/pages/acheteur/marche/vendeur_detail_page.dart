import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../models/annonce_vente.dart';
import '../../../../routing/route_names.dart';
import '../../../../services/providers.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../widgets/acheteur/marche/cta_message_vendeur.dart';
import '../../../widgets/acheteur/marche/etat_vide_vendeur.dart';
import '../../../widgets/acheteur/marche/header_vendeur_detail.dart';
import '../../../widgets/acheteur/marche/hero_card_vendeur.dart';
import '../../../widgets/acheteur/marche/liste_annonces_vendeur.dart';
import '../../../widgets/acheteur/marche/stats_row_vendeur.dart';
import '../../../widgets/acheteur/marche/titre_section_vendeur.dart';
import '../../../widgets/communs/chargement.dart';
import '../../../widgets/communs/snackbars.dart';
import '../../../widgets/communs/vue_erreur.dart';

final _annoncesVendeurProvider = FutureProvider.autoDispose
    .family<List<AnnonceVente>, String>((ref, farmerId) async {
  final result = await ref
      .read(marketplaceServiceProvider)
      .listAnnoncesVente(farmerId: farmerId, limit: 50);
  return result.data;
});

/// Profil public d'un vendeur (producteur ou coop) — vue acheteur.
///
/// Branche sur `listAnnoncesVente(farmerId:)` : on filtre les annonces du
/// farmer, et on extrait son nom public depuis la première annonce (le
/// backend joint `users: { full_name, rating, photo_url }`).
///
/// Conforme à la règle 3b chantier 3 : les coordonnées personnelles
/// (téléphone, vraie identité) ne sont JAMAIS affichées. Seul le nom
/// public + le bouton "Message" sont exposés.
class VendeurDetailPage extends ConsumerWidget {
  const VendeurDetailPage({super.key, required this.farmerId});

  final String farmerId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(_annoncesVendeurProvider(farmerId));
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const HeaderVendeurDetail(),
            Expanded(
              child: async.when(
                loading: () => const Padding(
                  padding: EdgeInsets.only(top: AppDimens.space32),
                  child: Chargement(size: 22),
                ),
                error: (e, _) => Padding(
                  padding: const EdgeInsets.all(AppDimens.pagePaddingH),
                  child: VueErreur(
                    message: 'Impossible de charger le profil vendeur. $e',
                    onRetry: () => ref
                        .invalidate(_annoncesVendeurProvider(farmerId)),
                  ),
                ),
                data: (annonces) => _buildBody(context, annonces),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, List<AnnonceVente> annonces) {
    if (annonces.isEmpty) {
      return const EtatVideVendeur();
    }

    final premiere = annonces.first;
    final vendeur = premiere.vendeur;
    final suffixLen = farmerId.length < 4 ? farmerId.length : 4;
    final nomPublic = vendeur?.fullName?.trim().isNotEmpty == true
        ? vendeur!.fullName!.trim()
        : 'Vendeur ${farmerId.substring(farmerId.length - suffixLen)}';
    final ville = premiere.localisationLabel ?? '';
    final rating = vendeur?.rating;
    final photo = vendeur?.photoUrl;

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppDimens.pagePaddingH,
        0,
        AppDimens.pagePaddingH,
        AppDimens.space24,
      ),
      children: [
        HeroCardVendeur(
          nom: nomPublic,
          ville: ville,
          photoUrl: photo,
          verifie: false,
        ),
        AppDimens.vGap16,
        StatsRowVendeur(
          note: rating != null && rating > 0
              ? rating.toStringAsFixed(1)
              : '—',
          annoncesActives: annonces.length.toString(),
        ),
        AppDimens.vGap24,
        const TitreSectionVendeur('Annonces actives'),
        AppDimens.vGap12,
        ListeAnnoncesVendeur(
          items: annonces,
          onTap: (a) =>
              context.push(RouteNames.acheteurAnnonceDetailPathFor(a.id)),
        ),
        AppDimens.vGap24,
        CtaMessageVendeur(
          onTap: () =>
              Snackbars.showInfo(context, 'Envoyer un message — à venir'),
        ),
      ],
    );
  }
}
