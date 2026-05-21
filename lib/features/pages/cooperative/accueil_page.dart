import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

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
import '../../widgets/communs/chargement.dart';
import '../../widgets/communs/header_utilisateur.dart';
import '../../widgets/communs/tile_raccourci.dart';
import '../../widgets/communs/vue_erreur.dart';

// ─── COULEURS LOCALES (alignées sur l'accueil producteur) ────────────────

const Color _kPrimarySoft = Color(0xFFE8F5E9);

// Palette d'accents sémantiques calmes — soft backgrounds + accents.
// Utilisés pour différencier visuellement les KPI / actions / raccourcis,
// sans casser la sobriété générale (jamais de saturé plein).
const Color _kInfoSoft = Color(0xFFE3F2FD);
const Color _kInfoAccent = Color(0xFF1976D2);
const Color _kWarnSoft = Color(0xFFFFF4E5);
const Color _kWarnAccent = Color(0xFFE65100);
const Color _kHighlightSoft = Color(0xFFFFF9C4);
const Color _kHighlightAccent = Color(0xFFF57F17);

// Radius des cards et du hero — conformes au pattern producteur :
// 14 pour les cards photo / liste, 16 pour le CTA hero unique.
const BorderRadius _kBrCard = BorderRadius.all(Radius.circular(14));
const BorderRadius _kBrHero = BorderRadius.all(Radius.circular(16));

// Photos statiques "Outils intelligents" (Unsplash — illustration neutre).
const String _kPhotoAssistantGestion =
    'https://images.unsplash.com/photo-1625246333195-78d9c38ad449?w=400&h=300&fit=crop&auto=format';
const String _kPhotoConseilsSaison =
    'https://images.unsplash.com/photo-1464226184884-fa280b87c399?w=400&h=300&fit=crop&auto=format';

/// Accueil coopérative — CTA Collecte, KPIs, raccourcis, acheteurs ciblés,
/// actions à traiter, activité récente des membres, outils intelligents.
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
    final showHero = data.nbAnnoncesAValider > 0;

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
                ? _EtatVide(
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
                      // 1. CTA Collecte du jour (hero — masqué si rien à peser)
                      if (showHero) ...[
                        _CtaCollecte(
                          nbAValider: data.nbAnnoncesAValider,
                          onTap: () => context.push(
                            RouteNames.cooperativeCollectePath,
                          ),
                        ),
                        AppDimens.vGap24,
                      ],
                      // 2. KPI 4 cards
                      _KpiRow(data: data),
                      AppDimens.vGap24,
                      // 3. Grille raccourcis (Collecte remplacée par "Voir les
                      // membres" quand le hero est affiché).
                      _GrilleRaccourcis(
                        nbAValider: data.nbAnnoncesAValider,
                        nbMembres: data.nbMembres,
                        heroAffiche: showHero,
                        onPremiere: () => context.push(
                          showHero
                              ? RouteNames.cooperativeMembresPath
                              : RouteNames.cooperativeCollectePath,
                        ),
                        onInviter: () => context.push(
                          RouteNames.cooperativeInviterFarmerPath,
                        ),
                        onVerserAvance: () => context.push(
                          RouteNames.cooperativeVerserAvancePath,
                        ),
                        onPublierMarche: () => context.push(
                          RouteNames.cooperativePublicationCreerPath,
                        ),
                      ),
                      // 4. Acheteurs qui ciblent ma coop
                      if (data.annoncesAchat.isNotEmpty) ...[
                        AppDimens.vGap24,
                        _SectionAcheteurs(
                          annonces: data.annoncesAchat,
                          onVoirTout: () => context.push(
                            RouteNames.cooperativeOffresRecuesPath,
                          ),
                        ),
                      ],
                      // 5. Actions à traiter
                      if (actions > 0) ...[
                        AppDimens.vGap24,
                        _ActionsATraiter(
                          data: data,
                          onAdhesions: () => context.push(
                            RouteNames.cooperativeAdhesionsPath,
                          ),
                          onOffres: () => context.push(
                            RouteNames.cooperativeOffresRecuesPath,
                          ),
                          onValidations: () => context.push(
                            RouteNames.cooperativePrevisionsMembresPath,
                          ),
                        ),
                      ],
                      // 6. Activité récente des membres
                      if (data.annoncesVentePending.isNotEmpty) ...[
                        AppDimens.vGap24,
                        _SectionActiviteMembres(
                          annonces:
                              data.annoncesVentePending.take(3).toList(),
                          onVoirTout: () => context.push(
                            RouteNames.cooperativeMarchePath,
                          ),
                        ),
                      ],
                      // 7. Outils intelligents
                      AppDimens.vGap24,
                      _SectionOutilsIA(
                        onAssistant: () => _snack(
                          context,
                          'Assistant gestion — à venir',
                        ),
                        onConseils: () => _snack(
                          context,
                          'Conseils saison — à venir',
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }
}

void _snack(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(
      content: Text(message),
      behavior: SnackBarBehavior.floating,
    ));
}

// ─── CTA "COLLECTE DU JOUR" (hero) ───────────────────────────────────────

class _CtaCollecte extends StatelessWidget {
  const _CtaCollecte({required this.nbAValider, required this.onTap});

  final int nbAValider;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final sousTitre = nbAValider > 0
        ? '$nbAValider ${nbAValider > 1 ? "produits" : "produit"} à peser'
        : 'Aucun produit en attente';

    return Material(
      color: AppColors.primary,
      borderRadius: _kBrHero,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: _kBrHero,
        child: Stack(
          children: [
            // Cercle décoratif blanc semi-transparent en bas-droite —
            // "embellish" subtil, ne modifie pas le layout du contenu.
            Positioned(
              right: -28,
              bottom: -28,
              child: IgnorePointer(
                child: Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    color: AppColors.onPrimary.withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Collecte du jour',
                          style: AppTextStyles.titleSmall.copyWith(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.onPrimary,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          sousTitre,
                          style: AppTextStyles.bodySmall.copyWith(
                            fontSize: 12,
                            color: AppColors.onPrimary.withValues(alpha: 0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                  AppDimens.hGap12,
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.onPrimary.withValues(alpha: 0.18),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.assignment_outlined,
                      size: 20,
                      color: AppColors.onPrimary,
                    ),
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

// ─── Ligne KPI (4 cards avec icône en haut) ──────────────────────────────

class _KpiRow extends StatelessWidget {
  const _KpiRow({required this.data});

  final _AccueilCoopData data;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: _KpiCard(
              icon: Icons.groups_outlined,
              value: '${data.nbMembres}',
              label: 'Membres',
              background: _kPrimarySoft,
              accent: AppColors.primary,
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: _KpiCard(
              icon: Icons.inventory_2_outlined,
              value: _formatStock(data.stockKg),
              label: 'Stock',
              background: _kInfoSoft,
              accent: _kInfoAccent,
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: _KpiCard(
              icon: Icons.account_balance_wallet_outlined,
              value: _formatCourt(data.solde),
              label: 'Solde',
              background: _kWarnSoft,
              accent: _kWarnAccent,
            ),
          ),
          const SizedBox(width: 6),
          // V1 — pas d'endpoint payouts coop pour l'instant.
          // TODO(payouts) : brancher quand l'API expose le compteur de payouts coop.
          const Expanded(
            child: _KpiCard(
              icon: Icons.payments_outlined,
              value: '0',
              label: 'Payouts',
              background: _kHighlightSoft,
              accent: _kHighlightAccent,
            ),
          ),
        ],
      ),
    );
  }
}

class _KpiCard extends StatelessWidget {
  const _KpiCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.background,
    required this.accent,
  });

  final IconData icon;
  final String value;
  final String label;

  /// Background pastel doux de la card (ex: _kPrimarySoft, _kInfoSoft…).
  final Color background;

  /// Couleur d'accent assortie utilisée pour le cercle de l'icône.
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      decoration: BoxDecoration(
        color: background,
        borderRadius: _kBrCard,
        border: Border.all(color: AppColors.border, width: AppDimens.borderThin),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: accent,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Icon(
              icon,
              size: 18,
              color: AppColors.onPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.titleSmall.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.2,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 10,
              color: AppColors.textSecondary,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Grille raccourcis 2×2 ───────────────────────────────────────────────

class _GrilleRaccourcis extends StatelessWidget {
  const _GrilleRaccourcis({
    required this.nbAValider,
    required this.nbMembres,
    required this.heroAffiche,
    required this.onPremiere,
    required this.onInviter,
    required this.onVerserAvance,
    required this.onPublierMarche,
  });

  /// Combine annonces vente PENDING + prévisions PENDING.
  final int nbAValider;
  final int nbMembres;

  /// Si le CTA hero "Collecte" est affiché, la tile "Collecte" est
  /// remplacée par "Voir les membres" pour éviter la redondance.
  final bool heroAffiche;

  /// Callback de la première tile (Voir les membres si heroAffiche, sinon
  /// Collecte du jour).
  final VoidCallback onPremiere;
  final VoidCallback onInviter;
  final VoidCallback onVerserAvance;
  final VoidCallback onPublierMarche;

  @override
  Widget build(BuildContext context) {
    final TileRaccourci tilePremiere = heroAffiche
        ? TileRaccourci(
            icon: Icons.groups_outlined,
            titre: 'Voir les membres',
            sousTitre: nbMembres > 0
                ? '$nbMembres ${nbMembres > 1 ? "membres actifs" : "membre actif"}'
                : 'aucun membre',
            accentColor: AppColors.primary,
            onTap: onPremiere,
          )
        : TileRaccourci(
            icon: Icons.assignment_outlined,
            titre: 'Collecte du jour',
            sousTitre: nbAValider > 0
                ? '$nbAValider produits à peser'
                : 'rien à peser',
            badge: nbAValider > 0 ? '$nbAValider' : null,
            accentColor: AppColors.primary,
            onTap: onPremiere,
          );

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 1.25,
      children: [
        tilePremiere,
        TileRaccourci(
          icon: Icons.person_add_outlined,
          titre: 'Inviter un farmer',
          sousTitre: 'par téléphone',
          accentColor: _kInfoAccent,
          onTap: onInviter,
        ),
        TileRaccourci(
          icon: Icons.payments_outlined,
          titre: 'Verser une avance',
          sousTitre: 'à un membre',
          accentColor: _kWarnAccent,
          onTap: onVerserAvance,
        ),
        TileRaccourci(
          icon: Icons.storefront_outlined,
          titre: 'Publier sur marché',
          sousTitre: 'stock direct',
          accentColor: _kHighlightAccent,
          onTap: onPublierMarche,
        ),
      ],
    );
  }
}

// ─── SECTION "ACHETEURS QUI CIBLENT MA COOP" ─────────────────────────────

class _SectionAcheteurs extends StatelessWidget {
  const _SectionAcheteurs({
    required this.annonces,
    required this.onVoirTout,
  });

  final List<AnnonceAchat> annonces;
  final VoidCallback onVoirTout;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SectionHead(
          titre: 'Acheteurs qui ciblent ma coop',
          lienTexte: 'Voir tout',
          onLien: onVoirTout,
          accentDot: _kWarnAccent,
        ),
        SizedBox(
          height: 138,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: annonces.length,
            separatorBuilder: (_, __) => AppDimens.hGap12,
            itemBuilder: (context, i) => _DemandeCard(annonce: annonces[i]),
          ),
        ),
      ],
    );
  }
}

class _DemandeCard extends StatelessWidget {
  const _DemandeCard({required this.annonce});

  final AnnonceAchat annonce;

  @override
  Widget build(BuildContext context) {
    final qte = NumberFormat('#,##0', 'fr_FR').format(annonce.quantiteKg);
    final prix = NumberFormat('#,##0', 'fr_FR').format(annonce.prixMaxKg);
    final region = annonce.regionId;
    final produit = (annonce.titre ?? '').trim().isNotEmpty
        ? annonce.titre!.trim()
        : 'produit';

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 250,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: _kBrCard,
            border: Border.all(
              color: AppColors.border,
              width: AppDimens.borderThin,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _AvatarInitiales(seed: annonce.buyerId),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Acheteur ${_initiales(annonce.buyerId)}',
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (region != null && region.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            region,
                            style: AppTextStyles.bodySmall.copyWith(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                'Cherche $qte kg $produit',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),
              Text(
                'jusqu\'à $prix F/kg',
                style: AppTextStyles.titleLarge.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                  letterSpacing: -0.2,
                  height: 1.2,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        // Petit badge "Nouveau" — opportunité acheteur ciblée sur la coop.
        Positioned(
          top: 8,
          right: 8,
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: _kWarnSoft,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Text(
              'Nouveau',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: _kWarnAccent,
                height: 1.1,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Section "Actions à traiter" ─────────────────────────────────────────

class _ActionsATraiter extends StatelessWidget {
  const _ActionsATraiter({
    required this.data,
    required this.onAdhesions,
    required this.onOffres,
    required this.onValidations,
  });

  final _AccueilCoopData data;
  final VoidCallback onAdhesions;
  final VoidCallback onOffres;
  final VoidCallback onValidations;

  @override
  Widget build(BuildContext context) {
    final items = <_ListItemActionData>[];

    if (data.joinRequests.isNotEmpty) {
      final dernier = _plusRecent(
        data.joinRequests.map((r) => r.createdAt),
      );
      final relatif = _formatRelatif(dernier);
      items.add(
        _ListItemActionData(
          icon: Icons.group_add_outlined,
          titre: '${data.joinRequests.length} '
              '${data.joinRequests.length > 1 ? "demandes" : "demande"} '
              'd’adhésion',
          sousTitre:
              relatif != null ? 'dont 1 reçue $relatif' : 'à examiner',
          accent: _kInfoAccent,
          accentSoft: _kInfoSoft,
          count: data.joinRequests.length,
          onTap: onAdhesions,
        ),
      );
    }

    if (data.annoncesAchat.isNotEmpty) {
      items.add(
        _ListItemActionData(
          icon: Icons.shopping_cart_outlined,
          titre: '${data.annoncesAchat.length} '
              '${data.annoncesAchat.length > 1 ? "offres" : "offre"} '
              'd’achat ${data.annoncesAchat.length > 1 ? "reçues" : "reçue"}',
          sousTitre: _sousTitreOffres(data.annoncesAchat),
          accent: _kWarnAccent,
          accentSoft: _kWarnSoft,
          count: data.annoncesAchat.length,
          onTap: onOffres,
        ),
      );
    }

    if (data.nbAnnoncesAValider > 0) {
      items.add(
        _ListItemActionData(
          icon: Icons.fact_check_outlined,
          titre: '${data.nbAnnoncesAValider} '
              '${data.nbAnnoncesAValider > 1 ? "annonces" : "annonce"} '
              'à valider',
          sousTitre: _sousTitreValidations(
            data.annoncesVentePending.length,
            data.previsionsPending.length,
          ),
          accent: AppColors.primary,
          accentSoft: _kPrimarySoft,
          count: data.nbAnnoncesAValider,
          onTap: onValidations,
        ),
      );
    }

    if (items.isEmpty) return const SizedBox.shrink();

    // "Voir tout" du header : priorité = adhésions > offres > validations,
    // pour pointer sur la liste la plus probable.
    final VoidCallback onVoirTout = data.joinRequests.isNotEmpty
        ? onAdhesions
        : (data.annoncesAchat.isNotEmpty ? onOffres : onValidations);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SectionHead(
          titre: 'Actions à traiter',
          lienTexte: 'Voir tout',
          onLien: onVoirTout,
          trailing: data.joinRequests.isEmpty
              ? null
              : _AvatarsEmpiles(
                  seeds: data.joinRequests
                      .map((r) => r.farmerId)
                      .take(3)
                      .toList(),
                ),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: _kBrCard,
            border: Border.all(
              color: AppColors.border,
              width: AppDimens.borderThin,
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              for (var i = 0; i < items.length; i++) ...[
                _ListItemAction(
                  data: items[i],
                  onTap: items[i].onTap,
                ),
                if (i < items.length - 1)
                  const Divider(
                    height: 1,
                    thickness: 1,
                    color: AppColors.border,
                  ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _ListItemActionData {
  _ListItemActionData({
    required this.icon,
    required this.titre,
    required this.sousTitre,
    required this.accent,
    required this.accentSoft,
    required this.count,
    required this.onTap,
  });

  final IconData icon;
  final String titre;
  final String sousTitre;

  /// Couleur d'accent sémantique (info / warning / primary). Utilisée pour
  /// le fond de l'icône et le badge compteur.
  final Color accent;

  /// Variante "soft" de la couleur d'accent — gardée pour usages futurs
  /// (background ligne, surlignage…). Non utilisée pour rester sobre.
  final Color accentSoft;

  /// Compteur affiché dans le badge de bout de ligne.
  final int count;

  final VoidCallback onTap;
}

class _ListItemAction extends StatelessWidget {
  const _ListItemAction({required this.data, required this.onTap});

  final _ListItemActionData data;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimens.space16,
          vertical: AppDimens.space12,
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: data.accent,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Icon(
                data.icon,
                size: 18,
                color: AppColors.onPrimary,
              ),
            ),
            AppDimens.hGap12,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    data.titre,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w500,
                      color: AppColors.text,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    data.sousTitre,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodySmall,
                  ),
                ],
              ),
            ),
            Container(
              constraints: const BoxConstraints(minWidth: 22, minHeight: 22),
              padding: const EdgeInsets.symmetric(horizontal: 7),
              decoration: BoxDecoration(
                color: data.accent,
                borderRadius: BorderRadius.circular(11),
              ),
              alignment: Alignment.center,
              child: Text(
                '${data.count}',
                style: const TextStyle(
                  color: AppColors.onPrimary,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  height: 1.1,
                ),
              ),
            ),
            const SizedBox(width: 6),
            const Icon(
              Icons.chevron_right,
              size: 18,
              color: AppColors.textSubtle,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── SECTION "ACTIVITÉ RÉCENTE DES MEMBRES" ──────────────────────────────

class _SectionActiviteMembres extends StatelessWidget {
  const _SectionActiviteMembres({
    required this.annonces,
    required this.onVoirTout,
  });

  final List<AnnonceVente> annonces;
  final VoidCallback onVoirTout;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SectionHead(
          titre: 'Activité récente des membres',
          lienTexte: 'Voir tout',
          onLien: onVoirTout,
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: _kBrCard,
            border: Border.all(
              color: AppColors.border,
              width: AppDimens.borderThin,
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              for (var i = 0; i < annonces.length; i++) ...[
                _ActiviteRow(annonce: annonces[i]),
                if (i < annonces.length - 1)
                  const Divider(
                    height: 1,
                    thickness: 1,
                    color: AppColors.border,
                  ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _ActiviteRow extends StatelessWidget {
  const _ActiviteRow({required this.annonce});

  final AnnonceVente annonce;

  @override
  Widget build(BuildContext context) {
    final qte = NumberFormat('#,##0', 'fr_FR').format(annonce.quantiteKg);
    final produit = annonce.titre.trim().isNotEmpty
        ? annonce.titre.trim()
        : 'un produit';
    final prefixe = _prefixeId(annonce.farmerId);

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.space16,
        vertical: AppDimens.space12,
      ),
      child: Row(
        children: [
          _AvatarInitiales(seed: annonce.farmerId),
          AppDimens.hGap12,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$prefixe a publié $produit',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$qte kg · en attente de validation',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodySmall.copyWith(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── SECTION "OUTILS INTELLIGENTS" (grid 2 col, cards photo) ─────────────

class _SectionOutilsIA extends StatelessWidget {
  const _SectionOutilsIA({
    required this.onAssistant,
    required this.onConseils,
  });

  final VoidCallback onAssistant;
  final VoidCallback onConseils;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _SectionHead(titre: 'Outils intelligents'),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _OutilCard(
                photoUrl: _kPhotoAssistantGestion,
                badgeIcon: Icons.chat_bubble_outline,
                titre: 'Assistant gestion',
                sousTitre: 'Pose tes questions sur la gestion coop',
                onTap: onAssistant,
              ),
            ),
            AppDimens.hGap12,
            Expanded(
              child: _OutilCard(
                photoUrl: _kPhotoConseilsSaison,
                badgeIcon: Icons.trending_up,
                titre: 'Conseils saison',
                sousTitre: 'Quels produits valoriser ce mois-ci',
                onTap: onConseils,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _OutilCard extends StatelessWidget {
  const _OutilCard({
    required this.photoUrl,
    required this.badgeIcon,
    required this.titre,
    required this.sousTitre,
    required this.onTap,
  });

  final String photoUrl;
  final IconData badgeIcon;
  final String titre;
  final String sousTitre;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: _kBrCard,
      child: InkWell(
        onTap: onTap,
        borderRadius: _kBrCard,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: _kBrCard,
            border: Border.all(
              color: AppColors.border,
              width: AppDimens.borderThin,
            ),
          ),
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Photo + badge en bas-droite (overflow autorisé via Stack)
              SizedBox(
                height: 80 + 12, // 80 photo + 12 badge overflow
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned.fill(
                      bottom: 12,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            CachedNetworkImage(
                              imageUrl: photoUrl,
                              fit: BoxFit.cover,
                              placeholder: (_, __) => Container(
                                color: AppColors.surfaceSoft,
                              ),
                              errorWidget: (_, __, ___) => Container(
                                color: AppColors.surfaceSoft,
                              ),
                            ),
                            // Overlay gradient subtil (sombre en bas) pour
                            // mieux faire ressortir le badge et préparer
                            // l'arrivée éventuelle d'un texte sur photo.
                            const DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Color(0x00000000),
                                    Color(0x4D000000),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      right: 8,
                      bottom: 0,
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.border,
                            width: AppDimens.borderThin,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Icon(
                          badgeIcon,
                          size: 18,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                titre,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                sousTitre,
                style: AppTextStyles.bodySmall.copyWith(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── SECTION HEAD ────────────────────────────────────────────────────────

class _SectionHead extends StatelessWidget {
  const _SectionHead({
    required this.titre,
    this.lienTexte,
    this.onLien,
    this.trailing,
    this.accentDot,
  });

  final String titre;
  final String? lienTexte;
  final VoidCallback? onLien;

  /// Widget optionnel inséré entre le titre et le lien (ex: avatars empilés).
  final Widget? trailing;

  /// Si fourni, un petit point coloré (8×8) est affiché avant le titre,
  /// pour suggérer la nature de la section (opportunité, action…).
  final Color? accentDot;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimens.space12),
      child: Row(
        children: [
          if (accentDot != null) ...[
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: accentDot,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: Text(
              titre,
              style: AppTextStyles.titleSmall.copyWith(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (trailing != null) ...[
            trailing!,
            const SizedBox(width: 8),
          ],
          if (lienTexte != null)
            InkWell(
              onTap: onLien,
              borderRadius: BorderRadius.circular(6),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 4,
                  vertical: 4,
                ),
                child: Text(
                  lienTexte!,
                  style: AppTextStyles.link.copyWith(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ─── AVATAR INITIALES ────────────────────────────────────────────────────

class _AvatarInitiales extends StatelessWidget {
  const _AvatarInitiales({required this.seed});

  final String seed;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: _kPrimarySoft,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.border, width: AppDimens.borderThin),
      ),
      alignment: Alignment.center,
      child: Text(
        _initiales(seed),
        style: AppTextStyles.labelSmall.copyWith(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: AppColors.primary,
        ),
      ),
    );
  }
}

/// Avatars empilés (overlap léger), pour signaler "X personnes concernées".
class _AvatarsEmpiles extends StatelessWidget {
  const _AvatarsEmpiles({required this.seeds});

  final List<String> seeds;

  @override
  Widget build(BuildContext context) {
    if (seeds.isEmpty) return const SizedBox.shrink();
    const double avatarSize = 22;
    const double overlap = 6;
    final largeur = avatarSize + (seeds.length - 1) * (avatarSize - overlap);
    return SizedBox(
      width: largeur,
      height: avatarSize,
      child: Stack(
        children: [
          for (var i = 0; i < seeds.length; i++)
            Positioned(
              left: i * (avatarSize - overlap),
              child: Container(
                width: avatarSize,
                height: avatarSize,
                decoration: BoxDecoration(
                  color: _kPrimarySoft,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.surface,
                    width: 1.5,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  _initiales(seeds[i]),
                  style: AppTextStyles.labelSmall.copyWith(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ─── État totalement vide ────────────────────────────────────────────────

class _EtatVide extends StatelessWidget {
  const _EtatVide({required this.onInviter});

  final VoidCallback onInviter;

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.pagePaddingH,
        vertical: AppDimens.space32,
      ),
      children: [
        const SizedBox(height: AppDimens.space24),
        Center(
          child: Icon(
            Icons.group_outlined,
            size: 40,
            color: AppColors.textSubtle.withValues(alpha: 0.9),
          ),
        ),
        AppDimens.vGap16,
        Text(
          'Votre coopérative est prête.',
          textAlign: TextAlign.center,
          style: AppTextStyles.titleMedium,
        ),
        const SizedBox(height: 4),
        Text(
          'Invitez vos premiers producteurs pour commencer.',
          textAlign: TextAlign.center,
          style: AppTextStyles.bodySmall,
        ),
        AppDimens.vGap16,
        Center(
          child: TextButton(
            onPressed: onInviter,
            child: Text(
              'Inviter un farmer',
              style: AppTextStyles.link,
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Helpers ─────────────────────────────────────────────────────────────

/// Formate un montant en F CFA "court" : 84500 → "84,5K", 1200000 → "1,2M",
/// inférieur à 1000 → "[v] F".
String _formatCourt(double v) {
  if (v.isNaN || v.isInfinite) return '0 F';
  final abs = v.abs();
  if (abs >= 1000000) {
    return '${_formatDecimal(v / 1000000)}M';
  }
  if (abs >= 1000) {
    return '${_formatDecimal(v / 1000)}K';
  }
  return '${v.toInt()} F';
}

/// Formate une quantité en kg : au-dessus de 1000 → "12,5 t", sinon "[n] kg".
String _formatStock(double kg) {
  if (kg <= 0) return '0 kg';
  if (kg >= 1000) {
    return '${_formatDecimal(kg / 1000)} t';
  }
  return '${kg.toInt()} kg';
}

/// Une décimale, séparateur virgule à la française, sans zéro inutile.
String _formatDecimal(double v) {
  final rounded = (v * 10).round() / 10;
  final isInt = rounded == rounded.roundToDouble();
  if (isInt) return rounded.toInt().toString();
  return rounded.toString().replaceAll('.', ',');
}

/// "il y a Xh" / "il y a Xj" / "à l'instant".
String? _formatRelatif(DateTime? date) {
  if (date == null) return null;
  final diff = DateTime.now().difference(date);
  if (diff.inMinutes < 1) return 'à l’instant';
  if (diff.inMinutes < 60) return 'il y a ${diff.inMinutes} min';
  if (diff.inHours < 24) return 'il y a ${diff.inHours} h';
  if (diff.inDays < 7) return 'il y a ${diff.inDays} j';
  final semaines = (diff.inDays / 7).floor();
  if (semaines < 5) return 'il y a $semaines sem';
  final mois = (diff.inDays / 30).floor();
  return 'il y a $mois mois';
}

DateTime? _plusRecent(Iterable<DateTime?> dates) {
  DateTime? best;
  for (final d in dates) {
    if (d == null) continue;
    if (best == null || d.isAfter(best)) best = d;
  }
  return best;
}

String _sousTitreOffres(List<AnnonceAchat> offres) {
  if (offres.isEmpty) return '';
  final premier = offres.first;
  final qty = _formatStock(premier.quantiteKg);
  final titre = (premier.titre ?? '').trim();
  if (titre.isNotEmpty) return '$titre · $qty';
  return qty;
}

String _sousTitreValidations(int nbVente, int nbPrev) {
  final parts = <String>[];
  if (nbVente > 0) {
    parts.add('$nbVente ${nbVente > 1 ? "annonces" : "annonce"}');
  }
  if (nbPrev > 0) {
    parts.add('$nbPrev ${nbPrev > 1 ? "prévisions" : "prévision"}');
  }
  if (parts.isEmpty) return 'à examiner';
  return '${parts.join(" · ")} à examiner';
}

/// Génère 2 lettres depuis un id/nom — utile pour avatar placeholder.
String _initiales(String input) {
  final trimmed = input.trim();
  if (trimmed.isEmpty) return '?';
  // Si plusieurs mots → première lettre de chaque (max 2).
  final parts = trimmed.split(RegExp(r'[\s\-_]+'))
    ..removeWhere((p) => p.isEmpty);
  if (parts.length >= 2) {
    return (parts[0].substring(0, 1) + parts[1].substring(0, 1)).toUpperCase();
  }
  // Sinon : 2 premiers caractères du mot.
  if (trimmed.length == 1) return trimmed.toUpperCase();
  return trimmed.substring(0, 2).toUpperCase();
}

/// Prefixe d'un id pour affichage utilisateur (ex: "user_abc123" → "Abc12").
String _prefixeId(String id) {
  final trimmed = id.trim();
  if (trimmed.isEmpty) return 'Un membre';
  // Si l'id contient un underscore, on prend ce qui suit le 1er underscore.
  final apres = trimmed.contains('_') ? trimmed.split('_').last : trimmed;
  if (apres.isEmpty) return 'Un membre';
  final court = apres.length > 5 ? apres.substring(0, 5) : apres;
  return court[0].toUpperCase() + court.substring(1);
}
