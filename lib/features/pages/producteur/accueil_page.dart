import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/ai_content.dart';
import '../../../models/annonce_achat.dart';
import '../../../models/annonce_vente.dart';
import '../../../models/cooperative.dart';
import '../../../models/enums.dart';
import '../../../models/negociation.dart';
import '../../../models/portefeuille.dart';
import '../../../models/publication_coop.dart';
import '../../../services/providers.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_dimens.dart';
import '../../state/auth_state.dart';
import '../../widgets/communs/chargement.dart';
import '../../widgets/communs/header_utilisateur.dart';
import '../../widgets/communs/vue_erreur.dart';
import '../../widgets/producteur/accueil/accueil_producteur_data.dart';
import '../../widgets/producteur/accueil/contenu_accueil.dart';

/// Extrait le prénom = premier mot de `fullName`, fallback « toi » si vide.
String _prenomDe(String? fullName) =>
    (fullName ?? '').trim().split(RegExp(r'\s+')).first;

/// Sous-titre header producteur, calé sur ce qui mérite le plus
/// l'attention. Cascade :
///   1. Offres reçues actionnables (PENDING/COUNTER_OFFERED) → priorité
///   2. Annonces actives → métier nominal
///   3. Aucune annonce → invite à publier
///
/// Helper top-level (pas méthode du Widget) pour pouvoir le tester
/// indépendamment et garder le build() lisible.
String? _construireSousTitreProducteur(
    AsyncValue<AccueilProducteurData> async) {
  final data = async.value;
  if (data == null) return null;

  // 1. Candidatures actionnables = action prioritaire
  final candidaturesActives = data.offresIncoming
      .where((c) =>
          c.status == NegotiationStatus.pending ||
          c.status == NegotiationStatus.counterOffered)
      .length;
  if (candidaturesActives > 0) {
    return candidaturesActives == 1
        ? '1 offre à traiter sur tes annonces'
        : '$candidaturesActives offres à traiter sur tes annonces';
  }

  // 2. Annonces actives = métier nominal
  final nbAnnonces = data.annonces.length;
  if (nbAnnonces > 0) {
    return nbAnnonces == 1
        ? '1 annonce active'
        : '$nbAnnonces annonces actives';
  }

  // 3. Rien publié → invite douce
  return 'Publie ta première annonce pour vendre';
}

/// Charge en parallèle les données nécessaires à l'accueil producteur.
///
/// Chaque appel est tolérant : un service en échec retourne `null`/liste
/// vide et les sections concernées sont masquées (graceful degradation).
final accueilDataProducteurProvider =
    FutureProvider.autoDispose<AccueilProducteurData>((ref) async {
  final marketplace = ref.watch(marketplaceServiceProvider);
  final finance = ref.watch(financeServiceProvider);
  final negotiation = ref.watch(negotiationServiceProvider);
  final ai = ref.watch(aiServiceProvider);
  final cooperatives = ref.watch(cooperativesServiceProvider);
  final user = ref.watch(currentUserProvider);
  final coopId = user?.cooperativeId;

  final results = await Future.wait<dynamic>([
    // 0 — wallet
    finance.getWallet().then<Object?>((v) => v).catchError((_) => null),
    // 1 — mes annonces (filtrées côté client par farmerId)
    marketplace
        .listAnnoncesVente(limit: 10)
        .then<Object?>((v) => v)
        .catchError((_) => null),
    // 2 — candidatures incoming
    negotiation
        .listCandidatures(direction: 'incoming')
        .then<Object?>((v) => v)
        .catchError((_) => <Candidature>[]),
    // 3 — insights IA
    ai.getMyInsights().then<Object?>((v) => v).catchError((_) => null),
    // 4 — annonces d'achat (acheteurs qui cherchent)
    marketplace
        .listAnnoncesAchat(limit: 10)
        .then<Object?>((v) => v)
        .catchError((_) => null),
    // 5 — coopérative (si l'utilisateur est membre)
    if (coopId != null)
      cooperatives.getPublic(coopId).then<Object?>((v) => v).catchError((_) => null),
    // 6 — publications coop récentes
    if (coopId != null)
      cooperatives
          .listPublications(cooperativeId: coopId, limit: 3)
          .then<Object?>((v) => v)
          .catchError((_) => null),
  ]);

  final walletBundle = results[0];
  final annoncesRaw = results[1];
  final candidatures = results[2];
  final insights = results[3];
  final acheteursRaw = results[4];
  final coopInfo = coopId != null ? results[5] as Cooperative? : null;
  final coopPublicationsRaw = coopId != null ? results[6] : null;

  // Mes annonces (filtre côté client par farmerId).
  final farmerId = user?.id;
  final List<AnnonceVente> mesAnnonces = [];
  if (annoncesRaw != null && farmerId != null) {
    final data = (annoncesRaw as dynamic).data as List;
    for (final a in data) {
      if (a is AnnonceVente && a.farmerId == farmerId) {
        mesAnnonces.add(a);
      }
    }
  }

  // Acheteurs qui cherchent — filtrage côté client : garder les annonces
  // dont le produitId matche un produit que le farmer cultive (déduit de
  // ses annonces actives). Si aucun match : on garde toutes les annonces.
  final List<AnnonceAchat> acheteurs = [];
  if (acheteursRaw != null) {
    final data = (acheteursRaw as dynamic).data as List;
    final mesProduitIds = mesAnnonces.map((a) => a.produitId).toSet();
    final List<AnnonceAchat> tous = [];
    for (final a in data) {
      if (a is AnnonceAchat) tous.add(a);
    }
    if (mesProduitIds.isEmpty) {
      acheteurs.addAll(tous);
    } else {
      final matchs = tous.where((a) => mesProduitIds.contains(a.produitId)).toList();
      acheteurs.addAll(matchs.isEmpty ? tous : matchs);
    }
  }

  // Publications coop.
  final List<PublicationCoop> coopPubs = [];
  if (coopPublicationsRaw != null) {
    final data = (coopPublicationsRaw as dynamic).data as List;
    for (final p in data) {
      if (p is PublicationCoop) coopPubs.add(p);
    }
  }

  return AccueilProducteurData(
    wallet: walletBundle == null ? null : (walletBundle as dynamic).wallet as Portefeuille,
    annonces: mesAnnonces,
    offresIncoming: (candidatures as List<Candidature>?) ?? const [],
    insights: insights as AiInsights?,
    acheteursQuiCherchent: acheteurs,
    coopInfo: coopInfo,
    coopPublications: coopPubs,
  );
});

/// Compteur de parcelles du farmer — utilisé par le bandeau d'alerte
/// au-dessus du flux principal de l'accueil. Provider dédié pour ne pas
/// polluer le bundle d'accueil et pouvoir être invalidé seul après
/// création d'une parcelle.
final accueilProducteurParcellesCountProvider =
    FutureProvider.autoDispose<int>((ref) async {
  final list = await ref.watch(marketplaceServiceProvider).listParcelles();
  return list.length;
});

/// Accueil producteur — CTA publier, KPIs, à traiter, demandes acheteurs,
/// coopérative, outils IA, mes annonces, conseils du jour.
///
/// Conforme à `mockups/producteur_accueil.html`. Pas de mock data : tous
/// les blocs consomment les services Riverpod (`finance`, `marketplace`,
/// `negotiation`, `ai`, `cooperatives`). Les sections sans donnée se
/// masquent silencieusement (pas de "—" partout).
class AccueilPage extends ConsumerWidget {
  const AccueilPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(accueilDataProducteurProvider);
    final parcellesCount =
        ref.watch(accueilProducteurParcellesCountProvider);
    final user = ref.watch(currentUserProvider);
    final prenom = _prenomDe(user?.fullName);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Sous-titre dynamique : si des candidatures actionnables
            // attendent → message d'action. Sinon défaut neutre.
            HeaderUtilisateur(
              variant: HeaderVariant.producteur,
              subtitleOverride: _construireSousTitreProducteur(async),
            ),
            Expanded(
              child: async.when(
                loading: () => const Padding(
                  padding: EdgeInsets.only(top: AppDimens.space32),
                  child: Chargement(size: 22),
                ),
                error: (e, _) => Padding(
                  padding: const EdgeInsets.all(AppDimens.pagePaddingH),
                  child: VueErreur(
                    message: 'Impossible de charger l\'accueil.',
                    onRetry: () => ref.invalidate(accueilDataProducteurProvider),
                  ),
                ),
                data: (data) => RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: () async {
                    ref.invalidate(accueilDataProducteurProvider);
                    ref.invalidate(accueilProducteurParcellesCountProvider);
                  },
                  child: ContenuAccueil(
                    data: data,
                    parcellesCount: parcellesCount,
                    prenom: prenom,
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
