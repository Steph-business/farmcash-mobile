import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../models/ai_content.dart';
import '../../../models/annonce_achat.dart';
import '../../../models/annonce_vente.dart';
import '../../../models/pagination.dart';
import '../../../models/produit.dart';
import '../../../routing/route_names.dart';
import '../../../services/providers.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_dimens.dart';
import '../../../theme/app_text_styles.dart';
import '../../state/auth_state.dart';
import '../../widgets/communs/chargement.dart';
import '../../widgets/communs/header_utilisateur.dart';
import '../../widgets/communs/vue_erreur.dart';

// ─── COULEURS ACCENT LOCALES ─────────────────────────────────────────────

const Color _kPrimarySoft = Color(0xFFE8F5E9);

// Radius cards (14 — acceptable pour cette page d'accueil avec photos,
// hero CTA en 16, conformément à la page producteur).
const BorderRadius _kBrCard = BorderRadius.all(Radius.circular(14));
const BorderRadius _kBrHero = BorderRadius.all(Radius.circular(16));

// Photos statiques Unsplash pour les "Outils intelligents" — illustration
// neutre, pas de mock data fonctionnel.
const String _kPhotoAssistantAchat =
    'https://images.unsplash.com/photo-1488459716781-31db52582fe9?w=400&h=300&fit=crop&auto=format';
const String _kPhotoAlertesPrix =
    'https://images.unsplash.com/photo-1586201375761-83865001e31c?w=400&h=300&fit=crop&auto=format';

/// Vendeur unique dérivé des annonces de vente (groupé par farmerId).
class _VendeurApercu {
  const _VendeurApercu({
    required this.farmerId,
    required this.regionId,
    required this.nbProduits,
    required this.premierProduitNom,
  });

  final String farmerId;
  final String? regionId;
  final int nbProduits;
  final String premierProduitNom;
}

/// Données agrégées pour l'accueil acheteur.
class _AccueilData {
  const _AccueilData({
    required this.categories,
    required this.annonces,
    required this.demandes,
    required this.produitsParId,
    required this.producteursADecouvrir,
    required this.insights,
  });

  final List<Categorie> categories;
  final List<AnnonceVente> annonces;
  final List<AnnonceAchat> demandes;
  final Map<String, Produit> produitsParId;
  final List<_VendeurApercu> producteursADecouvrir;
  final AiInsights? insights;
}

/// Provider de chargement combiné (catégories + annonces + demandes + IA).
final _accueilAcheteurDataProvider =
    FutureProvider.autoDispose<_AccueilData>((ref) async {
  final svc = ref.watch(marketplaceServiceProvider);
  final ai = ref.watch(aiServiceProvider);
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

  final produitsParId = <String, Produit>{
    for (final p in produits) p.id: p,
  };

  // Côté buyer : on filtre les annonces d'achat pour ne garder QUE les siennes.
  final mesDemandes = user == null
      ? const <AnnonceAchat>[]
      : demandesPage.data.where((a) => a.buyerId == user.id).toList();

  // Producteurs à découvrir : group by farmerId, 5 premiers uniques.
  final Map<String, List<AnnonceVente>> parFarmer = {};
  for (final a in annoncesPage.data) {
    parFarmer.putIfAbsent(a.farmerId, () => []).add(a);
  }
  final producteurs = parFarmer.entries.take(5).map((entry) {
    final premier = entry.value.first;
    final produit = produitsParId[premier.produitId];
    return _VendeurApercu(
      farmerId: entry.key,
      regionId: premier.regionId,
      nbProduits: entry.value.length,
      premierProduitNom: produit?.nom ?? premier.titre,
    );
  }).toList();

  return _AccueilData(
    categories: categories,
    annonces: annoncesPage.data,
    demandes: mesDemandes,
    produitsParId: produitsParId,
    producteursADecouvrir: producteurs,
    insights: insights,
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

  void _showSoon(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _onTapRecherche() => context.push(RouteNames.acheteurMarchePath);
  void _onTapPublierDemande() =>
      context.push(RouteNames.acheteurDemandePublierPath);
  void _onTapDemande() => context.push(RouteNames.acheteurDemandesPath);
  void _onTapVoirTout() => context.push(RouteNames.acheteurMarchePath);
  void _onTapVoirProducteurs() => context.push(RouteNames.acheteurMarchePath);
  void _onTapVendeur(_VendeurApercu v) {
    final farmerId = v.farmerId.isNotEmpty ? v.farmerId : 'mock-farmer-1';
    context.push(RouteNames.acheteurVendeurDetailPathFor(farmerId));
  }
  void _onTapAssistantAchat() => _showSoon('Assistant achat — à venir');
  void _onTapAlertesPrix() => _showSoon('Alertes prix — à venir');

  void _onTapAnnonce(AnnonceVente a) {
    context.push(RouteNames.acheteurAnnonceDetailPathFor(a.id));
  }

  @override
  Widget build(BuildContext context) {
    final asyncData = ref.watch(_accueilAcheteurDataProvider);

    final searchBar = _SearchBar(onTap: _onTapRecherche);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            HeaderUtilisateur(
              variant: HeaderVariant.acheteur,
              bottomChild: searchBar,
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
                data: (data) => _buildContent(data),
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
      return _EmptyState(onRefresh: _refresh);
    }

    // Filtrage en mémoire selon la catégorie active.
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
    // "Près de chez toi" : si on a > 4 annonces, on prend les 4 suivantes ;
    // sinon on remontre les mêmes en ordre inverse pour qu'au moins
    // quelque chose s'affiche (le backend n'expose pas encore de filtre
    // géo réel — à remplacer par un vrai filtre par région/distance).
    final pres = annoncesFiltrees.length > 4
        ? annoncesFiltrees.skip(4).take(4).toList()
        : annoncesFiltrees.reversed.take(4).toList();

    // Tendances : on prend la première si dispo, sinon fallback statique.
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
          // 2. Chips catégories
          _Chips(
            categories: data.categories,
            selection: _filtreCategorieNom,
            onChanged: (nom) => setState(() => _filtreCategorieNom = nom),
          ),
          AppDimens.vGap16,
          // 3. CTA Hero : publier une demande d'achat
          _CtaPublierDemande(onTap: _onTapPublierDemande),
          AppDimens.vGap16,
          // 4. Bandeau "Ma demande active" (si user a des demandes)
          if (data.demandes.isNotEmpty) ...[
            _BandeauDemande(
              demandes: data.demandes,
              produitsParId: data.produitsParId,
              onTap: _onTapDemande,
            ),
            AppDimens.vGap16,
          ],
          // 5. Producteurs à découvrir (masqué si <2 vendeurs uniques)
          if (data.producteursADecouvrir.length >= 2) ...[
            _SectionProducteurs(
              producteurs: data.producteursADecouvrir,
              onVoirTout: _onTapVoirProducteurs,
              onTapVendeur: _onTapVendeur,
            ),
            AppDimens.vGap24,
          ],
          // 6. Recommandé pour toi (grid 2 col)
          _Section(
            titre: 'Recommandé pour toi',
            onVoirTout: _onTapVoirTout,
            child: recommandes.isEmpty
                ? _EmptySection(
                    message: _filtreCategorieNom == null
                        ? 'Aucune annonce disponible pour le moment.'
                        : 'Aucune annonce dans cette catégorie.',
                  )
                : _AnnoncesGrid(
                    annonces: recommandes,
                    produitsParId: data.produitsParId,
                    onTap: _onTapAnnonce,
                  ),
          ),
          AppDimens.vGap24,
          // 7. Près de chez toi (grid 2 col, masqué si vide)
          if (pres.isNotEmpty) ...[
            _Section(
              titre: 'Près de chez toi',
              onVoirTout: _onTapVoirTout,
              child: _AnnoncesGrid(
                annonces: pres,
                produitsParId: data.produitsParId,
                onTap: _onTapAnnonce,
              ),
            ),
            AppDimens.vGap24,
          ],
          // 8. Tendances du marché (bandeau vert pâle)
          _SectionTendance(tendance: tendance),
          AppDimens.vGap24,
          // 9. Outils intelligents (grid 2×2 avec photos)
          _SectionOutilsIA(
            onAssistant: _onTapAssistantAchat,
            onAlertes: _onTapAlertesPrix,
          ),
        ],
      ),
    );
  }
}

// ───────────────────────────────────────────────────────────────────────
//  SEARCH BAR
// ───────────────────────────────────────────────────────────────────────

class _SearchBar extends StatelessWidget {
  const _SearchBar({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppDimens.brInput,
      child: Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: AppDimens.brInput,
          border: Border.all(
            color: AppColors.borderStrong,
            width: AppDimens.borderThin,
          ),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.search,
              size: AppDimens.iconM,
              color: AppColors.textSubtle,
            ),
            AppDimens.hGap8,
            Expanded(
              child: Text(
                'Rechercher un produit, une région…',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSubtle,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ───────────────────────────────────────────────────────────────────────
//  CHIPS CATÉGORIES
// ───────────────────────────────────────────────────────────────────────

class _Chips extends StatelessWidget {
  const _Chips({
    required this.categories,
    required this.selection,
    required this.onChanged,
  });

  final List<Categorie> categories;
  final String? selection;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    final items = <_ChipData>[
      const _ChipData(label: 'Tout', value: null),
      ...categories.map((c) => _ChipData(label: c.nom, value: c.nom)),
    ];

    return SizedBox(
      height: 34,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: items.length,
        separatorBuilder: (_, __) => AppDimens.hGap8,
        itemBuilder: (context, i) {
          final item = items[i];
          final active = item.value == selection;
          return _Chip(
            label: item.label,
            active: active,
            onTap: () => onChanged(item.value),
          );
        },
      ),
    );
  }
}

class _ChipData {
  const _ChipData({required this.label, required this.value});
  final String label;
  final String? value;
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimens.radiusPill),
      child: Container(
        height: 34,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: active ? AppColors.primary : AppColors.background,
          borderRadius: BorderRadius.circular(AppDimens.radiusPill),
          border: Border.all(
            color: active ? AppColors.primary : AppColors.borderStrong,
            width: AppDimens.borderThin,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.labelMedium.copyWith(
            color: active ? AppColors.onPrimary : AppColors.text,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

// ───────────────────────────────────────────────────────────────────────
//  CTA HERO — "PUBLIER UNE DEMANDE D'ACHAT"
// ───────────────────────────────────────────────────────────────────────

class _CtaPublierDemande extends StatelessWidget {
  const _CtaPublierDemande({required this.onTap});

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
                      'Publier une demande d\'achat',
                      style: AppTextStyles.titleSmall.copyWith(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.onPrimary,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Les producteurs viennent à toi',
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

// ───────────────────────────────────────────────────────────────────────
//  BANDEAU DEMANDE ACTIVE
// ───────────────────────────────────────────────────────────────────────

class _BandeauDemande extends StatelessWidget {
  const _BandeauDemande({
    required this.demandes,
    required this.produitsParId,
    required this.onTap,
  });

  final List<AnnonceAchat> demandes;
  final Map<String, Produit> produitsParId;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final premiere = demandes.first;
    final produitNom = produitsParId[premiere.produitId]?.nom;
    final qte = _formatKg(premiere.quantiteKg);

    final titre = produitNom != null
        ? 'Ma demande : $qte de $produitNom'
        : 'Ma demande : $qte';
    final sousTitre = demandes.length > 1
        ? '${demandes.length} demandes actives'
        : 'Demande active';

    return InkWell(
      onTap: onTap,
      borderRadius: AppDimens.brCard,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimens.space16,
          vertical: AppDimens.space12,
        ),
        decoration: BoxDecoration(
          color: AppColors.surfaceSoft,
          borderRadius: AppDimens.brCard,
          border: Border.all(
            color: AppColors.border,
            width: AppDimens.borderThin,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(AppDimens.radiusS),
                border: Border.all(
                  color: AppColors.border,
                  width: AppDimens.borderThin,
                ),
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.shopping_cart_outlined,
                size: AppDimens.iconM,
                color: AppColors.textSecondary,
              ),
            ),
            AppDimens.hGap12,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    titre,
                    style: AppTextStyles.titleSmall.copyWith(fontSize: 13),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    sousTitre,
                    style: AppTextStyles.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            AppDimens.hGap8,
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: _kPrimarySoft,
                borderRadius: BorderRadius.circular(AppDimens.radiusPill),
              ),
              child: Text(
                '${demandes.length}',
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ───────────────────────────────────────────────────────────────────────
//  SECTION "PRODUCTEURS À DÉCOUVRIR"
// ───────────────────────────────────────────────────────────────────────

class _SectionProducteurs extends StatelessWidget {
  const _SectionProducteurs({
    required this.producteurs,
    required this.onVoirTout,
    required this.onTapVendeur,
  });

  final List<_VendeurApercu> producteurs;
  final VoidCallback onVoirTout;
  final ValueChanged<_VendeurApercu> onTapVendeur;

  @override
  Widget build(BuildContext context) {
    return _Section(
      titre: 'Producteurs à découvrir',
      onVoirTout: onVoirTout,
      child: SizedBox(
        height: 232,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          itemCount: producteurs.length,
          separatorBuilder: (_, __) => AppDimens.hGap12,
          itemBuilder: (context, i) => _ProducteurCard(
            vendeur: producteurs[i],
            onTap: () => onTapVendeur(producteurs[i]),
          ),
        ),
      ),
    );
  }
}

class _ProducteurCard extends StatelessWidget {
  const _ProducteurCard({required this.vendeur, required this.onTap});

  final _VendeurApercu vendeur;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final region = vendeur.regionId;
    final regionTxt =
        (region != null && region.isNotEmpty) ? region : 'Région';
    final sousTitre = '$regionTxt · ${vendeur.nbProduits} produit'
        '${vendeur.nbProduits > 1 ? 's' : ''}';

    return InkWell(
      onTap: onTap,
      borderRadius: _kBrCard,
      child: Container(
        width: 160,
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Photo : pas d'URL fiable → placeholder gris avec initiales.
            Container(
              height: 120,
              width: double.infinity,
              color: AppColors.surfaceSoft,
              alignment: Alignment.center,
              child: Text(
                _initiales(vendeur.farmerId),
                style: AppTextStyles.headlineSmall.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Vendeur ${_initiales(vendeur.farmerId)}',
                    style: AppTextStyles.titleSmall.copyWith(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    sousTitre,
                    style: AppTextStyles.bodySmall.copyWith(fontSize: 11),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.star_outline,
                        size: 12,
                        color: AppColors.textSubtle,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '—',
                        style: AppTextStyles.labelSmall.copyWith(
                          fontSize: 11,
                          color: AppColors.textSubtle,
                        ),
                      ),
                    ],
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

// ───────────────────────────────────────────────────────────────────────
//  SECTION "TENDANCES DU MARCHÉ" (bandeau vert pâle)
// ───────────────────────────────────────────────────────────────────────

class _SectionTendance extends StatelessWidget {
  const _SectionTendance({required this.tendance});

  final AiInsightItem? tendance;

  @override
  Widget build(BuildContext context) {
    // Fallback statique si pas d'insights backend.
    final titre = (tendance != null && tendance!.titre.isNotEmpty)
        ? tendance!.titre
        : 'Prix du Maïs en hausse';
    final sub = (tendance?.body != null && tendance!.body!.isNotEmpty)
        ? tendance!.body!
        : '+ 8 % cette semaine · achète maintenant';

    return _Section(
      titre: 'Tendances du marché',
      child: Container(
        decoration: BoxDecoration(
          color: _kPrimarySoft,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: AppColors.border,
            width: AppDimens.borderThin,
          ),
        ),
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ───────────────────────────────────────────────────────────────────────
//  SECTION "OUTILS INTELLIGENTS" (grid 2×2 avec photos)
// ───────────────────────────────────────────────────────────────────────

class _SectionOutilsIA extends StatelessWidget {
  const _SectionOutilsIA({
    required this.onAssistant,
    required this.onAlertes,
  });

  final VoidCallback onAssistant;
  final VoidCallback onAlertes;

  @override
  Widget build(BuildContext context) {
    return _Section(
      titre: 'Outils intelligents',
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: _OutilCard(
              photoUrl: _kPhotoAssistantAchat,
              badgeIcon: Icons.chat_bubble_outline,
              titre: 'Assistant achat',
              sousTitre: 'Quel produit, quand acheter, à quel prix',
              onTap: onAssistant,
            ),
          ),
          AppDimens.hGap12,
          Expanded(
            child: _OutilCard(
              photoUrl: _kPhotoAlertesPrix,
              badgeIcon: Icons.trending_up,
              titre: 'Alertes prix',
              sousTitre: 'Sois prévenu quand un produit baisse',
              onTap: onAlertes,
            ),
          ),
        ],
      ),
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
                        child: CachedNetworkImage(
                          imageUrl: photoUrl,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => Container(
                            color: AppColors.surfaceSoft,
                          ),
                          errorWidget: (_, __, ___) => Container(
                            color: AppColors.surfaceSoft,
                          ),
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

// ───────────────────────────────────────────────────────────────────────
//  SECTION (titre + voir tout + child)
// ───────────────────────────────────────────────────────────────────────

class _Section extends StatelessWidget {
  const _Section({
    required this.titre,
    required this.child,
    this.onVoirTout,
  });

  final String titre;
  final Widget child;
  final VoidCallback? onVoirTout;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              titre,
              style: AppTextStyles.titleSmall.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            if (onVoirTout != null)
              InkWell(
                onTap: onVoirTout,
                borderRadius: BorderRadius.circular(AppDimens.radiusS),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 2,
                  ),
                  child: Text(
                    'Voir tout',
                    style: AppTextStyles.link.copyWith(fontSize: 13),
                  ),
                ),
              ),
          ],
        ),
        AppDimens.vGap12,
        child,
      ],
    );
  }
}

// ───────────────────────────────────────────────────────────────────────
//  GRID + CARD ANNONCE
// ───────────────────────────────────────────────────────────────────────

class _AnnoncesGrid extends StatelessWidget {
  const _AnnoncesGrid({
    required this.annonces,
    required this.produitsParId,
    required this.onTap,
  });

  final List<AnnonceVente> annonces;
  final Map<String, Produit> produitsParId;
  final ValueChanged<AnnonceVente> onTap;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: AppDimens.space12,
        mainAxisSpacing: AppDimens.space12,
        mainAxisExtent: 224,
      ),
      itemCount: annonces.length,
      itemBuilder: (context, i) {
        final a = annonces[i];
        return _AnnonceCard(
          annonce: a,
          produitNom: produitsParId[a.produitId]?.nom,
          onTap: () => onTap(a),
        );
      },
    );
  }
}

class _AnnonceCard extends StatelessWidget {
  const _AnnonceCard({
    required this.annonce,
    required this.produitNom,
    required this.onTap,
  });

  final AnnonceVente annonce;
  final String? produitNom;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final photoUrl =
        annonce.photos.isNotEmpty ? annonce.photos.first : null;
    final titreCard = produitNom ?? annonce.titre;

    return InkWell(
      onTap: onTap,
      borderRadius: _kBrCard,
      child: Container(
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
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 104,
              child: _Photo(url: photoUrl),
            ),
            Expanded(
              child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    titreCard,
                    style: AppTextStyles.titleSmall.copyWith(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _vendeurLigne(annonce),
                    style: AppTextStyles.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _formatPrix(annonce.prixParKg),
                    style: AppTextStyles.titleSmall.copyWith(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _disponibiliteLigne(annonce),
                    style: AppTextStyles.labelSmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _vendeurLigne(AnnonceVente a) {
    final region = a.regionId;
    if (region != null && region.isNotEmpty) {
      return 'Vendeur · $region';
    }
    return 'Vendeur';
  }

  String _disponibiliteLigne(AnnonceVente a) {
    final dispo = _formatKg(a.quantiteKg);
    return '$dispo dispo';
  }
}

class _Photo extends StatelessWidget {
  const _Photo({required this.url});

  final String? url;

  @override
  Widget build(BuildContext context) {
    if (url == null || url!.isEmpty) {
      return _PhotoPlaceholder();
    }
    return CachedNetworkImage(
      imageUrl: url!,
      fit: BoxFit.cover,
      placeholder: (_, __) => _PhotoPlaceholder(),
      errorWidget: (_, __, ___) => _PhotoPlaceholder(),
    );
  }
}

class _PhotoPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surfaceSoft,
      alignment: Alignment.center,
      child: Text(
        'Photo',
        style: AppTextStyles.labelSmall.copyWith(
          color: AppColors.textSubtle,
          fontSize: 11,
        ),
      ),
    );
  }
}

// ───────────────────────────────────────────────────────────────────────
//  EMPTY STATES
// ───────────────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onRefresh});

  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      color: AppColors.primary,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          AppDimens.pagePaddingH,
          AppDimens.space48,
          AppDimens.pagePaddingH,
          AppDimens.space24,
        ),
        children: [
          Text(
            'Aucun produit pour le moment',
            style: AppTextStyles.headlineSmall,
            textAlign: TextAlign.center,
          ),
          AppDimens.vGap8,
          Text(
            'Le marché est vide. Reviens dans quelques instants.',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          AppDimens.vGap24,
          Center(
            child: SizedBox(
              height: AppDimens.buttonHeightSmall,
              child: OutlinedButton(
                onPressed: onRefresh,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(
                    color: AppColors.borderStrong,
                    width: AppDimens.borderThin,
                  ),
                  shape: const RoundedRectangleBorder(
                    borderRadius: AppDimens.brButton,
                  ),
                ),
                child: const Text('Actualiser'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptySection extends StatelessWidget {
  const _EmptySection({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.space16,
        vertical: AppDimens.space24,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceSoft,
        borderRadius: _kBrCard,
        border: Border.all(
          color: AppColors.border,
          width: AppDimens.borderThin,
        ),
      ),
      child: Text(
        message,
        style: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.textSecondary,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

// ───────────────────────────────────────────────────────────────────────
//  FORMATAGE & HELPERS
// ───────────────────────────────────────────────────────────────────────

final _nfFr = NumberFormat('#,##0', 'fr_FR');

String _formatPrix(double prix) {
  return '${_nfFr.format(prix.round())} F/kg';
}

String _formatKg(double kg) {
  return '${_nfFr.format(kg.round())} kg';
}

/// Génère 2 lettres depuis un id/nom — utile pour avatar placeholder.
String _initiales(String input) {
  final trimmed = input.trim();
  if (trimmed.isEmpty) return '?';
  final parts = trimmed.split(RegExp(r'[\s\-_]+'))
    ..removeWhere((p) => p.isEmpty);
  if (parts.length >= 2) {
    return (parts[0].substring(0, 1) + parts[1].substring(0, 1)).toUpperCase();
  }
  if (trimmed.length == 1) return trimmed.toUpperCase();
  return trimmed.substring(0, 2).toUpperCase();
}
