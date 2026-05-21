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

const Color _kPrimarySoft = Color(0xFFE8F5E9);

enum _FilterType { tous, bio, chimique, naturel }

/// Référentiel des traitements proposés par l'IA.
///
/// Filtres : type (BIO/CHIMIQUE/NATUREL via chip), switch "Bio uniquement",
/// barre de recherche par maladie (debounce 300 ms côté UI → call
/// `listTreatments(maladie: q)` quand la query n'est pas vide).
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
  _FilterType _type = _FilterType.tous;
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
    final type = switch (_type) {
      _FilterType.tous => null,
      _FilterType.bio => 'BIO',
      _FilterType.chimique => 'CHIMIQUE',
      _FilterType.naturel => 'NATUREL',
    };
    return ref.read(aiServiceProvider).listTreatments(
          type: type,
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

  void _onTypeChanged(_FilterType type) {
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
          _Filtres(
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
                if (items.isEmpty) return const _EmptyState();
                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(
                    AppDimens.pagePaddingH,
                    AppDimens.space8,
                    AppDimens.pagePaddingH,
                    AppDimens.space24,
                  ),
                  itemCount: items.length,
                  separatorBuilder: (_, _) => AppDimens.vGap12,
                  itemBuilder: (_, i) => _TraitementCard(traitement: items[i]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _Filtres extends StatelessWidget {
  const _Filtres({
    required this.type,
    required this.bioOnly,
    required this.searchCtrl,
    required this.onTypeChanged,
    required this.onBioChanged,
    required this.onSearchChanged,
  });

  final _FilterType type;
  final bool bioOnly;
  final TextEditingController searchCtrl;
  final ValueChanged<_FilterType> onTypeChanged;
  final ValueChanged<bool> onBioChanged;
  final ValueChanged<String> onSearchChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppDimens.pagePaddingH,
        AppDimens.space12,
        AppDimens.pagePaddingH,
        AppDimens.space8,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search bar
          TextField(
            controller: searchCtrl,
            onChanged: onSearchChanged,
            style: AppTextStyles.bodyMedium,
            decoration: InputDecoration(
              hintText: 'Rechercher par maladie (mildiou, pyrale…)',
              hintStyle: AppTextStyles.hint,
              filled: true,
              fillColor: AppColors.surface,
              prefixIcon: const Icon(
                Icons.search,
                color: AppColors.textSubtle,
                size: 20,
              ),
              suffixIcon: searchCtrl.text.isEmpty
                  ? null
                  : IconButton(
                      icon: const Icon(
                        Icons.close,
                        color: AppColors.textSubtle,
                        size: 18,
                      ),
                      onPressed: () {
                        searchCtrl.clear();
                        onSearchChanged('');
                      },
                    ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 0,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: AppDimens.brInput,
                borderSide: const BorderSide(
                  color: AppColors.borderStrong,
                  width: AppDimens.borderThin,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: AppDimens.brInput,
                borderSide: const BorderSide(
                  color: AppColors.primary,
                  width: AppDimens.borderThin,
                ),
              ),
            ),
          ),
          AppDimens.vGap12,
          // Type chips horizontaux
          SizedBox(
            height: 32,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _TypeChip(
                  label: 'Tous',
                  active: type == _FilterType.tous,
                  onTap: () => onTypeChanged(_FilterType.tous),
                ),
                const SizedBox(width: 8),
                _TypeChip(
                  label: 'Bio',
                  active: type == _FilterType.bio,
                  onTap: () => onTypeChanged(_FilterType.bio),
                ),
                const SizedBox(width: 8),
                _TypeChip(
                  label: 'Chimique',
                  active: type == _FilterType.chimique,
                  onTap: () => onTypeChanged(_FilterType.chimique),
                ),
                const SizedBox(width: 8),
                _TypeChip(
                  label: 'Naturel',
                  active: type == _FilterType.naturel,
                  onTap: () => onTypeChanged(_FilterType.naturel),
                ),
              ],
            ),
          ),
          AppDimens.vGap8,
          Row(
            children: [
              Text(
                'Bio uniquement',
                style: AppTextStyles.labelMedium.copyWith(fontSize: 13),
              ),
              const Spacer(),
              Switch(
                value: bioOnly,
                onChanged: onBioChanged,
                activeThumbColor: AppColors.primary,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TypeChip extends StatelessWidget {
  const _TypeChip({
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
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: active ? _kPrimarySoft : AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: active ? AppColors.primary : AppColors.borderStrong,
            width: AppDimens.borderThin,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: AppTextStyles.labelMedium.copyWith(
            fontSize: 13,
            fontWeight: active ? FontWeight.w600 : FontWeight.w500,
            color: active ? AppColors.primary : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _TraitementCard extends StatelessWidget {
  const _TraitementCard({required this.traitement});

  final Traitement traitement;

  @override
  Widget build(BuildContext context) {
    final maladies = traitement.maladies;
    final produits = traitement.produits;
    final type = traitement.type?.trim();
    return InkWell(
      onTap: () => _showDetail(context),
      borderRadius: AppDimens.brCard,
      child: Container(
        padding: const EdgeInsets.all(AppDimens.space12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppDimens.brCard,
          border: Border.all(
            color: AppColors.border,
            width: AppDimens.borderThin,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    traitement.nom,
                    style: AppTextStyles.titleSmall.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (type != null && type.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  _TypeBadge(type: type, isBio: traitement.isBio),
                ],
              ],
            ),
            if (maladies.isNotEmpty) ...[
              AppDimens.vGap8,
              Text(
                'Maladies : ${maladies.join(", ")}',
                style: AppTextStyles.bodySmall.copyWith(fontSize: 12),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            if (produits.isNotEmpty) ...[
              AppDimens.vGap4,
              Text(
                'Cultures : ${produits.join(", ")}',
                style: AppTextStyles.bodySmall.copyWith(fontSize: 12),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: 4),
          ],
        ),
      ),
    );
  }

  void _showDetail(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (_) => _TraitementDetailDialog(traitement: traitement),
    );
  }
}

class _TypeBadge extends StatelessWidget {
  const _TypeBadge({required this.type, required this.isBio});

  final String type;
  final bool isBio;

  @override
  Widget build(BuildContext context) {
    final upper = type.toUpperCase();
    final (bg, fg) = isBio
        ? (_kPrimarySoft, AppColors.primary)
        : (AppColors.surfaceSoft, AppColors.textSecondary);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        upper,
        style: AppTextStyles.labelSmall.copyWith(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: fg,
        ),
      ),
    );
  }
}

class _TraitementDetailDialog extends StatelessWidget {
  const _TraitementDetailDialog({required this.traitement});

  final Traitement traitement;

  @override
  Widget build(BuildContext context) {
    final description = traitement.description?.trim();
    final dosage = traitement.dosage?.trim();
    final mode = traitement.mode?.trim();
    final type = traitement.type?.trim();
    final maladies = traitement.maladies;
    final produits = traitement.produits;
    return Dialog(
      shape: const RoundedRectangleBorder(borderRadius: AppDimens.brCard),
      backgroundColor: AppColors.surface,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimens.space16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      traitement.nom,
                      style: AppTextStyles.titleLarge.copyWith(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  if (type != null && type.isNotEmpty) ...[
                    const SizedBox(width: 8),
                    _TypeBadge(type: type, isBio: traitement.isBio),
                  ],
                ],
              ),
              if (description != null && description.isNotEmpty) ...[
                AppDimens.vGap12,
                Text(description, style: AppTextStyles.bodyMedium),
              ],
              if (dosage != null && dosage.isNotEmpty) ...[
                AppDimens.vGap12,
                _DetailLine(label: 'Dosage', value: dosage),
              ],
              if (mode != null && mode.isNotEmpty) ...[
                AppDimens.vGap8,
                _DetailLine(label: "Mode d'application", value: mode),
              ],
              if (maladies.isNotEmpty) ...[
                AppDimens.vGap8,
                _DetailLine(
                  label: 'Maladies traitées',
                  value: maladies.join(', '),
                ),
              ],
              if (produits.isNotEmpty) ...[
                AppDimens.vGap8,
                _DetailLine(
                  label: 'Cultures concernées',
                  value: produits.join(', '),
                ),
              ],
              AppDimens.vGap16,
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Fermer'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailLine extends StatelessWidget {
  const _DetailLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.labelMedium.copyWith(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 2),
        Text(value, style: AppTextStyles.bodyMedium),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimens.space24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.science_outlined,
              size: 40,
              color: AppColors.textSubtle.withValues(alpha: 0.9),
            ),
            const SizedBox(height: AppDimens.space12),
            Text(
              'Aucun traitement trouvé',
              style: AppTextStyles.titleSmall,
            ),
            AppDimens.vGap4,
            Text(
              'Modifie les filtres ou la recherche pour voir plus de résultats.',
              style: AppTextStyles.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
