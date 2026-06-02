import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../models/annonce_achat.dart';
import '../../../models/annonce_vente.dart';
import '../../../models/enums.dart';
import '../../../models/lot.dart';
import '../../../models/membre_coop.dart';
import '../../../models/pagination.dart';
import '../../../models/prevision.dart';
import '../../../models/wallet_with_transactions.dart';
import '../../../routing/route_names.dart';
import '../../../services/providers.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_dimens.dart';
import '../../state/auth_state.dart';
import '../../widgets/communs/carte_solde_hero.dart';
import '../../widgets/communs/chargement.dart';
import '../../widgets/communs/entete_bonjour.dart';
import '../../widgets/communs/grille_actions.dart';
import '../../widgets/communs/header_utilisateur.dart';
import '../../widgets/communs/vue_erreur.dart';
import '../../widgets/cooperative/accueil/etat_vide_accueil_coop.dart';

/// Accueil coopérative — layout épuré, pattern maquette FarmCash AI :
/// Bonjour + solde trésorerie + grille 2×3 d'actions. Toutes les
/// sections riches (CTA collecte, KPI, raccourcis, acheteurs ciblés,
/// actions à traiter, activité membres, outils IA) ont été retirées :
/// elles font doublon avec les tuiles de la grille qui pointent vers
/// les pages dédiées (Membres, Publications, Avances, etc.).
class AccueilPage extends ConsumerWidget {
  const AccueilPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dataAsync = ref.watch(_accueilCoopDataProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: dataAsync.when(
          loading: () => Column(
            children: const [
              HeaderUtilisateur(variant: HeaderVariant.cooperative),
              Expanded(child: Chargement(size: 22)),
            ],
          ),
          error: (err, _) => Column(
            children: [
              const HeaderUtilisateur(variant: HeaderVariant.cooperative),
              Padding(
                padding: const EdgeInsets.all(AppDimens.pagePaddingH),
                child: VueErreur(
                  message: 'Impossible de charger l’accueil.',
                  onRetry: () => ref.invalidate(_accueilCoopDataProvider),
                ),
              ),
            ],
          ),
          data: (data) => _AccueilContent(data: data),
        ),
      ),
    );
  }
}

// ─── Provider racine ─────────────────────────────────────────────────────

final _accueilCoopDataProvider =
    FutureProvider.autoDispose<_AccueilCoopData>((ref) async {
  final coopSvc = ref.watch(cooperativesServiceProvider);
  final financeSvc = ref.watch(financeServiceProvider);
  final marketSvc = ref.watch(marketplaceServiceProvider);

  final results = await Future.wait<dynamic>([
    coopSvc.listMembers(limit: 100).catchError(
          (_) => const Paginated<MembreCoop>(
            data: [],
            total: 0,
            page: 1,
            limit: 0,
            totalPages: 0,
          ),
        ),
    coopSvc
        .listJoinRequests()
        .catchError((_) => <CoopJoinRequest>[]),
    coopSvc
        .listIncomingAnnoncesAchat()
        .catchError((_) => <AnnonceAchat>[]),
    coopSvc
        .listAssignedAnnoncesVente(coopStatus: CoopAnnonceStatus.pending)
        .catchError((_) => <AnnonceVente>[]),
    coopSvc
        .listAssignedPrevisions(coopStatus: CoopAnnonceStatus.pending)
        .catchError((_) => <Prevision>[]),
    financeSvc
        .getWallet()
        .then<WalletWithTransactions?>((w) => w)
        .catchError((_) => null),
    marketSvc.listLots().catchError((_) => <Lot>[]),
  ]);

  return _AccueilCoopData(
    membres: results[0] as Paginated<MembreCoop>,
    joinRequests: results[1] as List<CoopJoinRequest>,
    annoncesAchat: results[2] as List<AnnonceAchat>,
    annoncesVentePending: results[3] as List<AnnonceVente>,
    previsionsPending: results[4] as List<Prevision>,
    wallet: results[5] as WalletWithTransactions?,
    lots: results[6] as List<Lot>,
  );
});

// ─── Modèle interne ──────────────────────────────────────────────────────

class _AccueilCoopData {
  _AccueilCoopData({
    required this.membres,
    required this.joinRequests,
    required this.annoncesAchat,
    required this.annoncesVentePending,
    required this.previsionsPending,
    required this.wallet,
    required this.lots,
  });

  final Paginated<MembreCoop> membres;
  final List<CoopJoinRequest> joinRequests;
  final List<AnnonceAchat> annoncesAchat;
  final List<AnnonceVente> annoncesVentePending;
  final List<Prevision> previsionsPending;
  final WalletWithTransactions? wallet;
  final List<Lot> lots;

  int get nbMembres => membres.total;

  int get nbAnnoncesAValider =>
      annoncesVentePending.length + previsionsPending.length;

  int get actionsTotal =>
      joinRequests.length + annoncesAchat.length + nbAnnoncesAValider;

  double get stockKg => lots.fold<double>(0, (s, l) => s + l.quantiteKg);

  double get solde => wallet?.wallet.balance ?? 0;

  bool get totalementVide =>
      nbMembres == 0 && actionsTotal == 0 && stockKg == 0 && solde == 0;
}

// ─── Contenu principal ───────────────────────────────────────────────────

class _AccueilContent extends ConsumerWidget {
  const _AccueilContent({required this.data});

  final _AccueilCoopData data;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final actions = data.actionsTotal;
    final user = ref.watch(currentUserProvider);
    // La coop a souvent un nom d'organisation comme fullName ; on prend
    // le premier mot pour rester court dans l'entête.
    final prenom = (user?.fullName ?? '').trim().split(RegExp(r'\s+')).first;

    return Column(
      children: [
        HeaderUtilisateur(
          variant: HeaderVariant.cooperative,
          subtitleOverride: actions > 0
              ? '$actions actions à traiter'
              : 'Aucune action en attente',
        ),
        Expanded(
          child: RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () async {
              ref.invalidate(_accueilCoopDataProvider);
              await ref.read(_accueilCoopDataProvider.future);
            },
            child: data.totalementVide
                ? EtatVideAccueilCoop(
                    onInviter: () => context.push(
                      RouteNames.cooperativeInviterFarmerPath,
                    ),
                  )
                : ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(
                      AppDimens.pagePaddingH,
                      AppDimens.space8,
                      AppDimens.pagePaddingH,
                      AppDimens.space16,
                    ),
                    children: [
                      // A. Hero personnalisé « Bonjour, [nom coop] 👋 »
                      EnteteBonjour(
                        prenom: prenom,
                        question: 'Quelle action aujourd\'hui ?',
                      ),
                      AppDimens.vGap16,
                      // B. Carte solde — trésorerie coopérative
                      CarteSoldeHero(
                        solde: data.solde,
                        onOuvrirWallet: () => context.push(
                          RouteNames.cooperativeWalletPath,
                        ),
                        titre: 'Trésorerie coopérative',
                        labelBouton: 'Voir la trésorerie',
                      ),
                      AppDimens.vGap16,
                      // C. Grille 2×3 d'actions rapides — toutes les pages
                      //    clés du rôle coop (Membres, Publications, etc.)
                      GrilleActions(actions: _actions(context)),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  /// Liste des 6 actions de la grille accueil coopérative — alignée
  /// sur le pattern maquette FarmCash AI : 6 portes d'entrée évidentes
  /// vers les pages clés du rôle coop. Ordre conservé pour cohérence
  /// cross-session.
  List<ActionRapide> _actions(BuildContext context) => [
        ActionRapide(
          icone: Icons.groups_outlined,
          label: 'Membres',
          // Onglet shell → go pour activer la branche bottom nav.
          onTap: () => context.go(RouteNames.cooperativeMembresPath),
        ),
        ActionRapide(
          icone: Icons.campaign_outlined,
          label: 'Publications',
          // Onglet shell Marché → go.
          onTap: () => context.go(RouteNames.cooperativeMarchePath),
        ),
        ActionRapide(
          icone: Icons.payments_outlined,
          label: 'Avances',
          onTap: () => context.push(RouteNames.cooperativeAvancesPath),
        ),
        ActionRapide(
          icone: Icons.support_agent_outlined,
          label: 'Sollicitations',
          onTap: () =>
              context.push(RouteNames.cooperativeSollicitationCreerPath),
        ),
        ActionRapide(
          icone: Icons.local_shipping_outlined,
          label: 'Logistique',
          onTap: () => context.push(RouteNames.cooperativeLogistiquePath),
        ),
        ActionRapide(
          icone: Icons.more_horiz,
          label: 'Plus',
          onTap: () => context.push(RouteNames.cooperativeProfilPath),
        ),
      ];
}

