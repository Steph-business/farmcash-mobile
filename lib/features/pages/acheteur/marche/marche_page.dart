import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../models/annonce_vente.dart';
import '../../../../models/enums.dart';
import '../../../../models/pagination.dart';
import '../../../../models/prevision.dart';
import '../../../../models/produit.dart';
import '../../../../services/providers.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../widgets/acheteur/marche/barre_recherche_marche.dart';
import '../../../widgets/acheteur/marche/chips_categories_marche.dart';
import '../../../widgets/acheteur/marche/controle_segmente_marche.dart';
import '../../../widgets/acheteur/marche/filtres_secondaires_marche.dart';
import '../../../widgets/acheteur/marche/grille_annonces_marche.dart';
import '../../../widgets/acheteur/marche/grille_previsions_marche.dart';
import '../../../widgets/acheteur/marche/sheet_filtres_avances_marche.dart';
import '../../../widgets/communs/chargement.dart';
import '../../../widgets/communs/entete_page_compacte_acheteur.dart';
import '../../../widgets/communs/vue_erreur.dart';

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
  SegmentMarche _segment = SegmentMarche.annonces;
  // `null` = "Tous"
  String? _categorieIdSelectionnee;

  // ─── État filtres secondaires ────────────────────────────────────────
  final Set<FiltreSecondaire> _filtres = {};

  // ─── État filtres avancés (sheet "+ Filtres") ─────────────────────────
  TriMarche _tri = TriMarche.recent;
  ProductQuality? _qualite;
  double? _prixMaxKg;

  void _toggleFiltre(FiltreSecondaire f) {
    setState(() {
      if (_filtres.contains(f)) {
        _filtres.remove(f);
      } else {
        _filtres.add(f);
      }
    });
  }

  Future<void> _ouvrirFiltresAvances() async {
    final resultat = await showModalBottomSheet<ResultatFiltresAvances>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => SheetFiltresAvancesMarche(
        triInitial: _tri,
        qualiteInitiale: _qualite,
        prixMaxInitial: _prixMaxKg,
      ),
    );
    if (resultat == null) return;
    setState(() {
      _tri = resultat.tri;
      _qualite = resultat.qualite;
      _prixMaxKg = resultat.prixMaxKg;
    });
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(_marcheAcheteurDataProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // En-tête compact (back + « Marché » + 🛒 + 🔔) — même
            // style que Messages et Commandes pour cohérence visuelle.
            const EntetePageCompacteAcheteur(title: 'Marché'),
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 4, 20, AppDimens.space12),
              child: BarreRechercheMarche(),
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
    final annoncesFiltrees = _appliquerFiltres(
      _filtrerParCategorie(data.annonces, data),
    );

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 16),
      children: [
        ControleSegmenteMarche(
          segment: _segment,
          nbAnnonces: annoncesFiltrees.length,
          nbPrevisions: data.previsions.length,
          onChanged: (s) => setState(() => _segment = s),
        ),
        const SizedBox(height: 14),
        ChipsCategoriesMarche(
          categories: data.categories,
          selectionId: _categorieIdSelectionnee,
          onChanged: (id) => setState(() => _categorieIdSelectionnee = id),
        ),
        const SizedBox(height: 12),
        FiltresSecondairesMarche(
          selection: _filtres,
          onToggle: _toggleFiltre,
          onPlusFiltres: _ouvrirFiltresAvances,
        ),
        const SizedBox(height: 16),
        if (_segment == SegmentMarche.annonces)
          GrilleAnnoncesMarche(
            annonces: annoncesFiltrees,
            produitsParId: data.produitsParId,
          )
        else
          GrillePrevisionsMarche(
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

  /// Applique successivement les filtres secondaires (Bio, Près de moi,
  /// Prix bas, Coop) et les filtres avancés (qualité, prix max, tri).
  List<AnnonceVente> _appliquerFiltres(List<AnnonceVente> annonces) {
    var resultat = annonces;

    // Bio (chip ou qualité Bio dans la sheet).
    if (_filtres.contains(FiltreSecondaire.bio)) {
      resultat = resultat.where(_estBio).toList(growable: false);
    }

    // Près de moi : V1 sans regionId profil → garde les annonces ayant
    // une localisation renseignée (région ou ville). Sera affiné quand
    // le user aura un regionId persisté.
    if (_filtres.contains(FiltreSecondaire.presDeMoi)) {
      resultat = resultat
          .where((a) =>
              (a.regionNom?.trim().isNotEmpty ?? false) ||
              (a.villeNom?.trim().isNotEmpty ?? false))
          .toList(growable: false);
    }

    // Coop : annonce assignée à une coop.
    if (_filtres.contains(FiltreSecondaire.coop)) {
      resultat = resultat
          .where((a) =>
              (a.assignedToCooperativeId?.isNotEmpty ?? false))
          .toList(growable: false);
    }

    // Filtre qualité (sheet avancée).
    if (_qualite != null) {
      resultat = resultat
          .where((a) => a.qualite == _qualite)
          .toList(growable: false);
    }

    // Filtre prix max (sheet avancée).
    final plafond = _prixMaxKg;
    if (plafond != null) {
      resultat = resultat
          .where((a) => a.prixParKg <= plafond)
          .toList(growable: false);
    }

    // Tri (le chip "Prix bas" force prix croissant, sinon on respecte
    // le tri choisi dans la sheet).
    final triEffectif = _filtres.contains(FiltreSecondaire.prixBas)
        ? TriMarche.prixCroissant
        : _tri;
    resultat = _trier(resultat, triEffectif);

    return resultat;
  }

  bool _estBio(AnnonceVente a) {
    if (a.qualite == ProductQuality.bio) return true;
    for (final c in a.certifications) {
      final lower = c.toLowerCase();
      if (lower.contains('bio') || lower.contains('organic')) return true;
    }
    return false;
  }

  List<AnnonceVente> _trier(
    List<AnnonceVente> annonces,
    TriMarche tri,
  ) {
    final copie = [...annonces];
    switch (tri) {
      case TriMarche.recent:
        copie.sort((a, b) {
          final da = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
          final db = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
          return db.compareTo(da);
        });
      case TriMarche.prixCroissant:
        copie.sort((a, b) => a.prixParKg.compareTo(b.prixParKg));
      case TriMarche.prixDecroissant:
        copie.sort((a, b) => b.prixParKg.compareTo(a.prixParKg));
      case TriMarche.quantite:
        copie.sort((a, b) => b.quantiteKg.compareTo(a.quantiteKg));
    }
    return copie;
  }
}
