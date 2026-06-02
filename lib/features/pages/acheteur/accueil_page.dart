import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../models/ai_content.dart';
import '../../../models/annonce_achat.dart';
import '../../../models/annonce_vente.dart';
import '../../../models/pagination.dart';
import '../../../models/produit.dart';
import '../../../models/wallet_with_transactions.dart';
import '../../../routing/route_names.dart';
import '../../../services/providers.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_dimens.dart';
import '../../state/auth_state.dart';
import '../../state/badges_state.dart';
import '../../widgets/acheteur/accueil/annonces_grid_acheteur.dart';
import '../../widgets/acheteur/accueil/etat_vide_accueil_acheteur.dart';
import '../../widgets/acheteur/accueil/section_accueil_acheteur.dart';
import '../../widgets/acheteur/accueil/section_tendance.dart';
import '../../widgets/communs/carte_solde_hero.dart';
import '../../widgets/communs/chargement.dart';
import '../../widgets/communs/grille_actions.dart';
import '../../widgets/communs/header_utilisateur.dart';
import '../../widgets/communs/vue_erreur.dart';

/// Données agrégées pour l'accueil acheteur.
class _AccueilData {
  const _AccueilData({
    required this.categories,
    required this.annonces,
    required this.demandes,
    required this.produitsParId,
    required this.insights,
    required this.solde,
  });

  final List<Categorie> categories;
  final List<AnnonceVente> annonces;
  final List<AnnonceAchat> demandes;
  final Map<String, Produit> produitsParId;
  final AiInsights? insights;

  /// Solde wallet FCFA. `null` si chargement échoué (on affiche
  /// « — » plutôt que d'écraser l'accueil).
  final double? solde;
}

/// Provider de chargement combiné (catégories + annonces + demandes + IA).
final _accueilAcheteurDataProvider =
    FutureProvider.autoDispose<_AccueilData>((ref) async {
  final svc = ref.watch(marketplaceServiceProvider);
  final ai = ref.watch(aiServiceProvider);
  final finance = ref.watch(financeServiceProvider);
  final user = ref.watch(currentUserProvider);

  final results = await Future.wait<dynamic>([
    // 0 — catégories
    svc.listCategories().then<Object?>((v) => v).catchError(
          (_) => const <Categorie>[],
        ),
    // 1 — produits
    svc.listProduits().then<Object?>((v) => v).catchError(
          (_) => const <Produit>[],
        ),
    // 2 — annonces de vente
    svc.listAnnoncesVente(limit: 20).then<Object?>((v) => v).catchError(
          (_) => const Paginated<AnnonceVente>(
            data: [],
            total: 0,
            page: 1,
            limit: 0,
            totalPages: 0,
          ),
        ),
    // 3 — annonces d'achat (uniquement si user connecté)
    if (user != null)
      svc.listAnnoncesAchat(limit: 10).then<Object?>((v) => v).catchError(
            (_) => const Paginated<AnnonceAchat>(
              data: [],
              total: 0,
              page: 1,
              limit: 0,
              totalPages: 0,
            ),
          ),
    // 4 — insights IA (tendances)
    ai.getMyInsights().then<Object?>((v) => v).catchError((_) => null),
    // 5 — wallet (solde acheteur affiché en hero)
    if (user != null)
      finance
          .getWallet(limit: 1)
          .then<Object?>((v) => v)
          .catchError((_) => null),
  ]);

  final categories = results[0] as List<Categorie>;
  final produits = results[1] as List<Produit>;
  final annoncesPage = results[2] as Paginated<AnnonceVente>;
  final Paginated<AnnonceAchat> demandesPage = user != null
      ? results[3] as Paginated<AnnonceAchat>
      : const Paginated<AnnonceAchat>(
          data: [],
          total: 0,
          page: 1,
          limit: 0,
          totalPages: 0,
        );
  final insights = user != null ? results[4] as AiInsights? : null;
  // results[5] disponible seulement si user != null (la condition côté
  // futureWait insère/n'insère pas l'élément).
  final wallet = user != null && results.length > 5
      ? results[5] as WalletWithTransactions?
      : null;
  final double? solde = wallet?.wallet.balance;

  final produitsParId = <String, Produit>{
    for (final p in produits) p.id: p,
  };

  // Côté buyer : on filtre les annonces d'achat pour ne garder QUE les siennes.
  final mesDemandes = user == null
      ? const <AnnonceAchat>[]
      : demandesPage.data.where((a) => a.buyerId == user.id).toList();

  return _AccueilData(
    categories: categories,
    annonces: annoncesPage.data,
    demandes: mesDemandes,
    produitsParId: produitsParId,
    insights: insights,
    solde: solde,
  );
});

/// Accueil acheteur — marché + search + filtres + recommandations + IA.
class AccueilPage extends ConsumerStatefulWidget {
  const AccueilPage({super.key});

  @override
  ConsumerState<AccueilPage> createState() => _AccueilPageState();
}

class _AccueilPageState extends ConsumerState<AccueilPage> {
  /// Filtre catégorie courant. `null` = "Tout".
  String? _filtreCategorieNom;

  Future<void> _refresh() async {
    ref.invalidate(_accueilAcheteurDataProvider);
    await ref.read(_accueilAcheteurDataProvider.future);
  }

  // Onglets du shell (Marché, Commandes) → `context.go` pour que le
  // bottom nav suive le changement de branche. Sinon `push` empile au
  // dessus de l'onglet actuel et la barre du bas reste sur Accueil
  // (bug courant des StatefulShellRoute).
  void _onTapRecherche() => context.go(RouteNames.acheteurMarchePath);
  void _onTapVoirTout() => context.go(RouteNames.acheteurMarchePath);
  void _onTapCommandes() => context.go(RouteNames.acheteurCommandesPath);

  /// Ouvre la page autonome « Négociations » (propositions reçues sur
  /// les demandes d'achat publiées). Page dédiée hors shell — c'est un
  /// flux distinct des commandes au sens propre (pas de paiement, pas
  /// de livraison à attendre).
  void _onTapNegociations() =>
      context.push(RouteNames.acheteurNegociationsPath);

  // Pages hors-shell (wallet, demandes, favoris) → `push` reste correct
  // car ce sont des écrans empilés (pas des onglets).
  void _onTapWallet() => context.push(RouteNames.acheteurWalletPath);
  void _onTapPaiements() => context.push(RouteNames.acheteurWalletPath);
  void _onTapMesOffres() =>
      context.push(RouteNames.acheteurDemandesPath);
  void _onTapFavoris() => context.push(RouteNames.acheteurFavorisPath);

  void _onTapAnnonce(AnnonceVente a) {
    context.push(RouteNames.acheteurAnnonceDetailPathFor(a.id));
  }

  /// Liste des 6 actions de la grille accueil (alignée sur la maquette
  /// FarmCash AI). Garde le même ordre pour cohérence cross-session.
  List<ActionRapide> _actions() => [
        ActionRapide(
          icone: Icons.search,
          label: 'Rechercher produits',
          onTap: _onTapRecherche,
        ),
        ActionRapide(
          icone: Icons.receipt_long_outlined,
          label: 'Mes commandes',
          onTap: _onTapCommandes,
        ),
        // Tuile « Négociations » : raccourci direct vers l'onglet
        // Négociations dans Mes commandes (propositions reçues sur les
        // demandes d'achat publiées). Avant 2026-05-27 cet emplacement
        // hébergeait « Vendeurs » qui dupliquait juste l'onglet Marché
        // du bottom nav — on l'a remplacé par un raccourci utile vers
        // un flux moins visible.
        ActionRapide(
          icone: Icons.handshake_outlined,
          label: 'Négociations',
          onTap: _onTapNegociations,
          // Badge dynamique : nombre de propositions reçues encore
          // actionnables (PENDING ou COUNTER_OFFERED). L'utilisateur
          // voit en un coup d'œil qu'il y a une réponse à traiter sans
          // ouvrir la page.
          badge: ref
                  .watch(propositionsRecuesNonTraiteesCountProvider)
                  .valueOrNull ??
              0,
        ),
        ActionRapide(
          icone: Icons.favorite_border,
          label: 'Mes favoris',
          onTap: _onTapFavoris,
        ),
        ActionRapide(
          icone: Icons.credit_card_outlined,
          label: 'Paiements',
          onTap: _onTapPaiements,
        ),
        // Tuile « Mes offres » : pointe vers les demandes d'achat
        // publiées par l'acheteur. Corollaire du « Offres d'achat »
        // côté producteur — l'acheteur voit ses propres demandes et
        // les négociations en cours.
        ActionRapide(
          icone: Icons.shopping_basket_outlined,
          label: 'Mes offres',
          onTap: _onTapMesOffres,
        ),
      ];

  @override
  Widget build(BuildContext context) {
    final asyncData = ref.watch(_accueilAcheteurDataProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const HeaderUtilisateur(variant: HeaderVariant.acheteur),
            Expanded(
              child: asyncData.when(
                loading: () => const Padding(
                  padding: EdgeInsets.only(top: 48),
                  child: Chargement(size: 22),
                ),
                error: (err, _) => Padding(
                  padding: const EdgeInsets.all(AppDimens.pagePaddingH),
                  child: VueErreur(
                    message: 'Impossible de charger le marché. $err',
                    onRetry: _refresh,
                  ),
                ),
                data: _buildContent,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(_AccueilData data) {
    // Empty global (rien à montrer du tout).
    if (data.categories.isEmpty &&
        data.annonces.isEmpty &&
        data.demandes.isEmpty) {
      return EtatVideAccueilAcheteur(onRefresh: _refresh);
    }

    // Filtrage en mémoire selon la catégorie active (utilisé en bas dans
    // « Recommandé pour toi »). La grille d'actions et le solde restent
    // toujours visibles.
    final annoncesFiltrees = _filtreCategorieNom == null
        ? data.annonces
        : data.annonces.where((a) {
            final produit = data.produitsParId[a.produitId];
            if (produit?.sousCategorieId == null) return false;
            for (final cat in data.categories) {
              if (cat.nom != _filtreCategorieNom) continue;
              final match = cat.sousCategories
                  .any((sc) => sc.id == produit!.sousCategorieId);
              if (match) return true;
            }
            return false;
          }).toList();

    final recommandes = annoncesFiltrees.take(4).toList();
    final pres = annoncesFiltrees.length > 4
        ? annoncesFiltrees.skip(4).take(4).toList()
        : annoncesFiltrees.reversed.take(4).toList();

    final tendance = data.insights?.tendances.isNotEmpty == true
        ? data.insights!.tendances.first
        : null;

    return RefreshIndicator(
      onRefresh: _refresh,
      color: AppColors.primary,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          AppDimens.pagePaddingH,
          AppDimens.space12,
          AppDimens.pagePaddingH,
          AppDimens.space16,
        ),
        children: [
          // 1. Carte solde wallet — hero card avec CTA « Mon portefeuille »
          CarteSoldeHero(
            solde: data.solde,
            onOuvrirWallet: _onTapWallet,
          ),
          AppDimens.vGap16,
          // 2. Grille 2×3 d'actions rapides — pattern maquette FarmCash AI
          GrilleActions(actions: _actions()),
          AppDimens.vGap16,
          // 3. Recommandé pour toi (grid 2 col)
          SectionAccueilAcheteur(
            titre: 'Recommandé pour toi',
            onVoirTout: _onTapVoirTout,
            child: recommandes.isEmpty
                ? EtatVideSectionAccueil(
                    message: _filtreCategorieNom == null
                        ? 'Aucune annonce disponible pour le moment.'
                        : 'Aucune annonce dans cette catégorie.',
                  )
                : AnnoncesGridAcheteur(
                    annonces: recommandes,
                    produitsParId: data.produitsParId,
                    onTap: _onTapAnnonce,
                  ),
          ),
          AppDimens.vGap24,
          // 4. Près de chez toi (grid 2 col, masqué si vide)
          if (pres.isNotEmpty) ...[
            SectionAccueilAcheteur(
              titre: 'Près de chez toi',
              onVoirTout: _onTapVoirTout,
              child: AnnoncesGridAcheteur(
                annonces: pres,
                produitsParId: data.produitsParId,
                onTap: _onTapAnnonce,
              ),
            ),
            AppDimens.vGap24,
          ],
          // 5. Tendances du marché (bandeau vert pâle)
          SectionTendance(tendance: tendance),
        ],
      ),
    );
  }
}
