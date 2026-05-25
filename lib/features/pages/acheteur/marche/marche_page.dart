import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../models/annonce_vente.dart';
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
import '../../../widgets/communs/chargement.dart';
import '../../../widgets/communs/header_utilisateur.dart';
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
              bottomChild: BarreRechercheMarche(),
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
        const FiltresSecondairesMarche(),
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
}
