import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/cooperative.dart';
import '../../../services/providers.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_dimens.dart';
import '../../../theme/app_text_styles.dart';
import '../communs/chargement.dart';

/// Sélecteur de coopérative — déclencheur d'input + bottom sheet de recherche.
///
/// Visuel aligné DESIGN.md : hauteur 50, radius 10, bordure 1px (vert au tap).
/// Sobriété stricte : pas d'ombre, pas de halo, deux couleurs (vert + gris).
class SelecteurCoop extends ConsumerStatefulWidget {
  const SelecteurCoop({
    required this.onSelected,
    this.selectedCoopId,
    this.enabled = true,
    this.label = 'Coopérative (optionnel)',
    super.key,
  });

  final String? selectedCoopId;
  final ValueChanged<Cooperative?> onSelected;
  final bool enabled;
  final String label;

  @override
  ConsumerState<SelecteurCoop> createState() => _SelecteurCoopState();
}

class _SelecteurCoopState extends ConsumerState<SelecteurCoop> {
  Cooperative? _selected;

  @override
  void initState() {
    super.initState();
    _hydrateSelected();
  }

  @override
  void didUpdateWidget(covariant SelecteurCoop oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedCoopId != widget.selectedCoopId) {
      _hydrateSelected();
    }
  }

  Future<void> _hydrateSelected() async {
    final id = widget.selectedCoopId;
    if (id == null || id.isEmpty) {
      if (mounted) setState(() => _selected = null);
      return;
    }
    if (_selected?.id == id) return;
    try {
      final coop =
          await ref.read(cooperativesServiceProvider).getPublic(id);
      if (!mounted) return;
      setState(() => _selected = coop);
    } catch (_) {
      // Si l'hydratation échoue silencieusement, on garde l'état vide :
      // l'utilisateur pourra toujours en choisir une autre.
    }
  }

  Future<void> _ouvrirBottomSheet() async {
    if (!widget.enabled) return;
    FocusScope.of(context).unfocus();
    final result = await showModalBottomSheet<_CoopChoice>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: AppDimens.brBottomSheet,
      ),
      builder: (ctx) => _SelecteurCoopBottomSheet(initial: _selected),
    );

    if (result == null) return; // dismissed
    if (result.clear) {
      setState(() => _selected = null);
      widget.onSelected(null);
      return;
    }
    setState(() => _selected = result.coop);
    widget.onSelected(result.coop);
  }

  @override
  Widget build(BuildContext context) {
    final hasSelection = _selected != null;
    final placeholderColor =
        widget.enabled ? AppColors.textSubtle : AppColors.textSubtle;
    final valueColor =
        widget.enabled ? AppColors.text : AppColors.textSecondary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.label, style: AppTextStyles.labelMedium),
        AppDimens.vGap8,
        InkWell(
          onTap: widget.enabled ? _ouvrirBottomSheet : null,
          borderRadius: AppDimens.brInput,
          child: Container(
            height: AppDimens.inputHeight,
            padding: const EdgeInsets.symmetric(horizontal: 14),
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
                Expanded(
                  child: Text(
                    hasSelection
                        ? _selected!.nom
                        : 'Sélectionner une coopérative',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: hasSelection ? valueColor : placeholderColor,
                      fontWeight:
                          hasSelection ? FontWeight.w500 : FontWeight.w400,
                    ),
                  ),
                ),
                const Icon(
                  Icons.keyboard_arrow_down,
                  size: AppDimens.iconM,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Résultat renvoyé par le bottom sheet — soit une coop, soit un clear.
class _CoopChoice {
  const _CoopChoice.select(this.coop) : clear = false;
  const _CoopChoice.clear()
      : coop = null,
        clear = true;

  final Cooperative? coop;
  final bool clear;
}

class _SelecteurCoopBottomSheet extends ConsumerStatefulWidget {
  const _SelecteurCoopBottomSheet({this.initial});

  final Cooperative? initial;

  @override
  ConsumerState<_SelecteurCoopBottomSheet> createState() =>
      _SelecteurCoopBottomSheetState();
}

class _SelecteurCoopBottomSheetState
    extends ConsumerState<_SelecteurCoopBottomSheet> {
  final TextEditingController _searchCtrl = TextEditingController();
  Timer? _debounce;

  bool _loading = true;
  String? _error;
  List<Cooperative> _results = const [];

  @override
  void initState() {
    super.initState();
    _fetch(null);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _fetch(String? query) async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final list = await ref
          .read(cooperativesServiceProvider)
          .listPublic(search: (query ?? '').trim().isEmpty ? null : query);
      if (!mounted) return;
      setState(() {
        _results = list;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Impossible de charger les coopératives.';
        _loading = false;
      });
    }
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      _fetch(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    return Padding(
      padding: EdgeInsets.only(bottom: mq.viewInsets.bottom),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: mq.size.height * 0.75,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppDimens.space24,
                  AppDimens.space8,
                  AppDimens.space24,
                  AppDimens.space12,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Coopérative',
                      style: AppTextStyles.titleLarge,
                    ),
                    AppDimens.vGap12,
                    TextField(
                      controller: _searchCtrl,
                      autofocus: false,
                      onChanged: _onSearchChanged,
                      textInputAction: TextInputAction.search,
                      decoration: const InputDecoration(
                        hintText: 'Rechercher une coopérative',
                        prefixIcon: Icon(
                          Icons.search,
                          color: AppColors.textSecondary,
                          size: AppDimens.iconM,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(
                height: 1,
                thickness: AppDimens.borderThin,
                color: AppColors.border,
              ),
              Expanded(child: _buildBody()),
              const Divider(
                height: 1,
                thickness: AppDimens.borderThin,
                color: AppColors.border,
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppDimens.space24,
                  AppDimens.space12,
                  AppDimens.space24,
                  AppDimens.space16,
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(
                      const _CoopChoice.clear(),
                    ),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      'Aucune coopérative',
                      style: AppTextStyles.link,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Padding(
        padding: EdgeInsets.all(AppDimens.space24),
        child: Chargement(size: 18),
      );
    }
    if (_error != null) {
      return Padding(
        padding: const EdgeInsets.all(AppDimens.space24),
        child: Text(
          _error!,
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.error),
        ),
      );
    }
    if (_results.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(AppDimens.space24),
        child: Text(
          'Aucune coopérative trouvée',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: AppDimens.space8),
      itemCount: _results.length,
      separatorBuilder: (_, __) => const Divider(
        height: 1,
        thickness: AppDimens.borderThin,
        color: AppColors.border,
      ),
      itemBuilder: (ctx, i) {
        final coop = _results[i];
        final isCurrent = widget.initial?.id == coop.id;
        return ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppDimens.space24,
            vertical: 2,
          ),
          title: Text(
            coop.nom,
            style: AppTextStyles.titleSmall,
          ),
          subtitle: (coop.regionId != null && coop.regionId!.isNotEmpty)
              ? Text(
                  coop.regionId!,
                  style: AppTextStyles.bodySmall,
                )
              : null,
          trailing: isCurrent
              ? const Icon(
                  Icons.check,
                  size: AppDimens.iconM,
                  color: AppColors.primary,
                )
              : null,
          onTap: () => Navigator.of(context).pop(
            _CoopChoice.select(coop),
          ),
        );
      },
    );
  }
}
