import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../models/ai_content.dart';
import '../../../models/annonce_achat.dart';
import '../../../models/annonce_vente.dart';
import '../../../models/cooperative.dart';
import '../../../models/enums.dart';
import '../../../models/negociation.dart';
import '../../../models/portefeuille.dart';
import '../../../models/publication_coop.dart';
import '../../../routing/route_names.dart';
import '../../../services/providers.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_dimens.dart';
import '../../../theme/app_text_styles.dart';
import '../../state/auth_state.dart';
import '../../widgets/communs/chargement.dart';
import '../../widgets/communs/header_utilisateur.dart';
import '../../widgets/communs/vue_erreur.dart';

// ─── COULEURS ACCENT (utilisées localement, conformes au mockup) ─────────

const Color _kPrimarySoft = Color(0xFFE8F5E9);
const Color _kWarnSoft = Color(0xFFFFF8E1);
const Color _kWarn = Color(0xFFB26A00);
const Color _kRedSoft = Color(0xFFFDECEA);

// Radius des cards de cette page (14 — acceptable par DESIGN.md pour cette
// page d'accueil avec photos, sauf CTA "publier" qui est en 16 car c'est la
// card hero unique mise en avant).
const BorderRadius _kBrCard = BorderRadius.all(Radius.circular(14));
const BorderRadius _kBrHero = BorderRadius.all(Radius.circular(16));

/// Bundle de données chargées en parallèle pour l'accueil producteur.
class _AccueilProducteurData {
  final Portefeuille? wallet;
  final List<AnnonceVente> annonces;
  final List<Candidature> offresIncoming;
  final AiInsights? insights;
  final List<AnnonceAchat> acheteursQuiCherchent;
  final Cooperative? coopInfo;
  final List<PublicationCoop> coopPublications;

  const _AccueilProducteurData({
    required this.wallet,
    required this.annonces,
    required this.offresIncoming,
    required this.insights,
    required this.acheteursQuiCherchent,
    required this.coopInfo,
    required this.coopPublications,
  });

  bool get isEmpty =>
      annonces.isEmpty &&
      offresIncoming.isEmpty &&
      acheteursQuiCherchent.isEmpty &&
      coopInfo == null &&
      (insights?.tendances.isEmpty ?? true);
}

/// Charge en parallèle les données nécessaires à l'accueil producteur.
///
/// Chaque appel est tolérant : un service en échec retourne `null`/liste
/// vide et les sections concernées sont masquées (graceful degradation).
final accueilDataProducteurProvider =
    FutureProvider.autoDispose<_AccueilProducteurData>((ref) async {
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

  return _AccueilProducteurData(
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

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const HeaderUtilisateur(variant: HeaderVariant.producteur),
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
                  child: _ContenuAccueil(data: data),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ContenuAccueil extends ConsumerWidget {
  const _ContenuAccueil({required this.data});

  final _AccueilProducteurData data;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final annoncesActives = data.annonces
        .where((a) => a.status == ProductStatus.active)
        .length;
    final parcellesCount =
        ref.watch(accueilProducteurParcellesCountProvider);

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(
        AppDimens.pagePaddingH,
        AppDimens.space8,
        AppDimens.pagePaddingH,
        AppDimens.space16,
      ),
      children: [
        // 0. Bandeau alerte si 0 parcelle (au-dessus de tout le reste).
        _BandeauParcellesVide(asyncCount: parcellesCount),
        // 1. CTA Publier ma récolte
        _CtaPublier(
          onTap: () =>
              context.push(RouteNames.producteurPublierAnnoncePath),
        ),
        AppDimens.vGap24,
        // 2. KPI Row
        _KpiRow(
          solde: data.wallet?.balance ?? 0,
          devise: data.wallet?.currency ?? 'XOF',
          annoncesActives: annoncesActives,
          commandesEnCours: 0,
        ),
        AppDimens.vGap24,
        // 3. À traiter
        if (data.offresIncoming.isNotEmpty) ...[
          _SectionATraiter(offres: data.offresIncoming),
          AppDimens.vGap24,
        ],
        // 4. Acheteurs qui cherchent
        if (data.acheteursQuiCherchent.isNotEmpty) ...[
          _SectionAcheteurs(annonces: data.acheteursQuiCherchent),
          AppDimens.vGap24,
        ],
        // 5. Ma coopérative
        if (data.coopInfo != null) ...[
          _SectionCoop(
            coop: data.coopInfo!,
            publications: data.coopPublications,
          ),
          AppDimens.vGap24,
        ],
        // 6. Outils IA (grid 2×2 — 4 raccourcis)
        _SectionOutilsIA(
          onAnalyse: () =>
              context.push(RouteNames.producteurAiAnalysePlantePath),
          onAssistant: () =>
              context.push(RouteNames.producteurAiAssistantPath),
          onActualites: () =>
              context.push(RouteNames.producteurAiActualitesPath),
          onTraitements: () => context
              .push(RouteNames.producteurAiCatalogueTraitementsPath),
        ),
        AppDimens.vGap24,
        // 7. Mes annonces
        if (data.annonces.isNotEmpty) ...[
          _SectionAnnonces(annonces: data.annonces.take(5).toList()),
          AppDimens.vGap24,
        ],
        // 8. Conseils du jour
        if (data.insights != null && data.insights!.tendances.isNotEmpty) ...[
          _SectionConseils(tendance: data.insights!.tendances.first),
          AppDimens.vGap24,
        ],
        if (data.isEmpty) _EtatVide(),
      ],
    );
  }
}

// ─── BANDEAU "AUCUNE PARCELLE" ───────────────────────────────────────────

/// Bandeau d'alerte non-dismissible affiché tant que le farmer n'a aucune
/// parcelle enregistrée. Le bouton "Ajouter ma parcelle" pousse vers le
/// formulaire de création (point d'entrée alternatif au flow "Publier").
class _BandeauParcellesVide extends StatelessWidget {
  const _BandeauParcellesVide({required this.asyncCount});

  final AsyncValue<int> asyncCount;

  @override
  Widget build(BuildContext context) {
    final shouldShow = asyncCount.maybeWhen(
      data: (count) => count == 0,
      orElse: () => false,
    );
    if (!shouldShow) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimens.space24),
      child: Container(
        padding: const EdgeInsets.all(AppDimens.space16),
        decoration: BoxDecoration(
          color: AppColors.surfaceSoft,
          borderRadius: AppDimens.brCard,
          border: Border.all(
            color: AppColors.borderStrong,
            width: AppDimens.borderThin,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(
              Icons.info_outline,
              size: AppDimens.iconM,
              color: AppColors.primary,
            ),
            AppDimens.hGap12,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Tu n\'as pas encore enregistré ton champ',
                    style: AppTextStyles.titleSmall.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Indique-nous où tu cultives pour pouvoir publier '
                    'tes annonces.',
                    style: AppTextStyles.bodySmall,
                  ),
                  AppDimens.vGap12,
                  InkWell(
                    onTap: () => context.push(
                      RouteNames.producteurCreerParcellePath,
                    ),
                    borderRadius: BorderRadius.circular(6),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 4,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Ajouter ma parcelle',
                            style: AppTextStyles.link,
                          ),
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.arrow_forward,
                            size: 16,
                            color: AppColors.primary,
                          ),
                        ],
                      ),
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

// ─── CTA "PUBLIER MA RÉCOLTE" ────────────────────────────────────────────

class _CtaPublier extends StatelessWidget {
  const _CtaPublier({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primary,
      borderRadius: _kBrHero,
      child: InkWell(
        onTap: onTap,
        borderRadius: _kBrHero,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Publier ma récolte',
                      style: AppTextStyles.titleSmall.copyWith(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.onPrimary,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '3 étapes simples · 30 secondes',
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
                  Icons.arrow_forward,
                  size: 20,
                  color: AppColors.onPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── KPI ROW ─────────────────────────────────────────────────────────────

class _KpiRow extends StatelessWidget {
  const _KpiRow({
    required this.solde,
    required this.devise,
    required this.annoncesActives,
    required this.commandesEnCours,
  });

  final double solde;
  final String devise;
  final int annoncesActives;
  final int commandesEnCours;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _KpiCard(
            icon: Icons.account_balance_wallet_outlined,
            valeur: _formatMontant(solde, devise),
            libelle: 'Solde wallet',
          ),
        ),
        AppDimens.hGap8,
        Expanded(
          child: _KpiCard(
            icon: Icons.list_alt_outlined,
            valeur: annoncesActives.toString(),
            libelle: 'Annonces',
          ),
        ),
        AppDimens.hGap8,
        Expanded(
          child: _KpiCard(
            icon: Icons.description_outlined,
            valeur: commandesEnCours.toString(),
            libelle: 'Commandes',
          ),
        ),
      ],
    );
  }
}

class _KpiCard extends StatelessWidget {
  const _KpiCard({
    required this.icon,
    required this.valeur,
    required this.libelle,
  });

  final IconData icon;
  final String valeur;
  final String libelle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: _kBrCard,
        border: Border.all(color: AppColors.border, width: AppDimens.borderThin),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: AppDimens.iconS,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: 6),
          Text(
            valeur,
            style: AppTextStyles.titleLarge.copyWith(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.3,
              height: 1.1,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            libelle,
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w400,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// ─── SECTION "À TRAITER" ─────────────────────────────────────────────────

/// Type sémantique de l'action — pilote la couleur de la bulle.
enum _ActionType { positive, validation, warning, error }

class _ActionItem {
  final IconData icon;
  final _ActionType type;
  final String titre;
  final String sousTitre;
  const _ActionItem({
    required this.icon,
    required this.type,
    required this.titre,
    required this.sousTitre,
  });
}

class _SectionATraiter extends StatelessWidget {
  const _SectionATraiter({required this.offres});

  final List<Candidature> offres;

  @override
  Widget build(BuildContext context) {
    final items = offres.take(3).map((c) {
      final qte = NumberFormat('#,##0', 'fr_FR').format(c.quantiteKg);
      return _ActionItem(
        icon: Icons.shopping_cart_outlined,
        type: _ActionType.positive,
        titre: 'Offre reçue · $qte kg',
        sousTitre: _ageRelatif(c.createdAt),
      );
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SectionHead(
          titre: 'À traiter',
          lienTexte: 'Voir tout',
          onLien: () =>
              context.push(RouteNames.producteurOffresRecuesPath),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: _kBrCard,
            border:
                Border.all(color: AppColors.border, width: AppDimens.borderThin),
          ),
          child: Column(
            children: List.generate(items.length, (i) {
              return _ActionRow(
                item: items[i],
                isLast: i == items.length - 1,
                onTap: () =>
                    context.push(RouteNames.producteurOffresRecuesPath),
              );
            }),
          ),
        ),
      ],
    );
  }

  String _ageRelatif(DateTime? d) {
    if (d == null) return 'récemment';
    final diff = DateTime.now().difference(d);
    if (diff.inMinutes < 60) {
      final m = diff.inMinutes.clamp(1, 59);
      return 'il y a $m min';
    }
    if (diff.inHours < 24) {
      return 'il y a ${diff.inHours} h';
    }
    if (diff.inDays < 7) {
      return 'il y a ${diff.inDays} j';
    }
    return DateFormat('d MMM', 'fr_FR').format(d);
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.item,
    required this.isLast,
    this.onTap,
  });

  final _ActionItem item;
  final bool isLast;
  final VoidCallback? onTap;

  Color get _bubbleBg {
    switch (item.type) {
      case _ActionType.positive:
      case _ActionType.validation:
        return _kPrimarySoft;
      case _ActionType.warning:
        return _kWarnSoft;
      case _ActionType.error:
        return _kRedSoft;
    }
  }

  Color get _bubbleFg {
    switch (item.type) {
      case _ActionType.positive:
      case _ActionType.validation:
        return AppColors.primary;
      case _ActionType.warning:
        return _kWarn;
      case _ActionType.error:
        return AppColors.error;
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimens.space16,
          vertical: 14,
        ),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isLast ? Colors.transparent : AppColors.border,
              width: AppDimens.borderThin,
            ),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _bubbleBg,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Icon(item.icon, size: 20, color: _bubbleFg),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    item.titre,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w500,
                      height: 1.3,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.sousTitre,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              size: AppDimens.iconM,
              color: AppColors.textSubtle,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── SECTION "ACHETEURS QUI CHERCHENT" ───────────────────────────────────

class _SectionAcheteurs extends StatelessWidget {
  const _SectionAcheteurs({required this.annonces});

  final List<AnnonceAchat> annonces;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SectionHead(
          titre: 'Acheteurs qui cherchent',
          lienTexte: 'Voir tout',
          onLien: () =>
              context.push(RouteNames.producteurDemandesAchatPath),
        ),
        SizedBox(
          height: 130,
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
    final titre = annonce.titre?.trim().isNotEmpty == true
        ? annonce.titre!.trim()
        : 'Cherche $qte kg';
    final region = annonce.regionId;

    return Material(
      color: AppColors.surface,
      borderRadius: _kBrCard,
      child: InkWell(
        onTap: () => context.push(
          RouteNames.producteurDemandeAchatRepondrePathFor(annonce.id),
        ),
        borderRadius: _kBrCard,
        child: Container(
          width: 250,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: _kBrCard,
            border:
                Border.all(color: AppColors.border, width: AppDimens.borderThin),
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
                titre,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
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
      ),
    );
  }
}

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

// ─── SECTION "MA COOPÉRATIVE" ────────────────────────────────────────────

class _SectionCoop extends StatelessWidget {
  const _SectionCoop({required this.coop, required this.publications});

  final Cooperative coop;
  final List<PublicationCoop> publications;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SectionHead(
          titre: 'Ma coopérative',
          lienTexte: 'Voir tout',
          onLien: () =>
              context.push(RouteNames.producteurCooperativePath),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: _kBrCard,
            border:
                Border.all(color: AppColors.border, width: AppDimens.borderThin),
          ),
          clipBehavior: Clip.hardEdge,
          child: Column(
            children: [
              _CoopBanner(coop: coop),
              for (final p in publications) _CoopPublicationRow(publication: p),
            ],
          ),
        ),
      ],
    );
  }
}

class _CoopBanner extends StatelessWidget {
  const _CoopBanner({required this.coop});

  final Cooperative coop;

  @override
  Widget build(BuildContext context) {
    final logoUrl = coop.logoUrl;
    return InkWell(
      onTap: () =>
          context.push(RouteNames.producteurCooperativePath),
      child: Container(
        color: _kPrimarySoft,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: AppColors.border,
                  width: AppDimens.borderThin,
                ),
              ),
              clipBehavior: Clip.hardEdge,
              child: (logoUrl != null && logoUrl.isNotEmpty)
                  ? CachedNetworkImage(
                      imageUrl: logoUrl,
                      fit: BoxFit.cover,
                      placeholder: (_, __) =>
                          _CoopLogoPlaceholder(nom: coop.nom),
                      errorWidget: (_, __, ___) =>
                          _CoopLogoPlaceholder(nom: coop.nom),
                    )
                  : _CoopLogoPlaceholder(nom: coop.nom),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    coop.nom,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _formatMembreDepuis(coop.createdAt),
                    style: AppTextStyles.bodySmall.copyWith(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Text(
              'Voir →',
              style: AppTextStyles.link.copyWith(
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CoopLogoPlaceholder extends StatelessWidget {
  const _CoopLogoPlaceholder({required this.nom});

  final String nom;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _kPrimarySoft,
      alignment: Alignment.center,
      child: Text(
        _initiales(nom),
        style: AppTextStyles.labelSmall.copyWith(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: AppColors.primary,
        ),
      ),
    );
  }
}

class _CoopPublicationRow extends StatelessWidget {
  const _CoopPublicationRow({required this.publication});

  final PublicationCoop publication;

  @override
  Widget build(BuildContext context) {
    final qte = NumberFormat('#,##0', 'fr_FR').format(publication.quantiteKg);
    final titre = publication.titre.trim().isNotEmpty
        ? publication.titre.trim()
        : 'Publication';
    return InkWell(
      onTap: () => context.push(
        RouteNames.producteurPublicationCoopDetailPathFor(publication.id),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(
              color: AppColors.border,
              width: AppDimens.borderThin,
            ),
          ),
        ),
        child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: AppColors.surfaceSoft,
              borderRadius: BorderRadius.circular(AppDimens.radiusS),
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.inventory_2_outlined,
              size: 16,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Nouvelle publication : $titre $qte kg',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (publication.createdAt != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    _ageRelatifCourt(publication.createdAt),
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
      ),
    );
  }
}

// ─── SECTION "OUTILS IA" (grid 2×2 d'icônes sobres) ──────────────────────

class _SectionOutilsIA extends StatelessWidget {
  const _SectionOutilsIA({
    required this.onAnalyse,
    required this.onAssistant,
    required this.onActualites,
    required this.onTraitements,
  });

  final VoidCallback onAnalyse;
  final VoidCallback onAssistant;
  final VoidCallback onActualites;
  final VoidCallback onTraitements;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _SectionHead(titre: 'Outils IA'),
        Row(
          children: [
            Expanded(
              child: _OutilTile(
                icon: Icons.eco_outlined,
                titre: 'Diagnostiquer une plante',
                onTap: onAnalyse,
              ),
            ),
            AppDimens.hGap12,
            Expanded(
              child: _OutilTile(
                icon: Icons.chat_bubble_outline,
                titre: 'Assistant agronomique',
                onTap: onAssistant,
              ),
            ),
          ],
        ),
        AppDimens.vGap12,
        Row(
          children: [
            Expanded(
              child: _OutilTile(
                icon: Icons.newspaper_outlined,
                titre: 'Actualités',
                onTap: onActualites,
              ),
            ),
            AppDimens.hGap12,
            Expanded(
              child: _OutilTile(
                icon: Icons.science_outlined,
                titre: 'Traitements',
                onTap: onTraitements,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _OutilTile extends StatelessWidget {
  const _OutilTile({
    required this.icon,
    required this.titre,
    required this.onTap,
  });

  final IconData icon;
  final String titre;
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
          height: 96,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: _kBrCard,
            border: Border.all(
              color: AppColors.border,
              width: AppDimens.borderThin,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  color: _kPrimarySoft,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Icon(icon, size: 18, color: AppColors.primary),
              ),
              Text(
                titre,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
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

// ─── SECTION "MES ANNONCES" ──────────────────────────────────────────────

class _SectionAnnonces extends StatelessWidget {
  const _SectionAnnonces({required this.annonces});

  final List<AnnonceVente> annonces;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SectionHead(
          titre: 'Mes annonces',
          lienTexte: 'Voir tout',
          onLien: () =>
              context.push(RouteNames.producteurMesPublicationsPath),
        ),
        SizedBox(
          height: 256,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: annonces.length,
            separatorBuilder: (_, __) => AppDimens.hGap12,
            itemBuilder: (context, i) => _AnnonceCard(annonce: annonces[i]),
          ),
        ),
      ],
    );
  }
}

class _AnnonceCard extends StatelessWidget {
  const _AnnonceCard({required this.annonce});

  final AnnonceVente annonce;

  @override
  Widget build(BuildContext context) {
    final photoUrl = annonce.photos.isNotEmpty ? annonce.photos.first : null;
    final qte = NumberFormat('#,##0', 'fr_FR').format(annonce.quantiteKg);
    final prix = NumberFormat('#,##0', 'fr_FR').format(annonce.prixParKg);

    return Material(
      color: AppColors.surface,
      borderRadius: _kBrCard,
      clipBehavior: Clip.hardEdge,
      child: InkWell(
        onTap: () => context.push(
          RouteNames.producteurAnnonceDetailPathFor(annonce.id),
        ),
        child: Container(
          width: 200,
          decoration: BoxDecoration(
            borderRadius: _kBrCard,
            border:
                Border.all(color: AppColors.border, width: AppDimens.borderThin),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 132,
                width: double.infinity,
                child: photoUrl != null && photoUrl.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: photoUrl,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => Container(
                          color: AppColors.surfaceSoft,
                        ),
                        errorWidget: (_, __, ___) => Container(
                          color: AppColors.surfaceSoft,
                          alignment: Alignment.center,
                          child: Text(
                            'Photo',
                            style: AppTextStyles.labelSmall.copyWith(
                              color: AppColors.textSubtle,
                            ),
                          ),
                        ),
                      )
                    : Container(
                        color: AppColors.surfaceSoft,
                        alignment: Alignment.center,
                        child: Text(
                          'Photo',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.textSubtle,
                          ),
                        ),
                      ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      annonce.titre,
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$qte kg · ${annonce.viewsCount} vues',
                      style: AppTextStyles.bodySmall.copyWith(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$prix F/kg',
                      style: AppTextStyles.titleLarge.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                        letterSpacing: -0.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── SECTION "CONSEILS DU JOUR" (bandeau vert pâle) ──────────────────────

class _SectionConseils extends StatelessWidget {
  const _SectionConseils({required this.tendance});

  final AiInsightItem tendance;

  @override
  Widget build(BuildContext context) {
    final titre = tendance.titre.isNotEmpty
        ? tendance.titre
        : 'Nouvelle tendance disponible';
    final sub = tendance.body ?? '';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _SectionHead(titre: 'Conseils du jour'),
        Container(
          decoration: BoxDecoration(
            color: _kPrimarySoft,
            borderRadius: _kBrCard,
            border:
                Border.all(color: AppColors.border, width: AppDimens.borderThin),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.trending_up,
                  size: 22,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      titre,
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (sub.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        sub,
                        style: AppTextStyles.bodySmall.copyWith(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── SECTION HEAD ────────────────────────────────────────────────────────

class _SectionHead extends StatelessWidget {
  const _SectionHead({required this.titre, this.lienTexte, this.onLien});

  final String titre;
  final String? lienTexte;
  final VoidCallback? onLien;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimens.space12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              titre,
              style: AppTextStyles.titleSmall.copyWith(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (lienTexte != null)
            InkWell(
              onTap: onLien,
              borderRadius: BorderRadius.circular(6),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 4,
                  vertical: 2,
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

// ─── ÉTAT VIDE ───────────────────────────────────────────────────────────

class _EtatVide extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppDimens.space32),
      child: Column(
        children: [
          Text(
            'Aucune annonce pour l\'instant',
            style: AppTextStyles.titleMedium.copyWith(
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          AppDimens.vGap8,
          Text(
            'Publiez votre première annonce pour commencer à vendre.',
            style: AppTextStyles.bodySmall,
            textAlign: TextAlign.center,
          ),
          AppDimens.vGap16,
          SizedBox(
            height: AppDimens.buttonHeight,
            child: ElevatedButton(
              onPressed: () => context.push(
                RouteNames.producteurPublierAnnoncePath,
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.onPrimary,
                elevation: 0,
                shape: const RoundedRectangleBorder(
                  borderRadius: AppDimens.brButton,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimens.space24,
                ),
              ),
              child: Text('Publier ma première annonce', style: AppTextStyles.button),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── HELPERS ─────────────────────────────────────────────────────────────

/// Formate `12500` → `12 500 F` (devise XOF uniquement, sinon le code).
String _formatMontant(double montant, String devise) {
  final formatted = NumberFormat('#,##0', 'fr_FR').format(montant);
  if (devise == 'XOF' || devise.isEmpty) {
    return '$formatted F';
  }
  return '$formatted $devise';
}

/// "Membre depuis [mois] [année]" — ou "Nouveau membre" si null.
String _formatMembreDepuis(DateTime? d) {
  if (d == null) return 'Nouveau membre';
  final formatted = DateFormat('MMMM yyyy', 'fr_FR').format(d);
  return 'Membre depuis $formatted';
}

/// "il y a 2 j" / "il y a 3 h" — pour annotations courtes.
String _ageRelatifCourt(DateTime? d) {
  if (d == null) return '';
  final diff = DateTime.now().difference(d);
  if (diff.inMinutes < 60) {
    final m = diff.inMinutes.clamp(1, 59);
    return 'il y a $m min';
  }
  if (diff.inHours < 24) return 'il y a ${diff.inHours} h';
  if (diff.inDays < 7) return 'il y a ${diff.inDays} j';
  return DateFormat('d MMM', 'fr_FR').format(d);
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
