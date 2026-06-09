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
import '../../../theme/app_text_styles.dart';
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

  /// Sous-titre du header acheteur. Si des propositions non traitées
  /// attendent → message d'action ("3 offres à traiter"). Sinon →
  /// salutation neutre. Évite de laisser l'acheteur ouvrir l'app sans
  /// indication sur ce qui mérite son attention.
  String? _construireSousTitreHeader(WidgetRef ref) {
    final propsCount = ref
            .watch(propositionsRecuesNonTraiteesCountProvider)
            .valueOrNull ??
        0;
    if (propsCount > 0) {
      return propsCount == 1
          ? '1 offre à traiter sur tes demandes'
          : '$propsCount offres à traiter sur tes demandes';
    }
    return null; // laisse le défaut de HeaderUtilisateur acheteur
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
            // Sous-titre dynamique : si l'acheteur a des propositions
            // reçues à traiter, on lui dit clairement combien — c'est
            // plus actionnable que "Bienvenue" générique.
            HeaderUtilisateur(
              variant: HeaderVariant.acheteur,
              subtitleOverride: _construireSousTitreHeader(ref),
            ),
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
          // 1.bis Bandeau premium d'alerte « Offres à traiter » — visible
          // SEULEMENT si des propositions non traitées attendent. Pattern
          // type Uber/Stripe : rappel d'action en haut, gradient vif pour
          // capter l'œil immédiatement. Tap → page Négociations.
          if ((ref
                      .watch(propositionsRecuesNonTraiteesCountProvider)
                      .valueOrNull ??
                  0) >
              0) ...[
            AppDimens.vGap12,
            _BandeauOffresATraiter(
              count: ref
                      .watch(propositionsRecuesNonTraiteesCountProvider)
                      .valueOrNull ??
                  0,
              onTap: _onTapNegociations,
            ),
          ],
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
                    icone: Icons.storefront_outlined,
                    message: _filtreCategorieNom == null
                        ? 'Aucune annonce pour l\'instant. Publie une demande pour faire venir les vendeurs.'
                        : 'Aucune annonce dans cette catégorie.',
                    ctaLabel: _filtreCategorieNom == null
                        ? 'Publier ma demande'
                        : 'Voir tout le marché',
                    onCtaTap: () => _filtreCategorieNom == null
                        ? context.push(RouteNames.acheteurDemandePublierPath)
                        : _onTapVoirTout(),
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

/// Bandeau d'alerte premium « X offres à traiter » — affiché en haut de
/// l'accueil acheteur SEULEMENT s'il a des propositions reçues non
/// traitées. Pattern type Uber/Stripe : capte l'œil immédiatement via
/// gradient vert + accent visuel, transforme l'app passive
/// (consultation marché) en app active (réponses aux propositions).
///
/// Tap → page Négociations.
class _BandeauOffresATraiter extends StatelessWidget {
  const _BandeauOffresATraiter({required this.count, required this.onTap});

  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primary,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.primary, AppColors.primaryHover],
            ),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.28),
                blurRadius: 12,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.20),
                  borderRadius: BorderRadius.circular(11),
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.handshake_rounded,
                  size: 22,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      count == 1
                          ? '1 offre à traiter'
                          : '$count offres à traiter',
                      style: AppTextStyles.titleSmall.copyWith(
                        fontFamily: 'Poppins',
                        fontSize: 14.5,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Des vendeurs ont répondu à tes demandes — touche pour voir.',
                      style: AppTextStyles.bodySmall.copyWith(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.92),
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              const Icon(
                Icons.arrow_forward_rounded,
                size: 20,
                color: Colors.white,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
