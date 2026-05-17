import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../../../api_client/api_exception.dart';
import '../../../../models/enums.dart';
import '../../../../models/parcelle.dart';
import '../../../../routing/route_names.dart';
import '../../../../services/providers.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';
import '../../../state/auth_state.dart';
import '../../../widgets/communs/bouton_principal.dart';
import '../../../widgets/communs/chargement.dart';
import '../../../widgets/communs/snackbars.dart';

/// Publier une annonce de vente — flow producteur (FARMER).
///
/// 2 pages dans un PageView :
///   1. Détails (parcelle, produit, qualité, quantité, prix, dispo).
///   2. Photos (max 5) + audience (public ou ma coop).
///
/// Pré-requis : au moins 1 parcelle. Sinon on pousse `parcelle_creer_page`
/// d'abord ; si l'utilisateur abandonne, on quitte ce flow.
class PublierAnnoncePage extends ConsumerStatefulWidget {
  const PublierAnnoncePage({super.key});

  @override
  ConsumerState<PublierAnnoncePage> createState() =>
      _PublierAnnoncePageState();
}

class _PublierAnnoncePageState extends ConsumerState<PublierAnnoncePage> {
  final PageController _pageController = PageController();
  int _pageIndex = 0;

  // ── Données chargées (bootstrap) ───────────────────────────────────────
  bool _loading = true;
  List<Parcelle> _parcelles = const [];

  // ── Page 1 ─────────────────────────────────────────────────────────────
  Parcelle? _parcelle;
  Culture? _culture;
  ProductQuality _qualite = ProductQuality.standard;
  final _quantiteCtrl = TextEditingController();
  final _prixCtrl = TextEditingController();
  DateTime? _dispoJusqu;

  // ── Page 2 ─────────────────────────────────────────────────────────────
  final List<File> _photos = [];
  final _titreCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();
  bool _audienceCoop = false;

  // ── Type de publication (segmented control étape 1) ───────────────────
  /// `false` = "Annonce immédiate" (par défaut, fonctionnel).
  /// `true` = "Prévision future" (à venir — feedback snackbar pour l'instant).
  bool _estPrevision = false;

  // ── État submit ────────────────────────────────────────────────────────
  bool _isSubmitting = false;

  static const int _maxPhotos = 5;

  @override
  void initState() {
    super.initState();
    _quantiteCtrl.addListener(_onAnyChange);
    _prixCtrl.addListener(_onAnyChange);
    _titreCtrl.addListener(_onAnyChange);
    _descriptionCtrl.addListener(_onAnyChange);
    WidgetsBinding.instance.addPostFrameCallback((_) => _bootstrap());
  }

  @override
  void dispose() {
    _pageController.dispose();
    _quantiteCtrl.dispose();
    _prixCtrl.dispose();
    _titreCtrl.dispose();
    _descriptionCtrl.dispose();
    super.dispose();
  }

  void _onAnyChange() {
    if (mounted) setState(() {});
  }

  // ── Bootstrap : on garantit au moins 1 parcelle ───────────────────────
  Future<void> _bootstrap() async {
    try {
      final parcelles =
          await ref.read(marketplaceServiceProvider).listParcelles();
      if (!mounted) return;
      if (parcelles.isEmpty) {
        final created = await context
            .push<Parcelle>(RouteNames.producteurCreerParcellePath);
        if (!mounted) return;
        if (created == null) {
          // l'utilisateur a abandonné la création — on quitte le flow.
          Navigator.of(context).pop();
          return;
        }
        _parcelles = [created];
      } else {
        _parcelles = parcelles;
      }

      // Présélection si on n'a qu'une parcelle. La culture, elle, est
      // toujours choisie manuellement par l'utilisateur (cascade via le
      // sélecteur dédié page 1).
      final autoParcelle = _parcelles.length == 1 ? _parcelles.first : null;

      if (!mounted) return;
      setState(() {
        _parcelle = autoParcelle;
        _loading = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      Snackbars.showErreur(context, e.message);
      Navigator.of(context).pop();
    } catch (_) {
      if (!mounted) return;
      Snackbars.showErreur(
        context,
        'Impossible de charger tes parcelles.',
      );
      Navigator.of(context).pop();
    }
  }

  // ── Validations & helpers ──────────────────────────────────────────────

  double? get _quantiteValeur {
    final raw = _quantiteCtrl.text.trim().replaceAll(',', '.');
    if (raw.isEmpty) return null;
    final v = double.tryParse(raw);
    if (v == null || v <= 0) return null;
    return v;
  }

  double? get _prixValeur {
    final raw = _prixCtrl.text.trim().replaceAll(',', '.');
    if (raw.isEmpty) return null;
    final v = double.tryParse(raw);
    if (v == null || v <= 0) return null;
    return v;
  }

  bool get _page1Valid {
    if (_parcelle == null) return false;
    if (_culture == null) return false;
    if (_quantiteValeur == null) return false;
    if (_prixValeur == null) return false;
    return true;
  }

  bool get _canPublier {
    if (_isSubmitting) return false;
    if (!_page1Valid) return false;
    return true;
  }

  // ── Sélecteurs ─────────────────────────────────────────────────────────

  Future<void> _choisirCulture() async {
    final parcelle = _parcelle;
    if (parcelle == null) return;
    FocusScope.of(context).unfocus();
    final selected = await showModalBottomSheet<Culture>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: AppDimens.brBottomSheet,
      ),
      builder: (_) => _SelectionCultureSheet(
        parcelleId: parcelle.id,
        initialId: _culture?.id,
      ),
    );
    if (selected != null && mounted) {
      setState(() => _culture = selected);
    }
  }

  Future<void> _ouvrirMesParcelles() async {
    if (!mounted) return;
    Navigator.of(context).pop();
    if (!mounted) return;
    context.push(RouteNames.producteurMesParcellesPath);
  }

  Future<void> _choisirDate() async {
    FocusScope.of(context).unfocus();
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _dispoJusqu ?? now.add(const Duration(days: 14)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      locale: const Locale('fr', 'FR'),
    );
    if (picked != null && mounted) {
      setState(() => _dispoJusqu = picked);
    }
  }

  // ── Photos ─────────────────────────────────────────────────────────────

  Future<void> _ajouterPhoto() async {
    if (_photos.length >= _maxPhotos) return;
    FocusScope.of(context).unfocus();

    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: AppDimens.brBottomSheet,
      ),
      builder: (ctx) {
        return SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppDimens.vGap8,
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimens.space24,
                  vertical: AppDimens.space8,
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Ajouter une photo',
                    style: AppTextStyles.titleLarge,
                  ),
                ),
              ),
              const Divider(
                height: 1,
                thickness: AppDimens.borderThin,
                color: AppColors.border,
              ),
              ListTile(
                leading: const Icon(
                  Icons.photo_camera_outlined,
                  color: AppColors.primary,
                  size: AppDimens.iconL,
                ),
                title: Text(
                  'Prendre une photo',
                  style: AppTextStyles.titleSmall,
                ),
                onTap: () => Navigator.of(ctx).pop(ImageSource.camera),
              ),
              const Divider(
                height: 1,
                thickness: AppDimens.borderThin,
                color: AppColors.border,
              ),
              ListTile(
                leading: const Icon(
                  Icons.photo_library_outlined,
                  color: AppColors.primary,
                  size: AppDimens.iconL,
                ),
                title: Text(
                  'Choisir dans la galerie',
                  style: AppTextStyles.titleSmall,
                ),
                onTap: () => Navigator.of(ctx).pop(ImageSource.gallery),
              ),
              AppDimens.vGap8,
            ],
          ),
        );
      },
    );

    if (source == null || !mounted) return;
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: source,
        maxWidth: 1600,
        imageQuality: 80,
      );
      if (picked == null || !mounted) return;
      setState(() => _photos.add(File(picked.path)));
    } catch (_) {
      if (mounted) {
        Snackbars.showErreur(context, 'Impossible d\'ajouter la photo.');
      }
    }
  }

  void _supprimerPhoto(int index) {
    setState(() => _photos.removeAt(index));
  }

  // ── Navigation pages ──────────────────────────────────────────────────

  void _suivant() {
    if (!_page1Valid) {
      Snackbars.showErreur(
        context,
        'Remplis tous les champs requis pour continuer.',
      );
      return;
    }
    FocusScope.of(context).unfocus();
    _pageController.nextPage(
      duration: AppDimens.durationNormal,
      curve: Curves.easeOut,
    );
  }

  void _precedent() {
    FocusScope.of(context).unfocus();
    _pageController.previousPage(
      duration: AppDimens.durationNormal,
      curve: Curves.easeOut,
    );
  }

  // ── Publication ────────────────────────────────────────────────────────

  Future<void> _publier() async {
    if (!_canPublier) return;
    final user = ref.read(currentUserProvider);
    final culture = _culture;
    final quantite = _quantiteValeur;
    final prix = _prixValeur;
    if (culture == null || quantite == null || prix == null) return;

    setState(() => _isSubmitting = true);

    try {
      // 1) GPS — obligatoire pour le back (champ `coordinates`).
      final serviceOk = await Geolocator.isLocationServiceEnabled();
      if (!serviceOk) {
        if (mounted) {
          Snackbars.showErreur(
            context,
            'Active la localisation de ton téléphone.',
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

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      final svc = ref.read(marketplaceServiceProvider);

      // 2) Titre — auto-généré si vide. Le nom du produit vient de la
      //    culture (jointure backend) ; fallback "Produit" si absent.
      final produitNom = culture.produitNom ?? 'Produit';
      final titreSaisi = _titreCtrl.text.trim();
      final titre = titreSaisi.isEmpty
          ? '$produitNom ${_libelleQualite(_qualite)} — '
                '${_formatNombre(quantite)}kg'
          : titreSaisi;

      final description = _descriptionCtrl.text.trim();

      // 3) Cible coop (si demandé ET membre d'une coop).
      final coopId = (_audienceCoop && user?.cooperativeId != null)
          ? user!.cooperativeId
          : null;

      // 4) Création de l'annonce — `produitId` vient de la culture
      //    sélectionnée (cascade parcelle → culture → produit).
      final annonce = await svc.createAnnonceVente(
        produitId: culture.produitId,
        titre: titre,
        quantiteKg: quantite,
        prixParKg: prix,
        lat: position.latitude,
        lng: position.longitude,
        qualite: _qualite,
        description: description.isEmpty ? null : description,
        disponibleJusqu: _dispoJusqu,
        assignedToCooperativeId: coopId,
      );

      // 5) Upload des photos en séquentiel — on continue même si l'une
      //    échoue, mais on signale l'erreur globalement à la fin.
      var photosOk = true;
      for (final file in _photos) {
        try {
          await svc.uploadAnnonceMedia(file: file, annonceId: annonce.id);
        } catch (_) {
          photosOk = false;
        }
      }

      if (!mounted) return;
      if (!photosOk) {
        Snackbars.showInfo(
          context,
          'Annonce publiée. Certaines photos n\'ont pas pu être ajoutées.',
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Annonce publiée avec succès !'),
          ),
        );
      }
      Navigator.of(context).pop();
    } on ApiException catch (e) {
      if (!mounted) return;
      Snackbars.showErreur(context, e.message);
    } catch (e) {
      if (!mounted) return;
      Snackbars.showErreur(context, 'Erreur : $e');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_isSubmitting,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          elevation: 0,
          scrolledUnderElevation: 0,
          toolbarHeight: 64,
          titleSpacing: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, size: AppDimens.iconL),
            onPressed: _isSubmitting
                ? null
                : () {
                    if (_pageIndex == 1) {
                      _precedent();
                    } else {
                      Navigator.of(context).pop();
                    }
                  },
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _pageIndex == 0 ? 'Publier' : 'Publier · 2/2',
                style: AppTextStyles.titleMedium.copyWith(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                _pageIndex == 0
                    ? 'Étape 1 sur 2'
                    : 'Photos & audience',
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
          child: _loading
              ? const Padding(
                  padding: EdgeInsets.only(top: AppDimens.space32),
                  child: Chargement(size: 22),
                )
              : PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  onPageChanged: (i) => setState(() => _pageIndex = i),
                  children: [
                    _buildPage1(),
                    _buildPage2(),
                  ],
                ),
        ),
      ),
    );
  }

  // ── Page 1 ─────────────────────────────────────────────────────────────

  Widget _buildPage1() {
    final parcelle = _parcelle;
    return Column(
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
              // ═══ Segmented : immédiate / prévision ═══════════════
              _SegmentedToggle(
                leftLabel: 'Annonce immédiate',
                rightLabel: 'Prévision future',
                rightSelected: _estPrevision,
                enabled: !_isSubmitting,
                onChanged: (right) {
                  if (right) {
                    Snackbars.showInfo(
                      context,
                      'Prévision future — à venir prochainement.',
                    );
                    return;
                  }
                  setState(() => _estPrevision = false);
                },
              ),
              const SizedBox(height: 20),

              // ═══ Section : Parcelle & culture ════════════════════
              const _SectionTitle('Parcelle & culture'),
              AppDimens.vGap12,
              _ChampLabel(
                label: 'Parcelle',
                child: _SelecteurMaquette(
                  icon: Icons.location_on_outlined,
                  title: parcelle == null
                      ? 'Choisir une parcelle'
                      : parcelle.nom,
                  subtitle: parcelle == null
                      ? null
                      : _sousTitreParcelle(parcelle),
                  placeholder: parcelle == null,
                  enabled: !_isSubmitting,
                  onTap: () => _choisirParcelleSheet(),
                ),
              ),
              const SizedBox(height: 14),
              _ChampLabel(
                label: 'Culture',
                child: parcelle == null
                    ? _SelecteurMaquette(
                        icon: Icons.eco_outlined,
                        title: 'Choisis d\'abord une parcelle',
                        placeholder: true,
                        enabled: false,
                        onTap: () {},
                      )
                    : _SelecteurCultureMaquette(
                        parcelleId: parcelle.id,
                        culture: _culture,
                        enabled: !_isSubmitting,
                        onTap: _choisirCulture,
                        onOuvrirMesParcelles: _ouvrirMesParcelles,
                      ),
              ),
              const SizedBox(height: 20),

              // ═══ Section : Détails ═══════════════════════════════
              const _SectionTitle('Détails'),
              AppDimens.vGap12,
              _ChampLabel(
                label: 'Qualité',
                child: Wrap(
                  spacing: AppDimens.space8,
                  runSpacing: AppDimens.space8,
                  children: [
                    for (final q in const [
                      ProductQuality.standard,
                      ProductQuality.premium,
                      ProductQuality.bio,
                      ProductQuality.equitable,
                    ])
                      _ChipQualite(
                        label: _libelleQualite(q),
                        selected: _qualite == q,
                        enabled: !_isSubmitting,
                        onTap: () => setState(() => _qualite = q),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              _ChampLabel(
                label: 'Quantité',
                child: TextField(
                  controller: _quantiteCtrl,
                  enabled: !_isSubmitting,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                  ],
                  decoration: const InputDecoration(
                    hintText: '0',
                    suffixText: 'kg',
                    suffixStyle: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              _ChampLabel(
                label: 'Prix par kg',
                child: TextField(
                  controller: _prixCtrl,
                  enabled: !_isSubmitting,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                  ],
                  decoration: const InputDecoration(
                    hintText: '0',
                    suffixText: 'F CFA / kg',
                    suffixStyle: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              _ChampLabel(
                label: 'Disponible jusqu\'au',
                child: _BoutonSelection(
                  placeholder: 'Optionnel — choisir une date',
                  valeur: _dispoJusqu == null
                      ? null
                      : _formatDate(_dispoJusqu!),
                  enabled: !_isSubmitting,
                  onTap: _choisirDate,
                  icon: Icons.calendar_today_outlined,
                ),
              ),
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
            label: 'Suivant',
            enabled: _page1Valid && !_isSubmitting,
            onPressed: _page1Valid && !_isSubmitting ? _suivant : null,
          ),
        ),
      ],
    );
  }

  String _sousTitreParcelle(Parcelle p) {
    final ha = p.superficieHa;
    return ha == null ? 'Superficie inconnue' : '${ha.toStringAsFixed(1)} ha';
  }

  Future<void> _choisirParcelleSheet() async {
    FocusScope.of(context).unfocus();
    final selected = await showModalBottomSheet<Parcelle>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: AppDimens.brBottomSheet,
      ),
      builder: (_) => _SelectionParcelleSheet(
        parcelles: _parcelles,
        initialId: _parcelle?.id,
      ),
    );
    if (selected != null && mounted) {
      setState(() {
        _parcelle = selected;
        _culture = null;
      });
    }
  }

  // ── Page 2 ─────────────────────────────────────────────────────────────

  Widget _buildPage2() {
    final user = ref.watch(currentUserProvider);
    final aDesCoop =
        user?.cooperativeId != null && user!.cooperativeId!.isNotEmpty;

    return Column(
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
              // ═══ Section : Photos ════════════════════════════════
              _SectionTitle('Photos (max $_maxPhotos)'),
              AppDimens.vGap12,
              _GrillePhotos(
                photos: _photos,
                max: _maxPhotos,
                enabled: !_isSubmitting,
                onAdd: _ajouterPhoto,
                onRemove: _supprimerPhoto,
              ),
              const SizedBox(height: 20),

              // ═══ Section : Description ═══════════════════════════
              const _SectionTitle('Description'),
              AppDimens.vGap12,
              _ChampLabel(
                label: 'Titre court',
                child: TextField(
                  controller: _titreCtrl,
                  enabled: !_isSubmitting,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    hintText: 'Auto-généré sinon',
                  ),
                ),
              ),
              const SizedBox(height: 14),
              _ChampLabel(
                label: 'Description',
                child: TextField(
                  controller: _descriptionCtrl,
                  enabled: !_isSubmitting,
                  maxLines: 3,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    hintText:
                        'Optionnel — donne plus de contexte sur ta récolte…',
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // ═══ Section : Publier vers ══════════════════════════
              const _SectionTitle('Publier vers'),
              AppDimens.vGap12,
              _RadioCard(
                children: [
                  _RadioCardItem(
                    emoji: '🌍',
                    title: 'Tout le marché (public)',
                    subtitle: 'Visible par tous les acheteurs',
                    selected: !_audienceCoop,
                    enabled: !_isSubmitting,
                    onTap: () => setState(() => _audienceCoop = false),
                  ),
                  if (aDesCoop)
                    _RadioCardItem(
                      emoji: '🤝',
                      title: 'Ma coopérative',
                      subtitle:
                          'Ta coop valide et agrège avec d\'autres avant publication',
                      selected: _audienceCoop,
                      enabled: !_isSubmitting,
                      onTap: () => setState(() => _audienceCoop = true),
                    ),
                ],
              ),
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
            label: 'Publier mon annonce',
            isLoading: _isSubmitting,
            enabled: _canPublier,
            onPressed: _canPublier ? _publier : null,
          ),
        ),
      ],
    );
  }

  // ── Helpers locaux ────────────────────────────────────────────────────

  static String _libelleQualite(ProductQuality q) {
    switch (q) {
      case ProductQuality.standard:
        return 'Standard';
      case ProductQuality.premium:
        return 'Premium';
      case ProductQuality.bio:
        return 'Bio';
      case ProductQuality.equitable:
        return 'Équitable';
      case ProductQuality.unknown:
        return 'Standard';
    }
  }

  static String _formatNombre(double value) {
    if ((value - value.truncate()).abs() < 0.01) {
      return value.toStringAsFixed(0);
    }
    return value.toStringAsFixed(1);
  }

  static String _formatDate(DateTime d) {
    return DateFormat('dd MMM yyyy', 'fr_FR').format(d);
  }
}

// ─── Composants locaux ─────────────────────────────────────────────────

/// Titre de section bold 14px (style "section-title" des maquettes).
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

/// Segmented control 2 options (maquette publier étape 1).
/// Fond gris léger, item actif fond vert plein + texte blanc.
class _SegmentedToggle extends StatelessWidget {
  const _SegmentedToggle({
    required this.leftLabel,
    required this.rightLabel,
    required this.rightSelected,
    required this.enabled,
    required this.onChanged,
  });

  final String leftLabel;
  final String rightLabel;
  final bool rightSelected;
  final bool enabled;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surfaceSoft,
        borderRadius: AppDimens.brInput,
        border: Border.all(
          color: AppColors.border,
          width: AppDimens.borderThin,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _SegItem(
              label: leftLabel,
              selected: !rightSelected,
              enabled: enabled,
              onTap: () => onChanged(false),
            ),
          ),
          Expanded(
            child: _SegItem(
              label: rightLabel,
              selected: rightSelected,
              enabled: enabled,
              onTap: () => onChanged(true),
            ),
          ),
        ],
      ),
    );
  }
}

class _SegItem extends StatelessWidget {
  const _SegItem({
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
      borderRadius: BorderRadius.circular(9),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(9),
        ),
        child: Text(
          label,
          style: AppTextStyles.labelMedium.copyWith(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: selected ? AppColors.onPrimary : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

/// Sélecteur "select" style maquette : icône carrée verte 36×36 + 2 lignes
/// texte (title + subtitle optionnel) + chevron à droite.
class _SelecteurMaquette extends StatelessWidget {
  const _SelecteurMaquette({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.placeholder,
    required this.enabled,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final bool placeholder;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: enabled ? onTap : null,
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
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: Icon(icon, size: 18, color: AppColors.primary),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: placeholder
                          ? AppColors.textSubtle
                          : AppColors.text,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodySmall.copyWith(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ],
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

/// Card englobante pour les options radio (maquette "Publier vers").
/// Items séparés par un divider interne.
class _RadioCard extends StatelessWidget {
  const _RadioCard({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: AppDimens.brInput,
        border: Border.all(
          color: AppColors.border,
          width: AppDimens.borderThin,
        ),
      ),
      child: Column(
        children: [
          for (var i = 0; i < children.length; i++) ...[
            children[i],
            if (i < children.length - 1)
              const Divider(
                height: 1,
                thickness: AppDimens.borderThin,
                color: AppColors.border,
              ),
          ],
        ],
      ),
    );
  }
}

/// Une option radio dans `_RadioCard` (avec emoji circulaire, titre,
/// subtitle, dot radio à droite).
class _RadioCardItem extends StatelessWidget {
  const _RadioCardItem({
    required this.emoji,
    required this.title,
    this.subtitle,
    required this.selected,
    required this.enabled,
    required this.onTap,
  });

  final String emoji;
  final String title;
  final String? subtitle;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: enabled ? onTap : null,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                color: Color(0xFFF9FAFB),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(emoji, style: const TextStyle(fontSize: 18)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      height: 1.3,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: AppTextStyles.bodySmall.copyWith(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                        height: 1.3,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            _RadioDot(selected: selected),
          ],
        ),
      ),
    );
  }
}

class _RadioDot extends StatelessWidget {
  const _RadioDot({required this.selected});
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: selected ? AppColors.primary : AppColors.borderStrong,
          width: 1.5,
        ),
      ),
      child: selected
          ? Center(
              child: Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
            )
          : null,
    );
  }
}

/// Bottom sheet sélection parcelle (liste).
class _SelectionParcelleSheet extends StatelessWidget {
  const _SelectionParcelleSheet({
    required this.parcelles,
    this.initialId,
  });

  final List<Parcelle> parcelles;
  final String? initialId;

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    return Padding(
      padding: EdgeInsets.only(bottom: mq.viewInsets.bottom),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: mq.size.height * 0.6,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppDimens.space24,
                  AppDimens.space16,
                  AppDimens.space24,
                  AppDimens.space12,
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Choisir une parcelle',
                    style: AppTextStyles.titleLarge,
                  ),
                ),
              ),
              const Divider(
                height: 1,
                thickness: AppDimens.borderThin,
                color: AppColors.border,
              ),
              Expanded(
                child: parcelles.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.all(AppDimens.space24),
                        child: Text(
                          'Aucune parcelle disponible.',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(
                          vertical: AppDimens.space8,
                        ),
                        itemCount: parcelles.length,
                        separatorBuilder: (_, _) => const Divider(
                          height: 1,
                          thickness: AppDimens.borderThin,
                          color: AppColors.border,
                        ),
                        itemBuilder: (ctx, i) {
                          final p = parcelles[i];
                          final isCurrent = initialId == p.id;
                          final ha = p.superficieHa;
                          final haTxt = ha == null
                              ? 'Superficie inconnue'
                              : '${ha.toStringAsFixed(1)} ha';
                          return ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: AppDimens.space24,
                              vertical: 2,
                            ),
                            title: Text(p.nom,
                                style: AppTextStyles.titleSmall),
                            subtitle: Text(
                              haTxt,
                              style: AppTextStyles.bodySmall,
                            ),
                            trailing: isCurrent
                                ? const Icon(
                                    Icons.check,
                                    size: AppDimens.iconM,
                                    color: AppColors.primary,
                                  )
                                : null,
                            onTap: () => Navigator.of(context).pop(p),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
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
        Text(label, style: AppTextStyles.labelMedium),
        AppDimens.vGap8,
        child,
      ],
    );
  }
}

class _BoutonSelection extends StatelessWidget {
  const _BoutonSelection({
    required this.placeholder,
    required this.valeur,
    required this.enabled,
    required this.onTap,
    this.icon,
  });

  final String placeholder;
  final String? valeur;
  final bool enabled;
  final VoidCallback onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final hasValeur = valeur != null && valeur!.isNotEmpty;
    return InkWell(
      onTap: enabled ? onTap : null,
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
                hasValeur ? valeur! : placeholder,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: hasValeur ? AppColors.text : AppColors.textSubtle,
                  fontWeight:
                      hasValeur ? FontWeight.w500 : FontWeight.w400,
                ),
              ),
            ),
            Icon(
              icon ?? Icons.keyboard_arrow_down,
              size: AppDimens.iconM,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}

class _ChipQualite extends StatelessWidget {
  const _ChipQualite({
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
      borderRadius: const BorderRadius.all(
        Radius.circular(AppDimens.radiusPill),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.background,
          borderRadius: const BorderRadius.all(
            Radius.circular(AppDimens.radiusPill),
          ),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.borderStrong,
            width: AppDimens.borderThin,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: AppTextStyles.labelMedium.copyWith(
            color: selected ? AppColors.onPrimary : AppColors.text,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _GrillePhotos extends StatelessWidget {
  const _GrillePhotos({
    required this.photos,
    required this.max,
    required this.enabled,
    required this.onAdd,
    required this.onRemove,
  });

  final List<File> photos;
  final int max;
  final bool enabled;
  final VoidCallback onAdd;
  final ValueChanged<int> onRemove;

  @override
  Widget build(BuildContext context) {
    final slots = <Widget>[];
    for (var i = 0; i < photos.length; i++) {
      slots.add(_VignettePhoto(
        file: photos[i],
        enabled: enabled,
        onRemove: () => onRemove(i),
      ));
    }
    if (photos.length < max) {
      slots.add(_SlotAjout(enabled: enabled, onTap: onAdd));
    }

    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: AppDimens.space8,
      crossAxisSpacing: AppDimens.space8,
      children: slots,
    );
  }
}

class _SlotAjout extends StatelessWidget {
  const _SlotAjout({required this.enabled, required this.onTap});

  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(AppDimens.radius),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceSoft,
          borderRadius: BorderRadius.circular(AppDimens.radius),
          border: Border.all(
            color: AppColors.borderStrong,
            width: AppDimens.borderThin,
          ),
        ),
        alignment: Alignment.center,
        child: const Icon(
          Icons.add,
          size: 28,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}

class _VignettePhoto extends StatelessWidget {
  const _VignettePhoto({
    required this.file,
    required this.enabled,
    required this.onRemove,
  });

  final File file;
  final bool enabled;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppDimens.radius),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.file(file, fit: BoxFit.cover),
          // Overlay click pour suppression.
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: enabled ? onRemove : null,
            ),
          ),
          Positioned(
            top: 4,
            right: 4,
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: AppColors.text.withValues(alpha: 0.6),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.close,
                size: 14,
                color: AppColors.onPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Cultures de la parcelle (cascade) ─────────────────────────────────

/// Cultures d'une parcelle donnée. `autoDispose` pour libérer la liste
/// dès que l'utilisateur quitte la page, `family` pour clé sur la
/// parcelleId (chaque parcelle a son propre cache).
final _culturesParcelleProvider =
    FutureProvider.autoDispose.family<List<Culture>, String>(
  (ref, parcelleId) async {
    return ref
        .watch(marketplaceServiceProvider)
        .listCultures(parcelleId: parcelleId);
  },
);

/// Sélecteur culture cascade — style maquette (icône carrée + 2 lignes).
/// La 2e ligne affiche "N cultures dispo sur cette parcelle".
class _SelecteurCultureMaquette extends ConsumerWidget {
  const _SelecteurCultureMaquette({
    required this.parcelleId,
    required this.culture,
    required this.enabled,
    required this.onTap,
    required this.onOuvrirMesParcelles,
  });

  final String parcelleId;
  final Culture? culture;
  final bool enabled;
  final VoidCallback onTap;
  final VoidCallback onOuvrirMesParcelles;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(_culturesParcelleProvider(parcelleId));
    return async.when(
      loading: () => const _BoutonSelectionLoading(),
      error: (_, _) => _SelecteurMaquette(
        icon: Icons.error_outline,
        title: 'Erreur de chargement',
        placeholder: true,
        enabled: false,
        onTap: () {},
      ),
      data: (cultures) {
        if (cultures.isEmpty) {
          return _CulturesVidesCard(onOuvrir: onOuvrirMesParcelles);
        }
        final hasSel = culture != null;
        return _SelecteurMaquette(
          icon: Icons.eco_outlined,
          title: hasSel
              ? (culture!.produitNom ?? '(produit inconnu)')
              : 'Choisir une culture',
          subtitle: hasSel
              ? '${cultures.length} cultures dispo sur cette parcelle'
              : null,
          placeholder: !hasSel,
          enabled: enabled,
          onTap: onTap,
        );
      },
    );
  }
}

class _BoutonSelectionLoading extends StatelessWidget {
  const _BoutonSelectionLoading();

  @override
  Widget build(BuildContext context) {
    return Container(
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
          const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2.2,
              color: AppColors.primary,
            ),
          ),
          AppDimens.hGap12,
          Expanded(
            child: Text(
              'Chargement des cultures…',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Card affichée quand la parcelle sélectionnée n'a aucune culture.
/// Texte d'erreur (rouge léger) + CTA vert pour aller dans "Mes parcelles".
class _CulturesVidesCard extends StatelessWidget {
  const _CulturesVidesCard({required this.onOuvrir});

  final VoidCallback onOuvrir;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimens.space12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: AppDimens.brInput,
        border: Border.all(
          color: AppColors.error,
          width: AppDimens.borderThin,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Cette parcelle n\'a pas encore de culture. Ajoute-en '
            'depuis "Mes parcelles".',
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.error),
          ),
          AppDimens.vGap8,
          InkWell(
            onTap: onOuvrir,
            child: Text(
              'Ouvrir mes parcelles',
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
                decoration: TextDecoration.underline,
                decorationColor: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Bottom sheet sélection culture (cascade depuis parcelle) ──────────

class _SelectionCultureSheet extends ConsumerStatefulWidget {
  const _SelectionCultureSheet({
    required this.parcelleId,
    this.initialId,
  });

  final String parcelleId;
  final String? initialId;

  @override
  ConsumerState<_SelectionCultureSheet> createState() =>
      _SelectionCultureSheetState();
}

class _SelectionCultureSheetState
    extends ConsumerState<_SelectionCultureSheet> {
  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final async = ref.watch(_culturesParcelleProvider(widget.parcelleId));
    return Padding(
      padding: EdgeInsets.only(bottom: mq.viewInsets.bottom),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: mq.size.height * 0.6,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppDimens.space24,
                  AppDimens.space16,
                  AppDimens.space24,
                  AppDimens.space12,
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Choisir une culture',
                    style: AppTextStyles.titleLarge,
                  ),
                ),
              ),
              const Divider(
                height: 1,
                thickness: AppDimens.borderThin,
                color: AppColors.border,
              ),
              Expanded(
                child: async.when(
                  loading: () => const Padding(
                    padding: EdgeInsets.all(AppDimens.space24),
                    child: Chargement(size: 20),
                  ),
                  error: (_, _) => Padding(
                    padding: const EdgeInsets.all(AppDimens.space24),
                    child: Text(
                      'Impossible de charger les cultures.',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.error,
                      ),
                    ),
                  ),
                  data: (cultures) {
                    if (cultures.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.all(AppDimens.space24),
                        child: Text(
                          'Aucune culture sur cette parcelle.',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      );
                    }
                    return ListView.separated(
                      padding: const EdgeInsets.symmetric(
                        vertical: AppDimens.space8,
                      ),
                      itemCount: cultures.length,
                      separatorBuilder: (_, _) => const Divider(
                        height: 1,
                        thickness: AppDimens.borderThin,
                        color: AppColors.border,
                      ),
                      itemBuilder: (ctx, i) {
                        final c = cultures[i];
                        final isCurrent = widget.initialId == c.id;
                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: AppDimens.space24,
                            vertical: 2,
                          ),
                          title: Text(
                            c.produitNom ?? '(produit inconnu)',
                            style: AppTextStyles.titleSmall,
                          ),
                          trailing: isCurrent
                              ? const Icon(
                                  Icons.check,
                                  size: AppDimens.iconM,
                                  color: AppColors.primary,
                                )
                              : null,
                          onTap: () => Navigator.of(context).pop(c),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
