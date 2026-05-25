import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../models/traitement.dart';
import '../../../../services/providers.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';
import '../../../widgets/communs/chargement.dart';
import '../../../widgets/communs/vue_erreur.dart';
import '../../../widgets/producteur/ai/catalogue_traitements_constants.dart';
import '../../../widgets/producteur/ai/empty_catalogue_traitements.dart';
import '../../../widgets/producteur/ai/filtres_catalogue_traitements.dart';
import '../../../widgets/producteur/ai/traitement_card_catalogue.dart';

/// Référentiel des traitements proposés par l'IA.
///
/// Filtres : type via chip (catalogue backend), switch "Bio uniquement"
/// (filtre `is_bio=true` sur produits compatibles agriculture bio),
/// barre de recherche par maladie (debounce 300 ms).
class CatalogueTraitementsPage extends ConsumerStatefulWidget {
  const CatalogueTraitementsPage({super.key});

  @override
  ConsumerState<CatalogueTraitementsPage> createState() =>
      _CatalogueTraitementsPageState();
}

class _CatalogueTraitementsPageState
    extends ConsumerState<CatalogueTraitementsPage> {
  final TextEditingController _searchCtrl = TextEditingController();
  Timer? _debounce;
  FilterTypeCatalogueTraitements _type = FilterTypeCatalogueTraitements.tous;
  bool _bioOnly = false;
  String _searchQuery = '';
  late Future<List<Traitement>> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<List<Traitement>> _load() {
    return ref.read(aiServiceProvider).listTreatments(
          type: filterTypeToApiCatalogueTraitements(_type),
          isBio: _bioOnly ? true : null,
          maladie: _searchQuery.isEmpty ? null : _searchQuery,
        );
  }

  void _reload() {
    setState(() => _future = _load());
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      setState(() {
        _searchQuery = value.trim();
        _future = _load();
      });
    });
  }

  void _onTypeChanged(FilterTypeCatalogueTraitements type) {
    setState(() {
      _type = type;
      _future = _load();
    });
  }

  void _onBioChanged(bool value) {
    setState(() {
      _bioOnly = value;
      _future = _load();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: const BackButton(color: AppColors.text),
        title: Text(
          'Traitements',
          style: AppTextStyles.titleSmall.copyWith(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: false,
      ),
      body: Column(
        children: [
          FiltresCatalogueTraitements(
            type: _type,
            bioOnly: _bioOnly,
            searchCtrl: _searchCtrl,
            onTypeChanged: _onTypeChanged,
            onBioChanged: _onBioChanged,
            onSearchChanged: _onSearchChanged,
          ),
          Expanded(
            child: FutureBuilder<List<Traitement>>(
              future: _future,
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.only(top: AppDimens.space32),
                    child: Chargement(size: 22),
                  );
                }
                if (snap.hasError) {
                  return Padding(
                    padding: const EdgeInsets.all(AppDimens.pagePaddingH),
                    child: VueErreur(
                      message: 'Impossible de charger les traitements.',
                      onRetry: _reload,
                    ),
                  );
                }
                final items = snap.data ?? const <Traitement>[];
                if (items.isEmpty) return const EmptyCatalogueTraitements();
                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(
                    AppDimens.pagePaddingH,
                    AppDimens.space8,
                    AppDimens.pagePaddingH,
                    AppDimens.space24,
                  ),
                  itemCount: items.length,
                  separatorBuilder: (_, _) => AppDimens.vGap12,
                  itemBuilder: (_, i) =>
                      TraitementCardCatalogue(traitement: items[i]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
