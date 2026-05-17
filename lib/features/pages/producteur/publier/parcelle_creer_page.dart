import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

import '../../../../api_client/api_exception.dart';
import '../../../../models/produit.dart';
import '../../../../models/ville.dart';
import '../../../../services/providers.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';
import '../../../widgets/communs/bouton_principal.dart';
import '../../../widgets/communs/chargement.dart';
import '../../../widgets/communs/snackbars.dart';

/// Création d'une parcelle — formulaire identique à la maquette
/// `mockups/producteur/parcelle_creer.html`.
///
/// Sections : Localisation (ville + nom) → Mesure (superficie) →
/// Position GPS → Cultures (multi-select chips). Renvoie la `Parcelle`
/// créée via `pop`.
class ParcelleCreerPage extends ConsumerStatefulWidget {
  const ParcelleCreerPage({super.key});

  @override
  ConsumerState<ParcelleCreerPage> createState() => _ParcelleCreerPageState();
}

class _ParcelleCreerPageState extends ConsumerState<ParcelleCreerPage> {
  final _nomCtrl = TextEditingController();
  final _superficieCtrl = TextEditingController();

  Ville? _selectedVille;
  double? _lat;
  double? _lng;
  bool _capturingGps = false;
  bool _isSubmitting = false;
  String? _errorMessage;

  /// IDs des produits cultivés sur cette parcelle (multi-sélection).
  /// Chacun donne lieu à un `addCulture(...)` après la création,
  /// avec une superficie répartie équitablement.
  final Set<String> _selectedProduitIds = {};

  @override
  void initState() {
    super.initState();
    _nomCtrl.addListener(_onAnyChange);
    _superficieCtrl.addListener(_onAnyChange);
  }

  @override
  void dispose() {
    _nomCtrl.dispose();
    _superficieCtrl.dispose();
    super.dispose();
  }

  void _onAnyChange() {
    if (mounted) setState(() {});
  }

  double? get _superficieValeur {
    final raw = _superficieCtrl.text.trim().replaceAll(',', '.');
    if (raw.isEmpty) return null;
    final v = double.tryParse(raw);
    if (v == null || v <= 0) return null;
    return v;
  }

  bool get _canSubmit {
    if (_isSubmitting) return false;
    if (_selectedVille == null) return false;
    if (_superficieValeur == null) return false;
    if (_lat == null || _lng == null) return false;
    return true;
  }

  // ── GPS ───────────────────────────────────────────────────────────────

  Future<void> _capturerPosition() async {
    if (_capturingGps) return;
    setState(() => _capturingGps = true);
    try {
      final serviceOk = await Geolocator.isLocationServiceEnabled();
      if (!serviceOk) {
        if (mounted) {
          Snackbars.showErreur(
            context,
            'Active la localisation de ton téléphone et réessaye.',
          );
        }
        return;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        if (mounted) {
          Snackbars.showErreur(
            context,
            'Accès à la position refusé. Active-le dans les réglages.',
          );
        }
        return;
      }

      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      if (!mounted) return;
      setState(() {
        _lat = pos.latitude;
        _lng = pos.longitude;
      });
    } catch (_) {
      if (mounted) {
        Snackbars.showErreur(
          context,
          'Impossible de récupérer ta position. Réessaye.',
        );
      }
    } finally {
      if (mounted) setState(() => _capturingGps = false);
    }
  }

  // ── Submit ────────────────────────────────────────────────────────────

  Future<void> _enregistrer() async {
    if (!_canSubmit) return;
    final ville = _selectedVille!;
    final saisieNom = _nomCtrl.text.trim();
    final nomFinal = saisieNom.isEmpty ? 'Champ de ${ville.nom}' : saisieNom;
    final superficieTotale = _superficieValeur!;

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });
    try {
      final svc = ref.read(marketplaceServiceProvider);
      final parcelle = await svc.createParcelle(
        nom: nomFinal,
        superficieHa: superficieTotale,
        produitId: null,
        lat: _lat,
        lng: _lng,
        villeId: ville.id,
      );

      var allCulturesOk = true;
      if (_selectedProduitIds.isNotEmpty) {
        final ids = _selectedProduitIds.toList(growable: false);
        final superficieParCulture = superficieTotale / ids.length;
        final results = await Future.wait(
          ids.map(
            (produitId) => svc
                .addCulture(
                  parcelleId: parcelle.id,
                  produitId: produitId,
                  superficieHa: superficieParCulture,
                )
                .then<Object?>((c) => c)
                .catchError((Object _) => null),
          ),
        );
        allCulturesOk = !results.contains(null);
      }

      if (!mounted) return;
      if (!allCulturesOk) {
        Snackbars.showInfo(
          context,
          'Parcelle créée mais certaines cultures n\'ont pas été '
          'enregistrées. Réessaye depuis l\'écran "Mes parcelles".',
        );
      }
      Navigator.of(context).pop(parcelle);
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _errorMessage = e.message);
      Snackbars.showErreur(context, e.message);
    } catch (_) {
      if (!mounted) return;
      setState(() => _errorMessage = 'Impossible de créer la parcelle.');
      Snackbars.showErreur(context, 'Impossible de créer la parcelle.');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        toolbarHeight: 64,
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, size: AppDimens.iconL),
          onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Créer une parcelle',
              style: AppTextStyles.titleMedium.copyWith(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Enregistre un nouveau champ',
              style: AppTextStyles.bodySmall.copyWith(
                fontSize: 12,
                color: AppColors.textSecondary,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppDimens.pagePaddingH,
                  AppDimens.space16,
                  AppDimens.pagePaddingH,
                  AppDimens.space16,
                ),
                children: [
                  // ═══ Localisation ═════════════════════════════════
                  const _SectionTitle('Localisation'),
                  AppDimens.vGap12,
                  _ChampLabel(
                    label: 'Ville',
                    child: _VilleSelect(
                      initial: _selectedVille,
                      enabled: !_isSubmitting,
                      onSelected: (v) => setState(() => _selectedVille = v),
                    ),
                  ),
                  const SizedBox(height: 14),
                  _ChampLabel(
                    label: 'Nom du champ',
                    child: TextField(
                      controller: _nomCtrl,
                      enabled: !_isSubmitting,
                      textCapitalization: TextCapitalization.sentences,
                      maxLength: 100,
                      decoration: const InputDecoration(
                        hintText: 'Optionnel — auto-généré sinon',
                        counterText: '',
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ═══ Mesure ═══════════════════════════════════════
                  const _SectionTitle('Mesure'),
                  AppDimens.vGap12,
                  _ChampLabel(
                    label: 'Superficie',
                    child: TextField(
                      controller: _superficieCtrl,
                      enabled: !_isSubmitting,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                      ],
                      decoration: const InputDecoration(
                        hintText: '0',
                        suffixText: 'ha',
                        suffixStyle: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Ex. 0.5 ha ≈ 50m × 100m',
                    style: AppTextStyles.bodySmall.copyWith(
                      fontSize: 11,
                      color: AppColors.textSubtle,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ═══ Position GPS ═════════════════════════════════
                  const _SectionTitle('Position GPS'),
                  AppDimens.vGap12,
                  _BoutonGpsSoft(
                    lat: _lat,
                    lng: _lng,
                    isLoading: _capturingGps,
                    enabled: !_isSubmitting,
                    onTap: _capturerPosition,
                  ),
                  const SizedBox(height: 20),

                  // ═══ Cultures ═════════════════════════════════════
                  const _SectionTitle('Quelles cultures se trouvent ici ?'),
                  AppDimens.vGap8,
                  Text(
                    'Sélectionne les produits que tu cultives',
                    style: AppTextStyles.bodySmall.copyWith(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  AppDimens.vGap12,
                  _GrilleCulturesProduits(
                    selectedIds: _selectedProduitIds,
                    enabled: !_isSubmitting,
                    onToggle: (id) {
                      setState(() {
                        if (_selectedProduitIds.contains(id)) {
                          _selectedProduitIds.remove(id);
                        } else {
                          _selectedProduitIds.add(id);
                        }
                      });
                    },
                  ),

                  if (_errorMessage != null) ...[
                    AppDimens.vGap16,
                    Text(_errorMessage!, style: AppTextStyles.errorText),
                  ],
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppDimens.pagePaddingH,
                AppDimens.space12,
                AppDimens.pagePaddingH,
                AppDimens.space16,
              ),
              child: BoutonPrincipal(
                label: 'Enregistrer ma parcelle',
                isLoading: _isSubmitting,
                enabled: _canSubmit,
                onPressed: _canSubmit ? _enregistrer : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
// Composants locaux
// ═══════════════════════════════════════════════════════════════════════

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: AppTextStyles.titleSmall.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: AppColors.text,
      ),
    );
  }
}

class _ChampLabel extends StatelessWidget {
  const _ChampLabel({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 6),
        child,
      ],
    );
  }
}

/// Bouton "Capturer ma position" plein largeur, style soft vert
/// (fond `#E8F5E9`, bordure et texte verts) tel que maquette.
class _BoutonGpsSoft extends StatelessWidget {
  const _BoutonGpsSoft({
    required this.lat,
    required this.lng,
    required this.isLoading,
    required this.enabled,
    required this.onTap,
  });

  final double? lat;
  final double? lng;
  final bool isLoading;
  final bool enabled;
  final VoidCallback onTap;

  static const Color _softBg = Color(0xFFE8F5E9);

  @override
  Widget build(BuildContext context) {
    final captured = lat != null && lng != null;
    return InkWell(
      onTap: enabled && !isLoading ? onTap : null,
      borderRadius: AppDimens.brInput,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          color: _softBg,
          borderRadius: AppDimens.brInput,
          border: Border.all(
            color: AppColors.primary,
            width: AppDimens.borderThin,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isLoading)
              const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2.2,
                  color: AppColors.primary,
                ),
              )
            else
              Icon(
                captured ? Icons.check_circle_outline : Icons.my_location,
                size: 18,
                color: AppColors.primary,
              ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                captured
                    ? 'lat: ${lat!.toStringAsFixed(4)} · '
                        'lng: ${lng!.toStringAsFixed(4)}'
                    : 'Capturer ma position',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
// Catalogue produits + grille chips multi-sélection
// ═══════════════════════════════════════════════════════════════════════

final _produitsRefProvider = FutureProvider<List<Produit>>((ref) async {
  return ref.watch(marketplaceServiceProvider).listProduits();
});

class _GrilleCulturesProduits extends ConsumerWidget {
  const _GrilleCulturesProduits({
    required this.selectedIds,
    required this.enabled,
    required this.onToggle,
  });

  final Set<String> selectedIds;
  final bool enabled;
  final ValueChanged<String> onToggle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(_produitsRefProvider);
    return async.when(
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: AppDimens.space8),
        child: Chargement(size: 18),
      ),
      error: (_, _) => Text(
        'Impossible de charger les produits.',
        style: AppTextStyles.bodySmall.copyWith(color: AppColors.error),
      ),
      data: (produits) {
        if (produits.isEmpty) {
          return Text(
            'Aucun produit disponible.',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          );
        }
        return Wrap(
          spacing: AppDimens.space8,
          runSpacing: AppDimens.space8,
          children: [
            for (final p in produits)
              _ChipCultureProduit(
                label: p.nom,
                selected: selectedIds.contains(p.id),
                enabled: enabled,
                onTap: () => onToggle(p.id),
              ),
          ],
        );
      },
    );
  }
}

class _ChipCultureProduit extends StatelessWidget {
  const _ChipCultureProduit({
    required this.label,
    required this.selected,
    required this.enabled,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: const BorderRadius.all(Radius.circular(14)),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.surface,
          borderRadius: const BorderRadius.all(Radius.circular(14)),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
            width: AppDimens.borderThin,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: AppTextStyles.labelMedium.copyWith(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: selected ? AppColors.onPrimary : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
// Sélecteur ville (style maquette : icône pin cerclée + label + chevron)
// ═══════════════════════════════════════════════════════════════════════

final _villesRefProvider = FutureProvider<List<Ville>>((ref) async {
  return ref.watch(marketplaceServiceProvider).listVilles();
});

class _VilleSelect extends ConsumerStatefulWidget {
  const _VilleSelect({
    required this.initial,
    required this.enabled,
    required this.onSelected,
  });

  final Ville? initial;
  final bool enabled;
  final ValueChanged<Ville> onSelected;

  @override
  ConsumerState<_VilleSelect> createState() => _VilleSelectState();
}

class _VilleSelectState extends ConsumerState<_VilleSelect> {
  Ville? _ville;

  @override
  void initState() {
    super.initState();
    _ville = widget.initial;
  }

  Future<void> _ouvrir() async {
    FocusScope.of(context).unfocus();
    final villes = await ref.read(_villesRefProvider.future);
    if (!mounted) return;
    final selected = await showModalBottomSheet<Ville>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: AppDimens.brBottomSheet,
      ),
      builder: (_) => _SelectionVilleSheet(
        villes: villes,
        initialId: _ville?.id,
      ),
    );
    if (selected != null && mounted) {
      setState(() => _ville = selected);
      widget.onSelected(selected);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasValeur = _ville != null;
    return InkWell(
      onTap: widget.enabled ? _ouvrir : null,
      borderRadius: AppDimens.brInput,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: AppDimens.brInput,
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
              decoration: const BoxDecoration(
                color: Color(0xFFE8F5E9),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.location_on_outlined,
                size: 16,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                hasValeur ? _ville!.displayWithRegion : 'Choisir une ville',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: hasValeur ? AppColors.text : AppColors.textSubtle,
                ),
              ),
            ),
            const Icon(
              Icons.keyboard_arrow_down,
              size: 18,
              color: AppColors.textSubtle,
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
// Bottom sheet sélection ville (recherche)
// ═══════════════════════════════════════════════════════════════════════

class _SelectionVilleSheet extends StatefulWidget {
  const _SelectionVilleSheet({
    required this.villes,
    this.initialId,
  });

  final List<Ville> villes;
  final String? initialId;

  @override
  State<_SelectionVilleSheet> createState() => _SelectionVilleSheetState();
}

class _SelectionVilleSheetState extends State<_SelectionVilleSheet> {
  String _query = '';

  List<Ville> get _filtered {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return widget.villes;
    return widget.villes
        .where((v) =>
            v.nom.toLowerCase().contains(q) ||
            (v.regionNom?.toLowerCase().contains(q) ?? false))
        .toList(growable: false);
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
                  AppDimens.space16,
                  AppDimens.space24,
                  AppDimens.space12,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Choisir une ville',
                      style: AppTextStyles.titleLarge,
                    ),
                    AppDimens.vGap12,
                    TextField(
                      autofocus: true,
                      onChanged: (v) => setState(() => _query = v),
                      decoration: const InputDecoration(
                        hintText: 'Rechercher une ville',
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    final items = _filtered;
    if (items.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(AppDimens.space24),
        child: Text(
          'Aucune ville trouvée.',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: AppDimens.space8),
      itemCount: items.length,
      separatorBuilder: (_, _) => const Divider(
        height: 1,
        thickness: AppDimens.borderThin,
        color: AppColors.border,
      ),
      itemBuilder: (ctx, i) {
        final v = items[i];
        final isCurrent = widget.initialId == v.id;
        return ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppDimens.space24,
            vertical: 2,
          ),
          title: Text(v.displayWithRegion, style: AppTextStyles.titleSmall),
          trailing: isCurrent
              ? const Icon(
                  Icons.check,
                  size: AppDimens.iconM,
                  color: AppColors.primary,
                )
              : null,
          onTap: () => Navigator.of(context).pop(v),
        );
      },
    );
  }
}
