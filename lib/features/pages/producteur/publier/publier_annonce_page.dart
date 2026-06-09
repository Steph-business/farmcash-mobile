import 'dart:io';

import 'package:flutter/cupertino.dart';
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
import '../../../widgets/communs/chargement.dart';
import '../../../widgets/communs/snackbars.dart';
import '../../../widgets/producteur/publier/_couleurs_publier.dart';
import '../../../widgets/producteur/publier/apercu_prix_net.dart';
import '../../../widgets/producteur/publier/barre_progression.dart';
import '../../../widgets/producteur/publier/bouton_pied_page.dart';
import '../../../widgets/producteur/publier/carte_culture.dart';
import '../../../widgets/producteur/publier/carte_radio.dart';
import '../../../widgets/producteur/publier/carte_radio_option.dart';
import '../../../widgets/producteur/publier/carte_recap.dart';
import '../../../widgets/producteur/publier/carte_total.dart';
import '../../../widgets/producteur/publier/champ_label.dart';
import '../../../widgets/producteur/publier/chips_kg_rapides.dart';
import '../../../widgets/producteur/publier/emplacement_photo.dart';
import '../../../widgets/producteur/publier/puce_publier.dart';
import '../../../widgets/producteur/publier/titre_section.dart';

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

/// Choix offert au producteur après publication réussie. Le dialog de
/// succès retourne l'un de ces deux choix ; `null` si le user dismiss
/// (cas rare avec `barrierDismissible: false`).
enum _PostSubmitAction { mesAnnonces, republier }

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
  // Date à laquelle le produit a été récolté — info de fraîcheur affichée
  // aux acheteurs. Limitée au passé (un an max) + aujourd'hui ; on ne
  // peut pas vendre une récolte du futur. La date de publication est
  // automatique (created_at backend). La date de disponibilité a été
  // retirée du formulaire — info redondante avec la date de récolte +
  // statut ACTIVE de l'annonce.
  DateTime? _dateRecolte;
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

  /// Quand on ouvre "Publier une annonce" sans avoir de parcelle/culture
  /// déclarée, on proposait avant d'aller vers la page "Mes parcelles" en
  /// FERMANT la page publier — résultat : après création de la parcelle,
  /// l'utilisateur retombait sur l'accueil et devait recliquer "Publier".
  ///
  /// Nouveau flow : la page publier reste empilée, on push directement
  /// `ParcelleCreerPage` qui retourne la parcelle créée via `pop(parcelle)`.
  /// Au retour, on recharge `_bootstrap()` pour que la liste des cultures
  /// soit à jour, et l'utilisateur continue son annonce sans interruption.
  void _redirigerVersMesParcelles() {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Aucune culture enregistrée'),
        content: const Text(
          'Tu n\'as pas encore déclaré ce que tu cultives sur une parcelle. '
          'Ajoute une parcelle et la culture associée — ensuite tu pourras '
          'publier cette annonce.',
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
            onPressed: () async {
              // Ferme le dialog SANS fermer la page publier (le flow reste
              // empilé : publier → parcelle_creer → retour publier).
              Navigator.of(ctx).pop();
              final created = await context.push<dynamic>(
                RouteNames.producteurCreerParcellePath,
              );
              if (!mounted) return;
              if (created != null) {
                // Parcelle créée : on relance le bootstrap pour repeupler
                // `_parcelles` + `_cultures` côté page publier. Le user
                // poursuit son flow d'annonce sans navigation manuelle.
                await _bootstrap();
              } else {
                // Annulé sans création → on ferme aussi la page publier
                // (sinon le user reste bloqué sans culture sélectionnable).
                if (mounted) Navigator.of(context).pop();
              }
            },
            child: const Text('Créer une parcelle'),
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
  // Le picker pour "Disponible jusqu'au" a été retiré du formulaire ;
  // seule la date de récolte (`_choisirDateRecolte`) est exposée.

  /// Picker pour la date de RÉCOLTE (≠ date de disponibilité).
  /// Borné au passé + jour J : on ne récolte pas dans le futur. On
  /// remonte à 365 jours pour gérer des produits longue conservation
  /// (manioc, igname, etc.).
  Future<void> _choisirDateRecolte() async {
    FocusScope.of(context).unfocus();
    final now = DateTime.now();
    final initial = _dateRecolte ?? now;
    await showCupertinoModalPopup<DateTime>(
      context: context,
      builder: (BuildContext context) => Container(
        height: 250,
        padding: const EdgeInsets.only(top: 6.0),
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        color: CupertinoColors.systemBackground.resolveFrom(context),
        child: SafeArea(
          top: false,
          child: CupertinoDatePicker(
            initialDateTime: initial,
            minimumDate: now.subtract(const Duration(days: 365)),
            maximumDate: now,
            mode: CupertinoDatePickerMode.date,
            use24hFormat: true,
            onDateTimeChanged: (DateTime newDate) {
              if (mounted) {
                setState(() => _dateRecolte = newDate);
              }
            },
          ),
        ),
      ),
    );
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
        // Date de récolte saisie à l'étape 4 — info de fraîcheur pour
        // les acheteurs. Reste null si le producteur ne l'a pas renseignée.
        dateRecolte: _dateRecolte,
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
      // Dialog de confirmation explicite : avant on faisait un Snackbars
      // + pop direct, l'utilisateur ne réalisait pas que l'annonce avait
      // été publiée. Le dialog propose 2 actions claires :
      // • « Voir mes annonces » → push vers la liste publications
      // • « Publier une autre » → reset le formulaire et reste sur la page
      await _afficherSuccesEtChoix(photoOk: photoOk);
    } on ApiException catch (e) {
      if (!mounted) return;
      Snackbars.showErreur(context, e.message);
    } catch (e) {
      if (!mounted) return;
      Snackbars.showErreurInattendue(context, e);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  /// Affiche un dialog de succès avec 2 actions : voir mes annonces ou
  /// publier une autre annonce. Le dialog n'est pas dismissible (force
  /// un choix conscient — évite que le producteur croit que l'annonce
  /// n'a pas été publiée s'il tape à côté).
  Future<void> _afficherSuccesEtChoix({required bool photoOk}) async {
    final action = await showDialog<_PostSubmitAction>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
        contentPadding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                color: kSoftBgPublier,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.check_circle_outline,
                size: 22,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(child: Text('Annonce publiée')),
          ],
        ),
        content: Text(
          photoOk
              ? 'Ton annonce est en ligne et visible par les acheteurs.'
              : 'Annonce publiée, mais la photo n\'a pas pu être ajoutée. '
                'Tu pourras la rajouter depuis le détail.',
          style: AppTextStyles.bodyMedium.copyWith(fontSize: 14, height: 1.4),
        ),
        actionsAlignment: MainAxisAlignment.spaceBetween,
        actionsPadding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(_PostSubmitAction.republier),
            child: const Text('Publier une autre'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(_PostSubmitAction.mesAnnonces),
            child: const Text('Voir mes annonces'),
          ),
        ],
      ),
    );
    if (!mounted) return;
    switch (action) {
      case _PostSubmitAction.mesAnnonces:
        // Pop la page publier, push vers "Mes publications".
        Navigator.of(context).pop();
        context.push(RouteNames.producteurMesPublicationsPath);
        break;
      case _PostSubmitAction.republier:
        // Reset le formulaire et reviens à l'étape 1 — le producteur
        // peut enchaîner sans réouvrir la page publier (utile pour
        // poster plusieurs annonces d'affilée après une grosse récolte).
        _resetForm();
        _pageController.jumpToPage(0);
        break;
      case null:
        // Dialog dismissed inopinément (cas rare avec barrierDismissible:
        // false mais on est défensif). On pop la page comme l'ancien comportement.
        Navigator.of(context).pop();
    }
  }

  /// Remet le formulaire à zéro pour permettre de publier une 2e annonce
  /// sans réouvrir la page. Préserve les parcelles/cultures déjà chargées
  /// pour éviter un nouveau `_bootstrap()` réseau inutile.
  void _resetForm() {
    setState(() {
      _culture = _cultures.length == 1 ? _cultures.first : null;
      _photo = null;
      _qteCtrl.clear();
      _prixCtrl.clear();
      _qualite = ProductQuality.standard;
      _certifications.clear();
      _traitements.clear();
      _certifAutreCtrl.clear();
      _traitementAutreCtrl.clear();
      _audienceCoop = false;
      _dateRecolte = null;
      _titreCtrl.clear();
      _descriptionCtrl.clear();
    });
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
                    BarreProgression(index: _pageIndex, total: 4),
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
              InkWell(
                onTap: () => context.push(RouteNames.producteurAnnonceExpressPath),
                borderRadius: BorderRadius.circular(AppDimens.radiusCard),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                    borderRadius: BorderRadius.circular(AppDimens.radiusCard),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.mic_none_outlined, size: 16, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          "Publier par Vidéo ou Note Vocale (IA)",
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                            fontSize: 13.5,
                          ),
                        ),
                      ),
                      const Icon(Icons.chevron_right, size: 18, color: AppColors.primary),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              for (final c in _cultures)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: CarteCulture(
                    culture: c,
                    parcelle: _parcelleDeLaCulture(c),
                    selected: _culture?.id == c.id,
                    onTap: () => setState(() => _culture = c),
                  ),
                ),
            ],
          ),
        ),
        BoutonPiedPage(
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
              EmplacementPhoto(
                photo: _photo,
                enabled: !_isSubmitting,
                onTap: _prendrePhoto,
                onRemove: () => setState(() => _photo = null),
              ),
              const SizedBox(height: 20),
              const TitreSection('Quantité'),
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
              ChipsKgRapides(onPick: (kg) {
                _qteCtrl.text = kg.toString();
              }),
              const SizedBox(height: 20),
              const TitreSection('Prix par kg'),
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
              // Aperçu net par kg dès que l'utilisateur saisit son prix.
              // Affiche en clair ce qu'il touchera vraiment après la
              // commission FarmCash 3 %. Pas de mauvaise surprise au
              // moment du paiement, et le producteur peut ajuster son
              // prix d'affichage en connaissance de cause.
              if (_prix != null) ...[
                const SizedBox(height: 8),
                ApercuPrixNet(
                  prixBrutKg: _prix!,
                  tauxFarmcash: 0.03,
                ),
              ],
              if (_total > 0) ...[
                const SizedBox(height: 10),
                CarteTotal(totalFormate: _formatMontant(_total)),
              ],
              const SizedBox(height: 20),
              const TitreSection('Qualité'),
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
                    PucePublier(
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
        BoutonPiedPage(
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
              const TitreSection('Traitements appliqués'),
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
                    PucePublier(
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
              ChampLabel(
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
              const TitreSection('Certification'),
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
                    PucePublier(
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
              ChampLabel(
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
        BoutonPiedPage(
          label: 'Suivant',
          enabled: _step3Valid && !_isSubmitting,
          onTap: _suivant,
        ),
      ],
    );
  }

  // ─── Step 4 : Audience + publier ──────────────────────────────────

  Widget _buildStep4() {
    // Safety check: redirect to step 1 if culture is not selected
    if (_culture == null) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text('Veuillez d\'abord sélectionner une culture',
                      style: AppTextStyles.bodyMedium),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      _pageController.jumpToPage(0);
                    },
                    child: const Text('Retour à l\'étape 1'),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

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
              const TitreSection('Publier vers'),
              AppDimens.vGap12,
              CarteRadio(
                children: [
                  CarteRadioOption(
                    emoji: '🌍',
                    title: 'Tout le marché (public)',
                    subtitle: 'Visible par tous les acheteurs',
                    selected: !_audienceCoop,
                    enabled: !_isSubmitting,
                    onTap: () => setState(() => _audienceCoop = false),
                  ),
                  // L'option "Ma coopérative" est TOUJOURS affichée pour
                  // que le producteur sache qu'elle existe. Si l'utilisateur
                  // n'est membre d'aucune coop (`cooperativeId == null`),
                  // l'option est désactivée + un sous-titre explique pourquoi
                  // et où s'inscrire à une coop. Avant : on cachait l'option
                  // → l'utilisateur croyait que le formulaire ne supportait
                  // pas l'attribution coop.
                  CarteRadioOption(
                    emoji: '🤝',
                    title: 'Ma coopérative',
                    subtitle: aDesCoop
                        ? 'La coop valide et agrège avec d\'autres avant publication'
                        : 'Rejoins d\'abord une coopérative dans ton profil pour activer cette option',
                    selected: aDesCoop && _audienceCoop,
                    enabled: aDesCoop && !_isSubmitting,
                    onTap: aDesCoop
                        ? () => setState(() => _audienceCoop = true)
                        : null,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const TitreSection('Détails (optionnel)'),
              AppDimens.vGap12,
              ChampLabel(
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
              ChampLabel(
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
              // Date de RÉCOLTE — info de fraîcheur pour l'acheteur.
              // Affichée AVANT la date "disponible jusqu'au" car c'est ce
              // que le producteur a en tête immédiatement après sa récolte.
              ChampLabel(
                label: 'Date de récolte',
                child: InkWell(
                  onTap: _isSubmitting ? null : _choisirDateRecolte,
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
                            _dateRecolte == null
                                ? 'Optionnel — quand as-tu récolté ?'
                                : _formatDate(_dateRecolte!),
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: _dateRecolte == null
                                  ? AppColors.textSubtle
                                  : AppColors.text,
                            ),
                          ),
                        ),
                        if (_dateRecolte != null && !_isSubmitting)
                          InkWell(
                            onTap: () =>
                                setState(() => _dateRecolte = null),
                            borderRadius: BorderRadius.circular(16),
                            child: const Padding(
                              padding: EdgeInsets.all(4),
                              child: Icon(
                                Icons.close,
                                size: 16,
                                color: AppColors.textSubtle,
                              ),
                            ),
                          )
                        else
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
              // Bloc "Disponible jusqu'au" retiré : la date est redondante
              // avec la `dateRecolte` + le statut ACTIVE de l'annonce. Le
              // producteur publie quand il a la marchandise prête, et il
              // pause l'annonce manuellement quand c'est écoulé. Garder un
              // champ supplémentaire embrouillait la saisie.
              const SizedBox(height: 20),
              CarteRecap(
                culture: _culture!,
                parcelle: _parcelleDeLaCulture(_culture!),
                qteFormatee: _formatNombre(_qte ?? 0),
                prixFormate: _formatMontant(_prix ?? 0),
                totalFormate: _formatMontant(_total),
                qualite: _libelleQualite(_qualite),
              ),
            ],
          ),
        ),
        BoutonPiedPage(
          label: 'Publier mon annonce',
          isLoading: _isSubmitting,
          enabled: _canPublier,
          onTap: _publier,
        ),
      ],
    );
  }
}
