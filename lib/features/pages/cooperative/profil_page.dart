import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../models/avance_coop.dart';
import '../../../models/cooperative.dart';
import '../../../models/enums.dart';
import '../../../models/membre_coop.dart';
import '../../../models/pagination.dart';
import '../../../models/payout.dart';
import '../../../models/utilisateur.dart';
import '../../../models/wallet_with_transactions.dart';
import '../../../routing/route_names.dart';
import '../../../services/providers.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_dimens.dart';
import '../../../theme/app_text_styles.dart';
import '../../state/auth_state.dart';
import '../../widgets/communs/chargement.dart';
import '../../widgets/communs/dialog_changer_profil.dart';
import '../../widgets/communs/profil/bouton_deconnexion_profil.dart';
import '../../widgets/communs/profil/carte_identite_profil.dart';
import '../../widgets/communs/profil/changer_photo_helper.dart';
import '../../widgets/communs/profil/groupe_profil.dart';
import '../../widgets/communs/profil/photo_profil.dart';
import '../../widgets/communs/profil/pied_legal_profil.dart';
import '../../widgets/communs/profil/tuile_profil.dart';
import '../../widgets/communs/profil/tuile_toggle_profil.dart';
import '../../widgets/communs/snackbars.dart';
import '../../widgets/communs/vue_erreur.dart';
import '../../widgets/cooperative/profil/ligne_stats_cooperative.dart';
import '../../widgets/cooperative/profil/sous_textes_profil_cooperative.dart';

/// Page profil de la coopérative — accessible via tap sur l'avatar du header
/// (route TOP-LEVEL hors shell). AppBar avec back button, pas d'icône
/// settings principale (l'icône paramètres déclenche juste un snackbar V1).
class ProfilCooperativePage extends ConsumerWidget {
  /// Crée la page profil coopérative.
  const ProfilCooperativePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dataAsync = ref.watch(_profilCoopDataProvider);

    return Scaffold(
      backgroundColor: AppColors.surfaceSoft,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: AppColors.background,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.text),
          tooltip: 'Retour',
          onPressed: () => context.canPop()
              ? context.pop()
              : context.go(RouteNames.accueilCooperativePath),
        ),
        title: Text(
          'Mon profil',
          style: AppTextStyles.titleLarge.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.settings_outlined,
              color: AppColors.text,
            ),
            tooltip: 'Paramètres',
            onPressed: () => _snack(context, 'Paramètres — à venir'),
          ),
        ],
      ),
      body: dataAsync.when(
        loading: () => const Chargement(size: 22),
        error: (err, _) => Padding(
          padding: const EdgeInsets.all(AppDimens.pagePaddingH),
          child: VueErreur(
            message: 'Impossible de charger le profil.',
            onRetry: () => ref.invalidate(_profilCoopDataProvider),
          ),
        ),
        data: (data) => RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () async {
            ref.invalidate(_profilCoopDataProvider);
            await ref.read(_profilCoopDataProvider.future);
          },
          child: _ContenuProfilCooperative(
            data: data,
            onLogout: () async {
              await ref.read(authStateProvider.notifier).logout();
              if (context.mounted) {
                context.go(RouteNames.bienvenuePath);
              }
            },
            onChangerPhoto: () => changerPhotoProfil(context, ref),
          ),
        ),
      ),
    );
  }
}

// ─── Provider racine (agrégation des appels API) ────────────────────────

final _profilCoopDataProvider =
    FutureProvider.autoDispose<_ProfilCoopData>((ref) async {
  final user = ref.watch(currentUserProvider);
  final coopSvc = ref.watch(cooperativesServiceProvider);
  final financeSvc = ref.watch(financeServiceProvider);

  // Coop publique : seulement si l'utilisateur a un cooperativeId connu.
  final coopFuture = (user?.cooperativeId != null &&
          user!.cooperativeId!.isNotEmpty)
      ? coopSvc
          .getPublic(user.cooperativeId!)
          .then<Cooperative?>((c) => c)
          .catchError((_) => null)
      : Future<Cooperative?>.value(null);

  final results = await Future.wait<dynamic>([
    coopFuture,
    financeSvc
        .getWallet()
        .then<WalletWithTransactions?>((w) => w)
        .catchError((_) => null),
    coopSvc.listMembers(limit: 100).catchError(
          (_) => const Paginated<MembreCoop>(
            data: [],
            total: 0,
            page: 1,
            limit: 0,
            totalPages: 0,
          ),
        ),
    coopSvc.listJoinRequests().catchError((_) => <CoopJoinRequest>[]),
    financeSvc.listPayoutBatches().catchError((_) => <PayoutBatch>[]),
    coopSvc.listAdvances().catchError((_) => <AvanceCoop>[]),
  ]);

  return _ProfilCoopData(
    user: user,
    coop: results[0] as Cooperative?,
    wallet: results[1] as WalletWithTransactions?,
    membres: results[2] as Paginated<MembreCoop>,
    joinRequests: results[3] as List<CoopJoinRequest>,
    payoutBatches: results[4] as List<PayoutBatch>,
    advances: results[5] as List<AvanceCoop>,
  );
});

// ─── Modèle interne ──────────────────────────────────────────────────────

class _ProfilCoopData {
  _ProfilCoopData({
    required this.user,
    required this.coop,
    required this.wallet,
    required this.membres,
    required this.joinRequests,
    required this.payoutBatches,
    required this.advances,
  });

  final Utilisateur? user;
  final Cooperative? coop;
  final WalletWithTransactions? wallet;
  final Paginated<MembreCoop> membres;
  final List<CoopJoinRequest> joinRequests;
  final List<PayoutBatch> payoutBatches;
  final List<AvanceCoop> advances;

  int get nbMembres => coop?.nbMembres ?? membres.total;

  int get nbDemandesEnAttente => joinRequests
      .where((r) => (r.status).toUpperCase() == 'PENDING')
      .length;

  int get nbDistributions => payoutBatches.length;

  int get nbAvancesActives =>
      advances.where((a) => a.status == CoopAdvanceStatus.paid).length;

  double get soldeWallet => wallet?.wallet.balance ?? 0;

  String get nomCoop {
    final n = coop?.nom.trim();
    if (n != null && n.isNotEmpty) return n;
    final un = user?.fullName?.trim();
    if (un != null && un.isNotEmpty) return un;
    return 'Ma coopérative';
  }

  String? get photoUrl {
    final p = coop?.logoUrl?.trim();
    if (p != null && p.isNotEmpty) return p;
    final up = user?.photoUrl?.trim();
    if (up != null && up.isNotEmpty) return up;
    return null;
  }

  /// Rating utilisateur (≈ note coop). Affiché formaté à 1 décimale.
  double get rating => user?.rating ?? 0;
}

// ─── Contenu principal ───────────────────────────────────────────────────

class _ContenuProfilCooperative extends StatelessWidget {
  const _ContenuProfilCooperative({
    required this.data,
    required this.onLogout,
    required this.onChangerPhoto,
  });

  final _ProfilCoopData data;
  final VoidCallback onLogout;
  final VoidCallback onChangerPhoto;

  @override
  Widget build(BuildContext context) {
    final produits = data.coop?.produits ?? const <String>[];
    final autoDistribute = data.coop?.autoDistribute ?? false;

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(
        AppDimens.pagePaddingH,
        AppDimens.space16,
        AppDimens.pagePaddingH,
        AppDimens.space16,
      ),
      children: [
        // 1. CARTE IDENTITÉ (photo carrée — variante coop)
        CarteIdentiteProfil(
          nom: data.nomCoop,
          initiales: initialesProfilDepuisNom(data.nomCoop),
          photoUrl: data.photoUrl,
          sousLigne: sousLigneIdentiteCooperative(
            data.nbMembres,
            data.rating,
          ),
          photoCarree: true,
          onModifier: () =>
              _snack(context, 'Modification du profil — à venir'),
          onEditPhoto: onChangerPhoto,
        ),
        AppDimens.vGap24,

        // 2. LIGNE 3 STATS
        LigneStatsCooperative(
          ventesCumulees: '—',
          nbDistributions: data.nbDistributions,
          nbAvancesActives: data.nbAvancesActives,
        ),
        AppDimens.vGap24,

        // 3. SECTION IDENTITÉ DE LA COOP
        GroupeProfil(
          titre: 'Identité de la coop',
          enfants: [
            TuileProfil(
              icone: Icons.assignment_outlined,
              accent: true,
              label: "Numéro d'agrément",
              onTap: () =>
                  context.push(RouteNames.cooperativeIdentitePath),
            ),
            TuileProfil(
              icone: Icons.location_on_outlined,
              accent: true,
              label: 'Région & ville',
              onTap: () =>
                  context.push(RouteNames.cooperativeIdentitePath),
            ),
            TuileProfil(
              icone: Icons.eco_outlined,
              accent: true,
              label: 'Produits gérés',
              sousTitre:
                  produits.isNotEmpty ? produits.take(4).join(', ') : null,
              onTap: () =>
                  context.push(RouteNames.cooperativeIdentitePath),
            ),
          ],
        ),
        AppDimens.vGap16,

        // 4. SECTION FINANCE
        GroupeProfil(
          titre: 'Finance',
          enfants: [
            TuileProfil(
              icone: Icons.account_balance_wallet_outlined,
              accent: true,
              label: 'Wallet coopérative',
              trailingTexte: formatMontantCooperative(data.soldeWallet),
              onTap: () => context.push(RouteNames.cooperativeWalletPath),
            ),
            TuileProfil(
              icone: Icons.percent,
              label: 'Commission par défaut',
              onTap: () =>
                  context.push(RouteNames.cooperativeCommissionPath),
            ),
            TuileToggleProfil(
              icone: Icons.autorenew,
              label: 'Distribution automatique',
              sousTitre: 'Paiements aux membres après vente',
              valeur: autoDistribute,
              onChanged: (_) =>
                  _snack(context, 'Distribution automatique — à venir'),
            ),
            TuileProfil(
              icone: Icons.show_chart,
              label: 'Transactions & payouts',
              onTap: () => context.push(RouteNames.cooperativePayoutsPath),
            ),
          ],
        ),
        AppDimens.vGap16,

        // 5. SECTION GESTION
        GroupeProfil(
          titre: 'Gestion',
          enfants: [
            TuileProfil(
              icone: Icons.receipt_long_outlined,
              accent: true,
              label: 'Mes commandes',
              sousTitre: 'Suivi des ventes directes',
              onTap: () =>
                  context.push(RouteNames.cooperativeCommandesPath),
            ),
            TuileProfil(
              icone: Icons.groups_outlined,
              label: 'Mes membres',
              sousTitre: sousTitreMembresCooperative(
                actifs: data.nbMembres,
                enAttente: data.nbDemandesEnAttente,
              ),
              onTap: () => context.go(RouteNames.cooperativeMembresPath),
            ),
            TuileProfil(
              icone: Icons.cloud_upload_outlined,
              label: 'Documents officiels',
              onTap: () =>
                  context.push(RouteNames.cooperativeDocumentsOfficielsPath),
            ),
          ],
        ),
        AppDimens.vGap16,

        // 5b. SECTION NÉGOCIATIONS — accès aux contre-offres reçues
        // des acheteurs sur les publications coop (table contre_offres_coop).
        GroupeProfil(
          titre: 'Négociations',
          enfants: [
            TuileProfil(
              icone: Icons.handshake_outlined,
              accent: true,
              label: 'Contre-offres reçues',
              sousTitre: 'Acheteurs qui négocient un lot publié',
              onTap: () => context
                  .push(RouteNames.cooperativeContreOffresRecuesPath),
            ),
          ],
        ),
        AppDimens.vGap16,

        // 6. SECTION PARAMÈTRES
        GroupeProfil(
          titre: 'Paramètres',
          enfants: [
            TuileProfil(
              icone: Icons.language,
              label: 'Langue',
              onTap: () => context.push(RouteNames.languePath),
            ),
            TuileProfil(
              icone: Icons.notifications_none,
              label: 'Notifications',
              onTap: () =>
                  context.push(RouteNames.notificationsPreferencesPath),
            ),
            TuileProfil(
              icone: Icons.lock_outline,
              label: 'Sécurité (PIN, sessions)',
              onTap: () => context.push(RouteNames.securitePath),
            ),
            // V1 : un user = un rôle. Dialog explicatif.
            TuileProfil(
              icone: Icons.swap_horiz_rounded,
              label: 'Changer de profil',
              sousTitre: 'Acheteur · Producteur · Coopérative',
              onTap: () => showDialogChangerProfil(context),
            ),
          ],
        ),
        AppDimens.vGap16,

        // 7. SECTION AIDE & LÉGAL
        GroupeProfil(
          titre: 'Aide & légal',
          enfants: [
            TuileProfil(
              icone: Icons.help_outline,
              label: "Centre d'aide",
              onTap: () => context.push(RouteNames.aidePath),
            ),
            TuileProfil(
              icone: Icons.description_outlined,
              label: 'Conditions & confidentialité',
              onTap: () => context.push(RouteNames.conditionsPath),
            ),
          ],
        ),
        AppDimens.vGap8,

        // 8. BOUTON DÉCONNEXION
        BoutonDeconnexionProfil(onTap: onLogout),

        // 9. FOOTER LÉGAL
        AppDimens.vGap16,
        const PiedLegalProfil(),
        AppDimens.vGap8,
      ],
    );
  }
}

/// SnackBar discrète « à venir » — délègue au helper unifié style apps
/// pro (fond sombre + icône colorée), cohérent avec le reste de l'app.
void _snack(BuildContext context, String message) {
  Snackbars.showInfo(context, message);
}
