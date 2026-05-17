import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../models/annonce_vente.dart';
import '../../../../models/pagination.dart';
import '../../../../models/prevision.dart';
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

/// Catégorie affichée dans le filtre horizontal de la maquette.
class _CategorieFiltre {
  const _CategorieFiltre({required this.label, required this.emoji});
  final String label;
  final String emoji;
}

const List<_CategorieFiltre> _kCategories = [
  _CategorieFiltre(label: 'Tous', emoji: '🌾'),
  _CategorieFiltre(label: 'Céréales', emoji: '🌽'),
  _CategorieFiltre(label: 'Tubercules', emoji: '🥔'),
  _CategorieFiltre(label: 'Fruits', emoji: '🍌'),
  _CategorieFiltre(label: 'Légumes', emoji: '🥬'),
  _CategorieFiltre(label: 'Légumineuses', emoji: '🌰'),
];

const List<String> _kFiltresSecondaires = [
  'Bio',
  'Près de moi',
  'Prix bas',
  'Coop',
  '+ Filtres',
];

/// Mock annonces : aligné mot-à-mot sur la maquette HTML.
class _MockAnnonce {
  const _MockAnnonce({
    required this.id,
    required this.nom,
    required this.vendeur,
    required this.ville,
    required this.prix,
    required this.qte,
    required this.photoUrl,
  });

  final String id;
  final String nom;
  final String vendeur;
  final String ville;
  final String prix;
  final String qte;
  final String photoUrl;
}

const List<_MockAnnonce> _kMockAnnonces = [
  _MockAnnonce(
    id: 'mock-1',
    nom: 'Maïs blanc',
    vendeur: 'Yao Konan',
    ville: 'Yopougon',
    prix: '350 F/kg',
    qte: '500 kg dispo',
    photoUrl:
        'https://images.unsplash.com/photo-1601493700631-2b16ec4b4716?w=400&h=300&fit=crop&auto=format',
  ),
  _MockAnnonce(
    id: 'mock-2',
    nom: 'Manioc frais',
    vendeur: 'Aya N\'Guessan',
    ville: 'Cocody',
    prix: '95 F/kg',
    qte: '1 000 kg dispo',
    photoUrl:
        'https://images.unsplash.com/photo-1574484284002-952d92456975?w=400&h=300&fit=crop&auto=format',
  ),
  _MockAnnonce(
    id: 'mock-3',
    nom: 'Tomate',
    vendeur: 'Marie Yao',
    ville: 'Yopougon',
    prix: '1 200 F/kg',
    qte: '60 kg dispo',
    photoUrl:
        'https://images.unsplash.com/photo-1518977956812-cd3dbadaaf31?w=400&h=300&fit=crop&auto=format',
  ),
  _MockAnnonce(
    id: 'mock-4',
    nom: 'Arachide',
    vendeur: 'COOP-AGRI',
    ville: 'Bouaké',
    prix: '600 F/kg',
    qte: '220 kg dispo',
    photoUrl:
        'https://images.unsplash.com/photo-1567521464027-f127ff144326?w=400&h=300&fit=crop&auto=format',
  ),
  _MockAnnonce(
    id: 'mock-5',
    nom: 'Banane plantain',
    vendeur: 'Mariam Koné',
    ville: 'Cocody',
    prix: '600 F/kg',
    qte: '80 kg dispo',
    photoUrl:
        'https://images.unsplash.com/photo-1488459716781-31db52582fe9?w=400&h=300&fit=crop&auto=format',
  ),
  _MockAnnonce(
    id: 'mock-6',
    nom: 'Igname pilable',
    vendeur: 'Kouamé Bi',
    ville: 'Bouaké',
    prix: '160 F/kg',
    qte: '300 kg dispo',
    photoUrl:
        'https://images.unsplash.com/photo-1574484284002-952d92456975?w=400&h=300&fit=crop&auto=format',
  ),
  _MockAnnonce(
    id: 'mock-7',
    nom: 'Maïs jaune Bio',
    vendeur: 'COOP Lagunes',
    ville: 'Daloa',
    prix: '420 F/kg',
    qte: '800 kg dispo',
    photoUrl:
        'https://images.unsplash.com/photo-1601493700631-2b16ec4b4716?w=400&h=300&fit=crop&auto=format',
  ),
  _MockAnnonce(
    id: 'mock-8',
    nom: 'Tomate cerise',
    vendeur: 'Fatim N.',
    ville: 'Adzopé',
    prix: '1 400 F/kg',
    qte: '25 kg dispo',
    photoUrl:
        'https://images.unsplash.com/photo-1518977956812-cd3dbadaaf31?w=400&h=300&fit=crop&auto=format',
  ),
];

/// Photos rotatives pour les prévisions (l'API n'en renvoie pas).
const List<String> _kPhotosPrevisions = [
  'https://images.unsplash.com/photo-1601493700631-2b16ec4b4716?w=400&h=300&fit=crop&auto=format',
  'https://images.unsplash.com/photo-1574484284002-952d92456975?w=400&h=300&fit=crop&auto=format',
  'https://images.unsplash.com/photo-1518977956812-cd3dbadaaf31?w=400&h=300&fit=crop&auto=format',
  'https://images.unsplash.com/photo-1488459716781-31db52582fe9?w=400&h=300&fit=crop&auto=format',
];

enum _Segment { annonces, previsions }

/// Bundle retourné par le provider d'écran.
class _MarcheData {
  const _MarcheData({required this.annonces, required this.previsions});
  final List<AnnonceVente> annonces;
  final List<Prevision> previsions;
}

final _marcheAcheteurDataProvider =
    FutureProvider.autoDispose<_MarcheData>((ref) async {
  final svc = ref.watch(marketplaceServiceProvider);
  final results = await Future.wait<dynamic>([
    svc.listAnnoncesVente(limit: 20).then<Object?>((v) => v).catchError(
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
  ]);

  final annoncesPage = results[0] as Paginated<AnnonceVente>;
  final previsions = results[1] as List<Prevision>;
  return _MarcheData(annonces: annoncesPage.data, previsions: previsions);
});

/// Onglet Marché de l'acheteur — annonces directes + prévisions à venir.
class MarchePage extends ConsumerStatefulWidget {
  const MarchePage({super.key});

  @override
  ConsumerState<MarchePage> createState() => _MarchePageState();
}

class _MarchePageState extends ConsumerState<MarchePage> {
  _Segment _segment = _Segment.annonces;
  int _categorieIndex = 0; // "Tous" par défaut

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
              cartCount: 2,
              unreadNotifications: 1,
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
                data: (data) => _buildContent(data),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(_MarcheData data) {
    final annoncesCount = data.annonces.isEmpty ? 47 : data.annonces.length;
    final previsionsCount =
        data.previsions.isEmpty ? 12 : data.previsions.length;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 16),
      children: [
        // Segmented control
        _SegmentedControl(
          segment: _segment,
          annoncesCount: annoncesCount,
          previsionsCount: previsionsCount,
          onChanged: (s) => setState(() => _segment = s),
        ),
        const SizedBox(height: 14),

        // Chips catégories
        _ChipsCategories(
          selectedIndex: _categorieIndex,
          onChanged: (i) => setState(() => _categorieIndex = i),
        ),
        const SizedBox(height: 12),

        // Filtres secondaires
        const _FiltresSecondaires(),
        const SizedBox(height: 16),

        // Grille produits
        if (_segment == _Segment.annonces)
          _GridAnnonces(annonces: data.annonces)
        else
          _GridPrevisions(previsions: data.previsions),
      ],
    );
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
    required this.selectedIndex,
    required this.onChanged,
  });

  final int selectedIndex;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 34,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: _kCategories.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final cat = _kCategories[i];
          final active = i == selectedIndex;
          return InkWell(
            onTap: () => onChanged(i),
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
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    cat.emoji,
                    style: const TextStyle(fontSize: 13),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    cat.label,
                    style: AppTextStyles.labelMedium.copyWith(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color:
                          active ? AppColors.onPrimary : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
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
  const _GridAnnonces({required this.annonces});

  final List<AnnonceVente> annonces;

  @override
  Widget build(BuildContext context) {
    // Si le backend renvoie de la donnée, on l'utilise. Sinon : mock fidèle.
    final useBackend = annonces.isNotEmpty;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        mainAxisExtent: 220,
      ),
      itemCount: useBackend
          ? annonces.length
          : _kMockAnnonces.length,
      itemBuilder: (context, i) {
        if (useBackend) {
          final a = annonces[i];
          final photo = a.photos.isNotEmpty
              ? a.photos.first
              : _kMockAnnonces[i % _kMockAnnonces.length].photoUrl;
          return _AnnonceCard(
            id: a.id,
            nom: a.titre,
            vendeur: 'Vendeur',
            ville: a.regionId ?? 'CI',
            prix: _formatPrix(a.prixParKg),
            qte: '${_formatKg(a.quantiteKg)} dispo',
            photoUrl: photo,
          );
        }
        final m = _kMockAnnonces[i];
        return _AnnonceCard(
          id: m.id,
          nom: m.nom,
          vendeur: m.vendeur,
          ville: m.ville,
          prix: m.prix,
          qte: m.qte,
          photoUrl: m.photoUrl,
        );
      },
    );
  }
}

class _AnnonceCard extends StatelessWidget {
  const _AnnonceCard({
    required this.id,
    required this.nom,
    required this.vendeur,
    required this.ville,
    required this.prix,
    required this.qte,
    required this.photoUrl,
  });

  final String id;
  final String nom;
  final String vendeur;
  final String ville;
  final String prix;
  final String qte;
  final String photoUrl;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () =>
          context.push(RouteNames.acheteurAnnonceDetailPathFor(id)),
      borderRadius: _kBrCard,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: _kBrCard,
          border: Border.all(color: AppColors.border, width: AppDimens.borderThin),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 118,
              child: CachedNetworkImage(
                imageUrl: photoUrl,
                fit: BoxFit.cover,
                placeholder: (_, _) => Container(color: AppColors.surfaceSoft),
                errorWidget: (_, _, _) =>
                    Container(color: AppColors.surfaceSoft),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(11, 9, 11, 11),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      nom,
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
                      '$vendeur · $ville',
                      style: AppTextStyles.bodySmall.copyWith(
                        fontSize: 11,
                        height: 1.3,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      prix,
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
                      qte,
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

// ─── Grille prévisions ─────────────────────────────────────────────────

class _GridPrevisions extends StatelessWidget {
  const _GridPrevisions({required this.previsions});

  final List<Prevision> previsions;

  @override
  Widget build(BuildContext context) {
    final useBackend = previsions.isNotEmpty;
    final mockCount = 6;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        mainAxisExtent: 220,
      ),
      itemCount: useBackend ? previsions.length : mockCount,
      itemBuilder: (context, i) {
        if (useBackend) {
          final p = previsions[i];
          final photo = _kPhotosPrevisions[i % _kPhotosPrevisions.length];
          final dateStr = p.dateRecoltePrev != null
              ? 'Dispo ${DateFormat('d MMM', 'fr_FR').format(p.dateRecoltePrev!)}'
              : 'Dispo bientôt';
          return _AnnonceCard(
            id: p.id,
            nom: 'Prévision',
            vendeur: 'Producteur',
            ville: dateStr,
            prix: p.prixCibleKg != null
                ? '${_formatPrix(p.prixCibleKg!)} prévu'
                : 'Prix à venir',
            qte: '${_formatKg(p.quantitePrevKg)} prévus',
            photoUrl: photo,
          );
        }
        // Mock prévisions
        final m = _kMockAnnonces[i];
        return _AnnonceCard(
          id: 'prev-${i + 1}',
          nom: m.nom,
          vendeur: m.vendeur,
          ville: 'Dispo 15 juin',
          prix: '${m.prix} prévu',
          qte: m.qte,
          photoUrl: m.photoUrl,
        );
      },
    );
  }
}

// ─── Formatage ─────────────────────────────────────────────────────────

final _nf = NumberFormat('#,##0', 'fr_FR');

String _formatPrix(double prix) => '${_nf.format(prix.round())} F/kg';

String _formatKg(double kg) => '${_nf.format(kg.round())} kg';
