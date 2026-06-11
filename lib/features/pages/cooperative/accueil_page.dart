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
import '../../../theme/app_text_styles.dart';
import '../../widgets/communs/bandeau_consentement.dart';
import '../../widgets/communs/carte_solde_hero.dart';
import '../../widgets/communs/chargement.dart';
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

    return BandeauConsentementWrapper(
      child: Scaffold(
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
                      AppDimens.space24,
                    ),
                    children: [
                      // Trésorerie coopérative
                      CarteSoldeHero(
                        solde: data.solde,
                        onOuvrirWallet: () => context.push(
                          RouteNames.cooperativeWalletPath,
                        ),
                        titre: 'Trésorerie coopérative',
                        labelBouton: 'Voir la trésorerie',
                      ),
                      AppDimens.vGap24,

                      // Synthèse (KPIs)
                      Text(
                        'Synthèse',
                        style: AppTextStyles.titleMedium.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      AppDimens.vGap12,
                      Row(
                        children: [
                          _KpiCard(
                            label: 'Stock (kg)',
                            value: data.stockKg.toStringAsFixed(0),
                            icon: Icons.inventory_2_outlined,
                          ),
                          const SizedBox(width: 12),
                          _KpiCard(
                            label: 'Membres',
                            value: data.nbMembres.toString(),
                            icon: Icons.groups_outlined,
                          ),
                        ],
                      ),
                      AppDimens.vGap24,

                      // À traiter (Alertes)
                      if (data.nbAnnoncesAValider > 0) ...[
                        Text(
                          'À traiter',
                          style: AppTextStyles.titleMedium.copyWith(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        AppDimens.vGap12,
                        InkWell(
                          onTap: () => context.push(RouteNames.cooperativeCollectePath),
                          borderRadius: BorderRadius.circular(14),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF3E0), // Orange très léger
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: const Color(0xFFFFCC80), width: 1),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.warning_amber_rounded, color: Color(0xFFE65100), size: 28),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${data.nbAnnoncesAValider} livraisons en attente',
                                        style: AppTextStyles.titleSmall.copyWith(
                                          fontWeight: FontWeight.w700,
                                          color: const Color(0xFFE65100),
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'Pesée et validation requises',
                                        style: AppTextStyles.bodySmall.copyWith(
                                          color: const Color(0xFFE65100).withOpacity(0.8),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(Icons.arrow_forward_ios, color: Color(0xFFE65100), size: 16),
                              ],
                            ),
                          ),
                        ),
                        AppDimens.vGap24,
                      ],

                      // Raccourcis rapides
                      Text(
                        'Raccourcis rapides',
                        style: AppTextStyles.titleMedium.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      AppDimens.vGap12,
                      GrilleActions(actions: _actions(context)),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  /// Liste des 6 actions de la grille accueil coopérative.
  List<ActionRapide> _actions(BuildContext context) => [
        ActionRapide(
          icone: Icons.inventory_2_outlined,
          label: 'Collecte',
          onTap: () => context.push(RouteNames.cooperativeCollectePath),
        ),
        ActionRapide(
          icone: Icons.groups_outlined,
          label: 'Membres',
          onTap: () => context.go(RouteNames.cooperativeMembresPath),
        ),
        ActionRapide(
          icone: Icons.campaign_outlined,
          label: 'Publications',
          onTap: () => context.go(RouteNames.cooperativeMarchePath),
        ),
        ActionRapide(
          icone: Icons.payments_outlined,
          label: 'Avances',
          // Fix 2026-06-06 : `cooperativeAvancesPath` ('/cooperative/avances')
          // était une constante orpheline (pas de GoRoute enregistré),
          // d'où le "no routes for location" 404. La page « Verser une
          // avance » est l'écran principal d'avances — on pointe dessus
          // directement (de toute façon il n'y a pas de page liste
          // d'avances séparée pour l'instant).
          onTap: () => context.push(RouteNames.cooperativeVerserAvancePath),
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
      ];
}

class _KpiCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _KpiCard({required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border, width: AppDimens.borderThin),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: AppColors.primary, size: 20),
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: AppTextStyles.titleMedium.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

