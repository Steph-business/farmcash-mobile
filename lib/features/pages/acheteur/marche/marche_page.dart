import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../models/annonce_vente.dart';
import '../../../../models/pagination.dart';
import '../../../../models/prevision.dart';
import '../../../../models/produit.dart';
import '../../../../routing/route_names.dart';
import '../../../../services/providers.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';
import '../../../widgets/communs/chargement.dart';
import '../../../widgets/communs/header_utilisateur.dart';
import '../../../widgets/communs/vue_erreur.dart';

// ─── Constantes locales ────────────────────────────────────────────────

const BorderRadius _kBrCard = BorderRadius.all(Radius.circular(12));

const List<String> _kFiltresSecondaires = [
  'Bio',
  'Près de moi',
  'Prix bas',
  'Coop',
  '+ Filtres',
];

enum _Segment { annonces, previsions }

/// Bundle retourné par le provider d'écran : annonces + prévisions + le
/// catalogue produit (pour résoudre `produit_id` côté prévisions, et pour
/// les chips de filtre catégorie).
class _MarcheData {
  const _MarcheData({
    required this.annonces,
    required this.previsions,
    required this.produitsParId,
    required this.categories,
  });
  final List<AnnonceVente> annonces;
  final List<Prevision> previsions;
  final Map<String, Produit> produitsParId;
  final List<Categorie> categories;
}

final _marcheAcheteurDataProvider =
    FutureProvider.autoDispose<_MarcheData>((ref) async {
  final svc = ref.watch(marketplaceServiceProvider);
  final results = await Future.wait<dynamic>([
    svc.listAnnoncesVente(limit: 40).then<Object?>((v) => v).catchError(
          (_) => const Paginated<AnnonceVente>(
            data: [],
            total: 0,
            page: 1,
            limit: 0,
            totalPages: 0,
          ),
        ),
    svc.listPrevisions().then<Object?>((v) => v).catchError(
          (_) => const <Prevision>[],
        ),
    svc.listProduits().then<Object?>((v) => v).catchError(
          (_) => const <Produit>[],
        ),
    svc.listCategories().then<Object?>((v) => v).catchError(
          (_) => const <Categorie>[],
        ),
  ]);

  final annoncesPage = results[0] as Paginated<AnnonceVente>;
  final previsions = results[1] as List<Prevision>;
  final produits = results[2] as List<Produit>;
  final categories = results[3] as List<Categorie>;
  final produitsParId = <String, Produit>{
    for (final p in produits) p.id: p,
  };
  return _MarcheData(
    annonces: annoncesPage.data,
    previsions: previsions,
    produitsParId: produitsParId,
    categories: categories,
  );
});

/// Onglet Marché de l'acheteur — annonces directes + prévisions à venir.
class MarchePage extends ConsumerStatefulWidget {
  const MarchePage({super.key});

  @override
  ConsumerState<MarchePage> createState() => _MarchePageState();
}

class _MarchePageState extends ConsumerState<MarchePage> {
  _Segment _segment = _Segment.annonces;
  // `null` = "Tous"
  String? _categorieIdSelectionnee;

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(_marcheAcheteurDataProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const HeaderUtilisateur(
              variant: HeaderVariant.acheteur,
              bottomChild: _SearchBar(),
            ),
            Expanded(
              child: async.when(
                loading: () => const Padding(
                  padding: EdgeInsets.only(top: 48),
                  child: Chargement(size: 22),
                ),
                error: (e, _) => Padding(
                  padding: const EdgeInsets.all(AppDimens.pagePaddingH),
                  child: VueErreur(
                    message: 'Impossible de charger le marché. $e',
                    onRetry: () =>
                        ref.invalidate(_marcheAcheteurDataProvider),
                  ),
                ),
                data: (data) => RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: () async {
                    ref.invalidate(_marcheAcheteurDataProvider);
                    await ref.read(_marcheAcheteurDataProvider.future);
                  },
                  child: _buildContent(data),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(_MarcheData data) {
    final annoncesFiltrees = _filtrerParCategorie(data.annonces, data);

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 16),
      children: [
        _SegmentedControl(
          segment: _segment,
          annoncesCount: annoncesFiltrees.length,
          previsionsCount: data.previsions.length,
          onChanged: (s) => setState(() => _segment = s),
        ),
        const SizedBox(height: 14),
        _ChipsCategories(
          categories: data.categories,
          selectionId: _categorieIdSelectionnee,
          onChanged: (id) => setState(() => _categorieIdSelectionnee = id),
        ),
        const SizedBox(height: 12),
        const _FiltresSecondaires(),
        const SizedBox(height: 16),
        if (_segment == _Segment.annonces)
          _GridAnnonces(
            annonces: annoncesFiltrees,
            produitsParId: data.produitsParId,
          )
        else
          _GridPrevisions(
            previsions: data.previsions,
            produitsParId: data.produitsParId,
          ),
      ],
    );
  }

  List<AnnonceVente> _filtrerParCategorie(
    List<AnnonceVente> annonces,
    _MarcheData data,
  ) {
    if (_categorieIdSelectionnee == null) return annonces;
    final cat = data.categories.firstWhere(
      (c) => c.id == _categorieIdSelectionnee,
      orElse: () => const Categorie(id: '', slug: '', nom: ''),
    );
    if (cat.id.isEmpty) return annonces;
    final sousCategoriesIds = cat.sousCategories.map((sc) => sc.id).toSet();
    return annonces.where((a) {
      final p = data.produitsParId[a.produitId];
      return p?.sousCategorieId != null &&
          sousCategoriesIds.contains(p!.sousCategorieId);
    }).toList(growable: false);
  }
}

// ─── Search bar ─────────────────────────────────────────────────────────

class _SearchBar extends StatelessWidget {
  const _SearchBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: AppColors.surfaceSoft,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.borderStrong,
          width: AppDimens.borderThin,
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.search, size: 18, color: AppColors.textSubtle),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Rechercher un produit, un vendeur…',
              style: AppTextStyles.bodySmall.copyWith(
                fontSize: 13,
                color: AppColors.textSubtle,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Segmented control ──────────────────────────────────────────────────

class _SegmentedControl extends StatelessWidget {
  const _SegmentedControl({
    required this.segment,
    required this.annoncesCount,
    required this.previsionsCount,
    required this.onChanged,
  });

  final _Segment segment;
  final int annoncesCount;
  final int previsionsCount;
  final ValueChanged<_Segment> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surfaceSoft,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: AppDimens.borderThin),
      ),
      child: Row(
        children: [
          Expanded(
            child: _SegmentItem(
              label: 'Annonces directes ($annoncesCount)',
              active: segment == _Segment.annonces,
              onTap: () => onChanged(_Segment.annonces),
            ),
          ),
          Expanded(
            child: _SegmentItem(
              label: 'Prévisions à venir ($previsionsCount)',
              active: segment == _Segment.previsions,
              onTap: () => onChanged(_Segment.previsions),
            ),
          ),
        ],
      ),
    );
  }
}

class _SegmentItem extends StatelessWidget {
  const _SegmentItem({
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
      borderRadius: BorderRadius.circular(9),
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(vertical: 9),
        decoration: BoxDecoration(
          color: active ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(9),
        ),
        child: Text(
          label,
          style: AppTextStyles.labelMedium.copyWith(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: active ? AppColors.onPrimary : AppColors.textSecondary,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}

// ─── Chips catégories ──────────────────────────────────────────────────

class _ChipsCategories extends StatelessWidget {
  const _ChipsCategories({
    required this.categories,
    required this.selectionId,
    required this.onChanged,
  });

  final List<Categorie> categories;
  final String? selectionId;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    final items = <_ChipData>[
      const _ChipData(label: 'Tous', value: null),
      ...categories.map((c) => _ChipData(label: c.nom, value: c.id)),
    ];

    return SizedBox(
      height: 34,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: items.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final it = items[i];
          final active = it.value == selectionId;
          return InkWell(
            onTap: () => onChanged(it.value),
            borderRadius: BorderRadius.circular(18),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: active ? AppColors.primary : AppColors.background,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: active ? AppColors.primary : AppColors.border,
                  width: AppDimens.borderThin,
                ),
              ),
              child: Text(
                it.label,
                style: AppTextStyles.labelMedium.copyWith(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color:
                      active ? AppColors.onPrimary : AppColors.textSecondary,
                ),
              ),
            ),
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

// ─── Filtres secondaires ───────────────────────────────────────────────

class _FiltresSecondaires extends StatelessWidget {
  const _FiltresSecondaires();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 30,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: _kFiltresSecondaires.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: AppColors.surfaceSoft,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: AppColors.border,
                width: AppDimens.borderThin,
              ),
            ),
            child: Text(
              _kFiltresSecondaires[i],
              style: AppTextStyles.labelMedium.copyWith(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.text,
              ),
            ),
          );
        },
      ),
    );
  }
}

// ─── Grille annonces ──────────────────────────────────────────────────

class _GridAnnonces extends StatelessWidget {
  const _GridAnnonces({
    required this.annonces,
    required this.produitsParId,
  });

  final List<AnnonceVente> annonces;
  final Map<String, Produit> produitsParId;

  @override
  Widget build(BuildContext context) {
    if (annonces.isEmpty) {
      return _EmptyMarche(
        message: 'Aucune annonce disponible pour le moment.',
      );
    }
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        mainAxisExtent: 270,
      ),
      itemCount: annonces.length,
      itemBuilder: (context, i) {
        final a = annonces[i];
        final nomProduit = a.produitNom ?? produitsParId[a.produitId]?.nom;
        return _AnnonceCard(
          annonce: a,
          nomProduit: nomProduit,
          onTap: () =>
              context.push(RouteNames.acheteurAnnonceDetailPathFor(a.id)),
        );
      },
    );
  }
}

class _AnnonceCard extends StatelessWidget {
  const _AnnonceCard({
    required this.annonce,
    required this.nomProduit,
    required this.onTap,
  });

  final AnnonceVente annonce;
  final String? nomProduit;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final photoUrl =
        annonce.photos.isNotEmpty ? annonce.photos.first : null;
    final titre = nomProduit ?? annonce.titre;
    final vendeur = annonce.vendeurNom ?? 'Vendeur';
    final loc = annonce.localisationLabel ?? '—';
    final publie = annonce.createdAt;
    final publieLigne = publie != null
        ? 'Publié ${DateFormat('d MMM', 'fr_FR').format(publie)}'
        : null;

    return InkWell(
      onTap: onTap,
      borderRadius: _kBrCard,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.background,
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
              height: 110,
              child: _CardPhoto(url: photoUrl),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(11, 9, 11, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titre,
                      style: AppTextStyles.titleSmall.copyWith(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        height: 1.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      vendeur,
                      style: AppTextStyles.bodySmall.copyWith(
                        fontSize: 11,
                        height: 1.3,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          size: 11,
                          color: AppColors.textSubtle,
                        ),
                        const SizedBox(width: 3),
                        Expanded(
                          child: Text(
                            loc,
                            style: AppTextStyles.labelSmall.copyWith(
                              fontSize: 10,
                              color: AppColors.textSubtle,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _formatPrix(annonce.prixParKg),
                      style: AppTextStyles.titleSmall.copyWith(
                        fontFamily: 'Poppins',
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      '${_formatKg(annonce.quantiteKg)} dispo',
                      style: AppTextStyles.labelSmall.copyWith(
                        fontSize: 10,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    if (publieLigne != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        publieLigne,
                        style: AppTextStyles.labelSmall.copyWith(
                          fontSize: 9,
                          color: AppColors.textSubtle,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Grille prévisions ─────────────────────────────────────────────────

class _GridPrevisions extends StatelessWidget {
  const _GridPrevisions({
    required this.previsions,
    required this.produitsParId,
  });

  final List<Prevision> previsions;
  final Map<String, Produit> produitsParId;

  @override
  Widget build(BuildContext context) {
    if (previsions.isEmpty) {
      return _EmptyMarche(
        message:
            'Aucune prévision pour le moment — reviens dans quelques jours.',
      );
    }
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        mainAxisExtent: 230,
      ),
      itemCount: previsions.length,
      itemBuilder: (context, i) {
        final p = previsions[i];
        final nomProduit = produitsParId[p.produitId]?.nom ?? 'Prévision';
        return _PrevisionCard(
          prevision: p,
          nomProduit: nomProduit,
          onTap: () =>
              context.push(RouteNames.acheteurPrevisionDetailPathFor(p.id)),
        );
      },
    );
  }
}

class _PrevisionCard extends StatelessWidget {
  const _PrevisionCard({
    required this.prevision,
    required this.nomProduit,
    required this.onTap,
  });

  final Prevision prevision;
  final String nomProduit;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final dateStr = prevision.dateRecoltePrev != null
        ? 'Récolte ${DateFormat('d MMM', 'fr_FR').format(prevision.dateRecoltePrev!)}'
        : 'Récolte à venir';
    final prix = prevision.prixCibleKg != null
        ? '${_formatPrix(prevision.prixCibleKg!)} (prévu)'
        : 'Prix à venir';

    return InkWell(
      onTap: onTap,
      borderRadius: _kBrCard,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.background,
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
              height: 100,
              child: Container(
                color: AppColors.surfaceSoft,
                alignment: Alignment.center,
                child: const Icon(
                  Icons.event_available_outlined,
                  size: 32,
                  color: AppColors.primary,
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(11, 9, 11, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      nomProduit,
                      style: AppTextStyles.titleSmall.copyWith(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      dateStr,
                      style: AppTextStyles.bodySmall.copyWith(fontSize: 11),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      prix,
                      style: AppTextStyles.titleSmall.copyWith(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      '${_formatKg(prevision.quantitePrevKg)} prévus',
                      style: AppTextStyles.labelSmall.copyWith(
                        fontSize: 10,
                        color: AppColors.textSecondary,
                      ),
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
}

// ─── Helpers visuels ───────────────────────────────────────────────────

class _CardPhoto extends StatelessWidget {
  const _CardPhoto({required this.url});
  final String? url;

  @override
  Widget build(BuildContext context) {
    if (url == null || url!.isEmpty) {
      return Container(
        color: AppColors.surfaceSoft,
        alignment: Alignment.center,
        child: const Icon(
          Icons.image_outlined,
          size: 28,
          color: AppColors.textSubtle,
        ),
      );
    }
    return CachedNetworkImage(
      imageUrl: url!,
      fit: BoxFit.cover,
      placeholder: (_, _) => Container(color: AppColors.surfaceSoft),
      errorWidget: (_, _, _) => Container(color: AppColors.surfaceSoft),
    );
  }
}

class _EmptyMarche extends StatelessWidget {
  const _EmptyMarche({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
      decoration: BoxDecoration(
        color: AppColors.surfaceSoft,
        borderRadius: _kBrCard,
        border: Border.all(
          color: AppColors.border,
          width: AppDimens.borderThin,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.storefront_outlined,
            size: 32,
            color: AppColors.textSubtle,
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ─── Formatage ─────────────────────────────────────────────────────────

final _nf = NumberFormat('#,##0', 'fr_FR');

String _formatPrix(double prix) => '${_nf.format(prix.round())} F/kg';

String _formatKg(double kg) => '${_nf.format(kg.round())} kg';
