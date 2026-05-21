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

/// Publier une annonce de vente — flow optimisé producteur, 4 étapes :
///   1. **Culture** — sélection parmi les cultures du producteur (déjà
///      enregistrées sur ses parcelles). Pas de saisie libre.
///   2. **Photo + Vente** — photo du produit, quantité, prix, qualité.
///   3. **Traçabilité** — certifications + traitements appliqués
///      (multi-select sur catalogues communs).
///   4. **Audience** — public / ma coop, date limite, description.
class PublierAnnoncePage extends ConsumerStatefulWidget {
  const PublierAnnoncePage({super.key});

  @override
  ConsumerState<PublierAnnoncePage> createState() => _PublierAnnoncePageState();
}

const _kSoftBg = Color(0xFFE8F5E9);

/// Traitements communs en CI — affichés en multi-select sur l'étape 3.
/// Le backend matche en recherche partielle (`produit_traitement_nom`),
/// donc l'admin peut compléter le catalogue côté backend sans
/// redéployer l'app.
const _kTraitementsCommuns = <String>[
  'Aucun traitement chimique',
  'Engrais naturel (compost, fumier)',
  'Engrais chimique NPK',
  'Pesticides naturels (Neem)',
  'Pesticides chimiques',
  'Désherbants',
];

/// Certifications communes — multi-select libre.
const _kCertifsCommunes = <String>[
  'Bio',
  'Équitable',
  'Origine Côte d\'Ivoire',
];

class _PublierAnnoncePageState extends ConsumerState<PublierAnnoncePage> {
  final PageController _pageController = PageController();
  int _pageIndex = 0;

  // ─ Bootstrap ───────────────────────────────────────────────────────
  bool _loading = true;
  List<Parcelle> _parcelles = const [];
  List<Culture> _cultures = const [];

  // ─ Étape 1 ─────────────────────────────────────────────────────────
  Culture? _culture;

  // ─ Étape 2 ─────────────────────────────────────────────────────────
  File? _photo;
  final _qteCtrl = TextEditingController();
  final _prixCtrl = TextEditingController();
  ProductQuality _qualite = ProductQuality.standard;

  // ─ Étape 3 ─────────────────────────────────────────────────────────
  final Set<String> _certifications = {};
  final Set<String> _traitements = {};
  final _certifAutreCtrl = TextEditingController();
  final _traitementAutreCtrl = TextEditingController();

  // ─ Étape 4 ─────────────────────────────────────────────────────────
  bool _audienceCoop = false;
  DateTime? _disponibleJusqu;
  final _descriptionCtrl = TextEditingController();
  final _titreCtrl = TextEditingController();

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _qteCtrl.addListener(_onChange);
    _prixCtrl.addListener(_onChange);
    _certifAutreCtrl.addListener(_onChange);
    _traitementAutreCtrl.addListener(_onChange);
    _titreCtrl.addListener(_onChange);
    _descriptionCtrl.addListener(_onChange);
    WidgetsBinding.instance.addPostFrameCallback((_) => _bootstrap());
  }

  @override
  void dispose() {
    _pageController.dispose();
    _qteCtrl.dispose();
    _prixCtrl.dispose();
    _certifAutreCtrl.dispose();
    _traitementAutreCtrl.dispose();
    _titreCtrl.dispose();
    _descriptionCtrl.dispose();
    super.dispose();
  }

  void _onChange() {
    if (mounted) setState(() {});
  }

  // ── Bootstrap : charge parcelles + cultures du producteur ─────────

  Future<void> _bootstrap() async {
    try {
      final svc = ref.read(marketplaceServiceProvider);
      final results = await Future.wait([
        svc.listParcelles(),
        svc.listCultures(),
      ]);
      final parcelles = results[0] as List<Parcelle>;
      final cultures = results[1] as List<Culture>;
      if (!mounted) return;

      if (cultures.isEmpty) {
        // Pas de culture : impossible de publier. On dirige le
        // producteur vers la création d'une parcelle + culture.
        _redirigerVersMesParcelles();
        return;
      }

      setState(() {
        _parcelles = parcelles;
        _cultures = cultures;
        _loading = false;
        // Présélection si une seule culture.
        if (cultures.length == 1) _culture = cultures.first;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      Snackbars.showErreur(context, e.message);
      Navigator.of(context).pop();
    } catch (_) {
      if (!mounted) return;
      Snackbars.showErreur(context, 'Impossible de charger tes cultures.');
      Navigator.of(context).pop();
    }
  }

  void _redirigerVersMesParcelles() {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Aucune culture enregistrée'),
        content: const Text(
          'Tu n\'as pas encore de culture sur une parcelle. '
          'Ajoute d\'abord une parcelle et indique ce que tu cultives.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.of(context).pop();
            },
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.of(context).pop();
              context.push(RouteNames.producteurMesParcellesPath);
            },
            child: const Text('Aller à mes parcelles'),
          ),
        ],
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────

  Parcelle? _parcelleDeLaCulture(Culture c) {
    if (c.parcelleId == null) return null;
    try {
      return _parcelles.firstWhere((p) => p.id == c.parcelleId);
    } catch (_) {
      return null;
    }
  }

  double? get _qte {
    final raw = _qteCtrl.text.trim().replaceAll(',', '.');
    if (raw.isEmpty) return null;
    final v = double.tryParse(raw);
    return (v == null || v <= 0) ? null : v;
  }

  double? get _prix {
    final raw = _prixCtrl.text.trim().replaceAll(',', '.');
    if (raw.isEmpty) return null;
    final v = double.tryParse(raw);
    return (v == null || v <= 0) ? null : v;
  }

  double get _total => (_qte ?? 0) * (_prix ?? 0);

  bool get _step1Valid => _culture != null;
  bool get _step2Valid => _qte != null && _prix != null;
  bool get _step3Valid => true; // optionnel
  bool get _canPublier => _step1Valid && _step2Valid && !_isSubmitting;

  // ── Navigation pages ──────────────────────────────────────────────

  void _suivant() {
    if (_pageIndex == 0 && !_step1Valid) {
      Snackbars.showErreur(context, 'Choisis une culture.');
      return;
    }
    if (_pageIndex == 1 && !_step2Valid) {
      Snackbars.showErreur(context, 'Indique la quantité et le prix.');
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

  // ── Photo ─────────────────────────────────────────────────────────

  Future<void> _prendrePhoto() async {
    FocusScope.of(context).unfocus();
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: AppDimens.brBottomSheet,
      ),
      builder: (ctx) => SafeArea(
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
                  'Photo du produit',
                  style: AppTextStyles.titleLarge,
                ),
              ),
            ),
            const Divider(height: 1, color: AppColors.border),
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined,
                  color: AppColors.primary),
              title: const Text('Prendre une photo'),
              onTap: () => Navigator.of(ctx).pop(ImageSource.camera),
            ),
            const Divider(height: 1, color: AppColors.border),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined,
                  color: AppColors.primary),
              title: const Text('Choisir dans la galerie'),
              onTap: () => Navigator.of(ctx).pop(ImageSource.gallery),
            ),
            AppDimens.vGap8,
          ],
        ),
      ),
    );
    if (source == null || !mounted) return;
    try {
      final picked = await ImagePicker().pickImage(
        source: source,
        maxWidth: 1600,
        imageQuality: 80,
      );
      if (picked == null || !mounted) return;
      setState(() => _photo = File(picked.path));
    } catch (_) {
      if (mounted) {
        Snackbars.showErreur(context, 'Impossible d\'ajouter la photo.');
      }
    }
  }

  // ── Date limite ───────────────────────────────────────────────────

  Future<void> _choisirDate() async {
    FocusScope.of(context).unfocus();
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _disponibleJusqu ?? now.add(const Duration(days: 14)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      locale: const Locale('fr', 'FR'),
    );
    if (picked != null && mounted) {
      setState(() => _disponibleJusqu = picked);
    }
  }

  // ── Publication ───────────────────────────────────────────────────

  Future<void> _publier() async {
    if (!_canPublier) return;
    final user = ref.read(currentUserProvider);
    final culture = _culture!;
    final qte = _qte!;
    final prix = _prix!;

    setState(() => _isSubmitting = true);
    try {
      // 1) GPS — capture silencieuse, obligatoire pour le back.
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

      // 2) Titre — auto-généré si vide.
      final produitNom = culture.produitNom ?? 'Produit';
      final titreSaisi = _titreCtrl.text.trim();
      final titre = titreSaisi.isEmpty
          ? '$produitNom ${_libelleQualite(_qualite)} — '
                '${_formatNombre(qte)}kg'
          : titreSaisi;
      final description = _descriptionCtrl.text.trim();

      // 3) Audience coop.
      final coopId = (_audienceCoop && user?.cooperativeId != null)
          ? user!.cooperativeId
          : null;

      // 4) Certifications consolidées (chips + saisie libre).
      final certifs = <String>{..._certifications};
      final certifAutre = _certifAutreCtrl.text.trim();
      if (certifAutre.isNotEmpty) certifs.add(certifAutre);

      // 5) Traitements consolidés en payload backend.
      final traitements = <Map<String, dynamic>>[
        for (final t in _traitements) {'produit_traitement_nom': t},
      ];
      final traitementAutre = _traitementAutreCtrl.text.trim();
      if (traitementAutre.isNotEmpty) {
        traitements.add({'produit_traitement_nom': traitementAutre});
      }

      // 6) Création annonce.
      final annonce = await svc.createAnnonceVente(
        produitId: culture.produitId,
        titre: titre,
        quantiteKg: qte,
        prixParKg: prix,
        lat: position.latitude,
        lng: position.longitude,
        qualite: _qualite,
        description: description.isEmpty ? null : description,
        disponibleJusqu: _disponibleJusqu,
        assignedToCooperativeId: coopId,
        certifications: certifs.toList(growable: false),
        traitements: traitements.isEmpty ? null : traitements,
      );

      // 7) Upload photo si présente.
      var photoOk = true;
      if (_photo != null) {
        try {
          await svc.uploadAnnonceMedia(file: _photo!, annonceId: annonce.id);
        } catch (_) {
          photoOk = false;
        }
      }

      if (!mounted) return;
      if (!photoOk) {
        Snackbars.showInfo(
          context,
          'Annonce publiée. La photo n\'a pas pu être ajoutée.',
        );
      } else {
        Snackbars.showSucces(context, 'Annonce publiée avec succès !');
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

  static String _formatNombre(double v) {
    if ((v - v.truncate()).abs() < 0.01) return v.toStringAsFixed(0);
    return v.toStringAsFixed(1);
  }

  static String _formatDate(DateTime d) =>
      DateFormat('dd MMM yyyy', 'fr_FR').format(d);

  static String _formatMontant(double v) {
    final formatter = NumberFormat('#,##0', 'fr_FR');
    return formatter.format(v).replaceAll(',', ' ');
  }

  // ═════════════════════════════════════════════════════════════════
  // BUILD
  // ═════════════════════════════════════════════════════════════════

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
                    if (_pageIndex > 0) {
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
                _titrePage(),
                style: AppTextStyles.titleMedium.copyWith(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Étape ${_pageIndex + 1} sur 4',
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
              : Column(
                  children: [
                    _ProgressBar(index: _pageIndex, total: 4),
                    Expanded(
                      child: PageView(
                        controller: _pageController,
                        physics: const NeverScrollableScrollPhysics(),
                        onPageChanged: (i) => setState(() => _pageIndex = i),
                        children: [
                          _buildStep1(),
                          _buildStep2(),
                          _buildStep3(),
                          _buildStep4(),
                        ],
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  String _titrePage() {
    switch (_pageIndex) {
      case 0:
        return 'Choisir la culture';
      case 1:
        return 'Photo & vente';
      case 2:
        return 'Traçabilité';
      case 3:
        return 'Publier';
      default:
        return 'Publier une annonce';
    }
  }

  // ─── Step 1 : Sélection culture ───────────────────────────────────

  Widget _buildStep1() {
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
              Text(
                'Sélectionne ce que tu veux vendre. La parcelle source '
                'est rattachée automatiquement.',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 16),
              for (final c in _cultures)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _CultureCard(
                    culture: c,
                    parcelle: _parcelleDeLaCulture(c),
                    selected: _culture?.id == c.id,
                    onTap: () => setState(() => _culture = c),
                  ),
                ),
            ],
          ),
        ),
        _FooterButton(
          label: 'Suivant',
          enabled: _step1Valid && !_isSubmitting,
          onTap: _suivant,
        ),
      ],
    );
  }

  // ─── Step 2 : Photo + Vente ──────────────────────────────────────

  Widget _buildStep2() {
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
              _PhotoSlot(
                photo: _photo,
                enabled: !_isSubmitting,
                onTap: _prendrePhoto,
                onRemove: () => setState(() => _photo = null),
              ),
              const SizedBox(height: 20),
              const _SectionTitle('Quantité'),
              AppDimens.vGap12,
              TextField(
                controller: _qteCtrl,
                enabled: !_isSubmitting,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
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
              const SizedBox(height: 8),
              _QuickKgChips(onPick: (kg) {
                _qteCtrl.text = kg.toString();
              }),
              const SizedBox(height: 20),
              const _SectionTitle('Prix par kg'),
              AppDimens.vGap12,
              TextField(
                controller: _prixCtrl,
                enabled: !_isSubmitting,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
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
              if (_total > 0) ...[
                const SizedBox(height: 10),
                _TotalCard(total: _total),
              ],
              const SizedBox(height: 20),
              const _SectionTitle('Qualité'),
              AppDimens.vGap12,
              Wrap(
                spacing: AppDimens.space8,
                runSpacing: AppDimens.space8,
                children: [
                  for (final q in const [
                    ProductQuality.standard,
                    ProductQuality.premium,
                    ProductQuality.bio,
                    ProductQuality.equitable,
                  ])
                    _Chip(
                      label: _libelleQualite(q),
                      selected: _qualite == q,
                      enabled: !_isSubmitting,
                      onTap: () => setState(() => _qualite = q),
                    ),
                ],
              ),
            ],
          ),
        ),
        _FooterButton(
          label: 'Suivant',
          enabled: _step2Valid && !_isSubmitting,
          onTap: _suivant,
        ),
      ],
    );
  }

  // ─── Step 3 : Traçabilité ─────────────────────────────────────────

  Widget _buildStep3() {
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
              Text(
                'Ces infos rassurent les acheteurs et permettent la '
                'traçabilité. Tout est optionnel.',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 16),
              const _SectionTitle('Traitements appliqués'),
              AppDimens.vGap8,
              Text(
                'Sélectionne tout ce qui s\'applique',
                style: AppTextStyles.bodySmall.copyWith(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              AppDimens.vGap12,
              Wrap(
                spacing: AppDimens.space8,
                runSpacing: AppDimens.space8,
                children: [
                  for (final t in _kTraitementsCommuns)
                    _Chip(
                      label: t,
                      selected: _traitements.contains(t),
                      enabled: !_isSubmitting,
                      onTap: () {
                        setState(() {
                          if (_traitements.contains(t)) {
                            _traitements.remove(t);
                          } else {
                            _traitements.add(t);
                          }
                        });
                      },
                    ),
                ],
              ),
              AppDimens.vGap12,
              _ChampLabel(
                label: 'Autre traitement (optionnel)',
                child: TextField(
                  controller: _traitementAutreCtrl,
                  enabled: !_isSubmitting,
                  textCapitalization: TextCapitalization.sentences,
                  maxLength: 200,
                  decoration: const InputDecoration(
                    hintText: 'Ex : Pulvérisation cuivre',
                    counterText: '',
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const _SectionTitle('Certification'),
              AppDimens.vGap8,
              Text(
                'Sélectionne si tu as une certification reconnue',
                style: AppTextStyles.bodySmall.copyWith(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              AppDimens.vGap12,
              Wrap(
                spacing: AppDimens.space8,
                runSpacing: AppDimens.space8,
                children: [
                  for (final c in _kCertifsCommunes)
                    _Chip(
                      label: c,
                      selected: _certifications.contains(c),
                      enabled: !_isSubmitting,
                      onTap: () {
                        setState(() {
                          if (_certifications.contains(c)) {
                            _certifications.remove(c);
                          } else {
                            _certifications.add(c);
                          }
                        });
                      },
                    ),
                ],
              ),
              AppDimens.vGap12,
              _ChampLabel(
                label: 'Autre certification (optionnel)',
                child: TextField(
                  controller: _certifAutreCtrl,
                  enabled: !_isSubmitting,
                  textCapitalization: TextCapitalization.sentences,
                  maxLength: 200,
                  decoration: const InputDecoration(
                    hintText: 'Ex : Label Origine CI',
                    counterText: '',
                  ),
                ),
              ),
            ],
          ),
        ),
        _FooterButton(
          label: 'Suivant',
          enabled: _step3Valid && !_isSubmitting,
          onTap: _suivant,
        ),
      ],
    );
  }

  // ─── Step 4 : Audience + publier ──────────────────────────────────

  Widget _buildStep4() {
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
                          'La coop valide et agrège avec d\'autres avant publication',
                      selected: _audienceCoop,
                      enabled: !_isSubmitting,
                      onTap: () => setState(() => _audienceCoop = true),
                    ),
                ],
              ),
              const SizedBox(height: 20),
              const _SectionTitle('Détails (optionnel)'),
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
                        'Donne plus de contexte sur ta récolte (séchage, conditionnement…)',
                  ),
                ),
              ),
              const SizedBox(height: 14),
              _ChampLabel(
                label: 'Disponible jusqu\'au',
                child: InkWell(
                  onTap: _isSubmitting ? null : _choisirDate,
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
                            _disponibleJusqu == null
                                ? 'Optionnel — choisir une date'
                                : _formatDate(_disponibleJusqu!),
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: _disponibleJusqu == null
                                  ? AppColors.textSubtle
                                  : AppColors.text,
                            ),
                          ),
                        ),
                        const Icon(
                          Icons.calendar_today_outlined,
                          size: AppDimens.iconM,
                          color: AppColors.textSecondary,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              _RecapCard(
                culture: _culture!,
                parcelle: _parcelleDeLaCulture(_culture!),
                qte: _qte ?? 0,
                prix: _prix ?? 0,
                total: _total,
                qualite: _libelleQualite(_qualite),
              ),
            ],
          ),
        ),
        _FooterButton(
          label: 'Publier mon annonce',
          isLoading: _isSubmitting,
          enabled: _canPublier,
          onTap: _publier,
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
// COMPOSANTS
// ═══════════════════════════════════════════════════════════════════════

class _ProgressBar extends StatelessWidget {
  const _ProgressBar({required this.index, required this.total});
  final int index;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppDimens.pagePaddingH,
        AppDimens.space4,
        AppDimens.pagePaddingH,
        AppDimens.space8,
      ),
      child: Row(
        children: List.generate(total, (i) {
          final actif = i <= index;
          return Expanded(
            child: Container(
              margin: EdgeInsets.only(right: i == total - 1 ? 0 : 6),
              height: 4,
              decoration: BoxDecoration(
                color: actif ? AppColors.primary : AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }),
      ),
    );
  }
}

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

class _FooterButton extends StatelessWidget {
  const _FooterButton({
    required this.label,
    required this.onTap,
    this.enabled = true,
    this.isLoading = false,
  });

  final String label;
  final VoidCallback onTap;
  final bool enabled;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppDimens.pagePaddingH,
        AppDimens.space12,
        AppDimens.pagePaddingH,
        AppDimens.space16,
      ),
      child: BoutonPrincipal(
        label: label,
        isLoading: isLoading,
        enabled: enabled,
        onPressed: enabled ? onTap : null,
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
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
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: selected ? AppColors.primary : AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected ? AppColors.primary : AppColors.border,
              width: AppDimens.borderThin,
            ),
          ),
          child: Text(
            label,
            style: AppTextStyles.labelMedium.copyWith(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: selected ? AppColors.onPrimary : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Step 1 : culture card ─────────────────────────────────────────────

class _CultureCard extends StatelessWidget {
  const _CultureCard({
    required this.culture,
    required this.parcelle,
    required this.selected,
    required this.onTap,
  });

  final Culture culture;
  final Parcelle? parcelle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final parcelleNom = parcelle?.nom ?? 'Parcelle inconnue';
    final ha = parcelle?.superficieHa;
    final haTxt = ha == null ? null : '${ha.toStringAsFixed(1)} ha';
    final sousTitre = haTxt == null ? parcelleNom : '$parcelleNom · $haTxt';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: selected ? _kSoftBg : AppColors.background,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? AppColors.primary : AppColors.border,
              width: selected ? 1.5 : AppDimens.borderThin,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.eco_outlined,
                  size: 22,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      culture.produitNom ?? '(produit inconnu)',
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      sousTitre,
                      style: AppTextStyles.bodySmall.copyWith(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _RadioDot(selected: selected),
            ],
          ),
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

// ─── Step 2 : photo + quantité ─────────────────────────────────────────

class _PhotoSlot extends StatelessWidget {
  const _PhotoSlot({
    required this.photo,
    required this.enabled,
    required this.onTap,
    required this.onRemove,
  });

  final File? photo;
  final bool enabled;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    if (photo == null) {
      return InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 180,
          decoration: BoxDecoration(
            color: AppColors.surfaceSoft,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.borderStrong,
              width: AppDimens.borderThin,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.add_a_photo_outlined,
                size: 32,
                color: AppColors.primary,
              ),
              const SizedBox(height: 8),
              Text(
                'Prendre une photo du produit',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Rassure l\'acheteur',
                style: AppTextStyles.bodySmall.copyWith(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      );
    }
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.file(
            photo!,
            width: double.infinity,
            height: 200,
            fit: BoxFit.cover,
          ),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: InkWell(
            onTap: enabled ? onRemove : null,
            borderRadius: BorderRadius.circular(20),
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.text.withValues(alpha: 0.6),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.close,
                size: 18,
                color: AppColors.onPrimary,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _QuickKgChips extends StatelessWidget {
  const _QuickKgChips({required this.onPick});
  final ValueChanged<int> onPick;

  static const _kg = [10, 25, 50, 100];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppDimens.space8,
      runSpacing: AppDimens.space8,
      children: [
        for (final kg in _kg)
          _Chip(
            label: '$kg kg',
            selected: false,
            enabled: true,
            onTap: () => onPick(kg),
          ),
      ],
    );
  }
}

class _TotalCard extends StatelessWidget {
  const _TotalCard({required this.total});
  final double total;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: _kSoftBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primary,
          width: AppDimens.borderThin,
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.calculate_outlined,
            size: 18,
            color: AppColors.primary,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Total estimé',
              style: AppTextStyles.bodyMedium.copyWith(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ),
          Text(
            '${_PublierAnnoncePageState._formatMontant(total)} F',
            style: AppTextStyles.titleMedium.copyWith(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Step 4 : audience radio-card + recap ─────────────────────────────

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

class _RecapCard extends StatelessWidget {
  const _RecapCard({
    required this.culture,
    required this.parcelle,
    required this.qte,
    required this.prix,
    required this.total,
    required this.qualite,
  });

  final Culture culture;
  final Parcelle? parcelle;
  final double qte;
  final double prix;
  final double total;
  final String qualite;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceSoft,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.border,
          width: AppDimens.borderThin,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Récapitulatif',
            style: AppTextStyles.titleSmall.copyWith(
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          _RecapRow('Culture', culture.produitNom ?? '(inconnu)'),
          _RecapRow(
            'Parcelle',
            parcelle?.nom ?? '—',
          ),
          _RecapRow('Quantité', '${_PublierAnnoncePageState._formatNombre(qte)} kg'),
          _RecapRow(
            'Prix',
            '${_PublierAnnoncePageState._formatMontant(prix)} F/kg',
          ),
          _RecapRow('Qualité', qualite),
          const Divider(height: 16, color: AppColors.border),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Total estimé',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                '${_PublierAnnoncePageState._formatMontant(total)} F',
                style: AppTextStyles.titleMedium.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RecapRow extends StatelessWidget {
  const _RecapRow(this.label, this.value);
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Text(
            value,
            style: AppTextStyles.bodyMedium.copyWith(
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
