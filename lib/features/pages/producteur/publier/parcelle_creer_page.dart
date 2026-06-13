import 'dart:async';
import 'dart:io';
import 'dart:math' as math;

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../api_client/api_exception.dart';
import '../../../../models/ville.dart';
import '../../../../services/marketplace_service.dart';
import '../../../../services/providers.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';
import '../../../widgets/communs/snackbars.dart';
import '../../../widgets/producteur/parcelles/barre_progression.dart';
import '../../../widgets/producteur/parcelles/bouton_gps_large.dart';
import '../../../widgets/producteur/parcelles/bouton_pied_de_page.dart';
import '../../../widgets/producteur/parcelles/cartes_mode_mesure.dart';
import '../../../widgets/producteur/parcelles/champ_label.dart';
import '../../../widgets/producteur/parcelles/panneau_contourner.dart';
import '../../../widgets/producteur/parcelles/panneau_cultures.dart';
import '../../../widgets/producteur/parcelles/parcelle_providers.dart';
import '../../../widgets/producteur/parcelles/recap_position.dart';
import '../../../widgets/producteur/parcelles/selecteur_photo.dart';
import '../../../widgets/producteur/parcelles/selection_ville_sheet.dart';

/// Création d'une parcelle — flow optimisé producteur, 3 étapes :
///   1. **Localisation** — GPS d'abord, reverse-geocoding auto pour la ville.
///   2. **Mesure** — saisie manuelle OU marche autour (multi-GPS + aire polygone).
///   3. **Cultures** — top 6 CI mis en avant, recherche, photo optionnelle.
///
/// Renvoie la `Parcelle` créée via `pop`.
class ParcelleCreerPage extends ConsumerStatefulWidget {
  const ParcelleCreerPage({super.key});

  @override
  ConsumerState<ParcelleCreerPage> createState() => _ParcelleCreerPageState();
}

class _ParcelleCreerPageState extends ConsumerState<ParcelleCreerPage> {
  final PageController _pageController = PageController();
  int _pageIndex = 0;

  // ─ Étape 1 : Localisation ──────────────────────────────────────────
  final _nomCtrl = TextEditingController();
  double? _lat;
  double? _lng;
  String? _villeDetectee; // ville résolue par Nominatim (read-only display)
  Ville? _selectedVille; // ville depuis le référentiel (matchée auto)
  bool _capturingGps = false;
  bool _resolvingCity = false;

  // ─ Étape 2 : Mesure ────────────────────────────────────────────────
  bool _modeMarche = false; // false = saisie, true = marcher autour
  final _superficieCtrl = TextEditingController();
  // Marcher autour : flux de positions + aire calculée.
  final List<Position> _walkPoints = [];
  StreamSubscription<Position>? _walkSub;
  bool _walking = false;
  double? _aireCalculeeHa;

  // ─ Étape 3 : Cultures + photo ──────────────────────────────────────
  final Set<String> _selectedProduitIds = {};
  final _rechercheCtrl = TextEditingController();
  bool _afficherToutes = false;
  File? _photo;

  // ─ Submit ─────────────────────────────────────────────────────────
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _nomCtrl.addListener(_onChanged);
    _superficieCtrl.addListener(_onChanged);
    _rechercheCtrl.addListener(_onChanged);
  }

  @override
  void dispose() {
    _nomCtrl.dispose();
    _superficieCtrl.dispose();
    _rechercheCtrl.dispose();
    _walkSub?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _onChanged() {
    if (mounted) setState(() {});
  }

  // ── Validations ────────────────────────────────────────────────────

  bool get _step1Valid => _lat != null && _lng != null;

  double? get _superficieValeur {
    // Priorité au calcul GPS si le mode marche a réussi.
    if (_modeMarche && _aireCalculeeHa != null && _aireCalculeeHa! > 0) {
      return _aireCalculeeHa;
    }
    final raw = _superficieCtrl.text.trim().replaceAll(',', '.');
    if (raw.isEmpty) return null;
    final v = double.tryParse(raw);
    if (v == null || v <= 0) return null;
    return v;
  }

  bool get _step2Valid => _superficieValeur != null;

  bool get _canSubmit => !_isSubmitting && _step1Valid && _step2Valid;

  // ── Navigation entre étapes ────────────────────────────────────────

  void _suivant() {
    if (_pageIndex == 0 && !_step1Valid) {
      Snackbars.showErreur(context, 'Capture ta position d\'abord.');
      return;
    }
    if (_pageIndex == 1 && !_step2Valid) {
      Snackbars.showErreur(context, 'Indique la superficie de ta parcelle.');
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

  // ── GPS + Reverse-geocoding ────────────────────────────────────────

  Future<Position?> _capturerPositionUnique() async {
    final serviceOk = await Geolocator.isLocationServiceEnabled();
    if (!serviceOk) {
      if (mounted) {
        Snackbars.showErreur(
          context,
          'Active la localisation de ton téléphone et réessaye.',
        );
      }
      return null;
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
      return null;
    }
    return Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    );
  }

  Future<void> _capturerEtape1() async {
    if (_capturingGps) return;
    setState(() => _capturingGps = true);
    try {
      final pos = await _capturerPositionUnique();
      if (pos == null || !mounted) return;
      setState(() {
        _lat = pos.latitude;
        _lng = pos.longitude;
      });
      // Lance le reverse-geocoding en arrière-plan (best-effort).
      await _resoudreVille(pos.latitude, pos.longitude);
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

  Future<void> _resoudreVille(double lat, double lng) async {
    setState(() => _resolvingCity = true);
    try {
      final dio = Dio();
      final res = await dio.get<Map<String, dynamic>>(
        'https://nominatim.openstreetmap.org/reverse',
        queryParameters: {
          'lat': lat,
          'lon': lng,
          'format': 'json',
          'accept-language': 'fr',
          'zoom': 10,
        },
        options: Options(
          headers: {'User-Agent': 'FarmCash-Mobile/1.0'},
          receiveTimeout: const Duration(seconds: 8),
          sendTimeout: const Duration(seconds: 5),
        ),
      );
      final data = res.data;
      if (data == null) return;
      final addr = data['address'] as Map<String, dynamic>?;
      if (addr == null) return;
      final ville =
          (addr['city'] ??
                  addr['town'] ??
                  addr['village'] ??
                  addr['suburb'] ??
                  addr['county'])
              as String?;
      if (!mounted || ville == null) return;
      setState(() => _villeDetectee = ville);
      // Tente de matcher avec le référentiel `Ville`.
      await _matcherVilleReferentiel(ville);
    } catch (_) {
      // Best-effort, on continue sans bloquer.
    } finally {
      if (mounted) setState(() => _resolvingCity = false);
    }
  }

  Future<void> _matcherVilleReferentiel(String nom) async {
    try {
      final villes = await ref.read(villesParcelleProvider.future);
      Ville? match;
      try {
        match = villes.firstWhere(
          (v) => v.nom.toLowerCase() == nom.toLowerCase(),
        );
      } catch (_) {
        try {
          match = villes.firstWhere(
            (v) => v.nom.toLowerCase().contains(nom.toLowerCase()),
          );
        } catch (_) {
          match = null;
        }
      }
      if (match == null || !mounted) return;
      setState(() => _selectedVille = match);
    } catch (_) {
      // pas de match, on garde juste le label détecté.
    }
  }

  Future<void> _choisirVilleManuellement() async {
    FocusScope.of(context).unfocus();
    final villes = await ref.read(villesParcelleProvider.future);
    if (!mounted) return;
    final selected = await showModalBottomSheet<Ville>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: AppDimens.brBottomSheet,
      ),
      builder: (_) =>
          SelectionVilleSheet(villes: villes, initialId: _selectedVille?.id),
    );
    if (selected == null || !mounted) return;
    setState(() {
      _selectedVille = selected;
      _villeDetectee = selected.nom;
    });
    // Si aucune position GPS captée, on en cherche une approximative pour
    // la ville sélectionnée (forward-geocoding Nominatim). Si GPS déjà
    // capturé, on garde la position précise du producteur.
    if (_lat == null || _lng == null) {
      await _resoudreCoordsVille(selected.nom);
    }
  }

  Future<void> _resoudreCoordsVille(String nom) async {
    setState(() => _resolvingCity = true);
    try {
      final dio = Dio();
      final res = await dio.get<List<dynamic>>(
        'https://nominatim.openstreetmap.org/search',
        queryParameters: {
          'q': '$nom, Côte d\'Ivoire',
          'format': 'json',
          'limit': 1,
        },
        options: Options(
          headers: {'User-Agent': 'FarmCash-Mobile/1.0'},
          receiveTimeout: const Duration(seconds: 8),
          sendTimeout: const Duration(seconds: 5),
        ),
      );
      final list = res.data;
      if (list == null || list.isEmpty) return;
      final first = list.first as Map<String, dynamic>;
      final lat = double.tryParse(first['lat']?.toString() ?? '');
      final lon = double.tryParse(first['lon']?.toString() ?? '');
      if (lat == null || lon == null || !mounted) return;
      setState(() {
        _lat = lat;
        _lng = lon;
      });
    } catch (_) {
      if (mounted) {
        Snackbars.showInfo(
          context,
          'Position approximative indisponible. Capture ta position GPS '
          'quand tu seras sur ta parcelle.',
        );
      }
    } finally {
      if (mounted) setState(() => _resolvingCity = false);
    }
  }

  // ── Marcher autour : multi-GPS + Shoelace ──────────────────────────

  Future<void> _toggleMarche() async {
    if (_walking) {
      // Stop : termine la capture et calcule l'aire.
      await _walkSub?.cancel();
      _walkSub = null;
      setState(() {
        _walking = false;
        if (_walkPoints.length >= 3) {
          _aireCalculeeHa = _calculAirePolygoneHa(_walkPoints);
        } else {
          _aireCalculeeHa = null;
          Snackbars.showInfo(
            context,
            'Pas assez de points capturés (minimum 3). Réessaye.',
          );
        }
      });
      return;
    }

    // Start : permission + démarrage du stream.
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
        Snackbars.showErreur(context, 'Accès position refusé.');
      }
      return;
    }

    setState(() {
      _walking = true;
      _walkPoints.clear();
      _aireCalculeeHa = null;
    });

    _walkSub =
        Geolocator.getPositionStream(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.bestForNavigation,
            distanceFilter: 3, // 3m entre chaque point capturé
          ),
        ).listen((pos) {
          if (!mounted) return;
          setState(() => _walkPoints.add(pos));
        });
  }

  /// Aire d'un polygone défini en coordonnées GPS, retournée en hectares.
  /// Projection locale tangente (approximation correcte pour < 1 km²).
  static double _calculAirePolygoneHa(List<Position> pts) {
    if (pts.length < 3) return 0;
    const earthRadius = 6378137.0;
    final lat0Rad = pts.first.latitude * math.pi / 180;
    final cosLat0 = math.cos(lat0Rad);
    // Projection en mètres relatifs au premier point.
    final proj = pts.map((p) {
      final dx =
          (p.longitude - pts.first.longitude) *
          math.pi /
          180 *
          earthRadius *
          cosLat0;
      final dy =
          (p.latitude - pts.first.latitude) * math.pi / 180 * earthRadius;
      return (dx, dy);
    }).toList();
    // Shoelace formula.
    double sum = 0;
    for (var i = 0; i < proj.length; i++) {
      final (x1, y1) = proj[i];
      final (x2, y2) = proj[(i + 1) % proj.length];
      sum += x1 * y2 - x2 * y1;
    }
    final aireM2 = sum.abs() / 2;
    return aireM2 / 10000; // m² → ha
  }

  // ── Photo ──────────────────────────────────────────────────────────

  Future<void> _ajouterPhoto() async {
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
                  'Ajouter une photo',
                  style: AppTextStyles.titleLarge,
                ),
              ),
            ),
            const Divider(height: 1, color: AppColors.border),
            ListTile(
              leading: const Icon(
                Icons.photo_camera_outlined,
                color: AppColors.primary,
              ),
              title: const Text('Prendre une photo'),
              onTap: () => Navigator.of(ctx).pop(ImageSource.camera),
            ),
            const Divider(height: 1, color: AppColors.border),
            ListTile(
              leading: const Icon(
                Icons.photo_library_outlined,
                color: AppColors.primary,
              ),
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

  // ── Submit ─────────────────────────────────────────────────────────

  Future<void> _enregistrer() async {
    if (!_canSubmit) return;
    final saisieNom = _nomCtrl.text.trim();
    final villeNom = _selectedVille?.nom ?? _villeDetectee ?? 'Inconnue';
    final nomFinal = saisieNom.isEmpty ? 'Champ de $villeNom' : saisieNom;
    final superficie = _superficieValeur!;

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });
    try {
      final svc = ref.read(marketplaceServiceProvider);
      final parcelle = await svc.createParcelle(
        nom: nomFinal,
        superficieHa: superficie,
        produitId: null,
        lat: _lat,
        lng: _lng,
        villeId: _selectedVille?.id,
      );

      // Cultures sélectionnées → addCulture en // (répartition équitable).
      var allCulturesOk = true;
      if (_selectedProduitIds.isNotEmpty) {
        final ids = _selectedProduitIds.toList(growable: false);
        final partHa = superficie / ids.length;
        final results = await Future.wait(
          ids.map(
            (id) => svc
                .addCulture(
                  parcelleId: parcelle.id,
                  produitId: id,
                  superficieHa: partHa,
                )
                .then<Object?>((c) => c)
                .catchError((Object _) => null),
          ),
        );
        allCulturesOk = !results.contains(null);
      }

      // Upload photo parcelle (optionnelle) — non-bloquant, signalé si KO.
      var photoOk = true;
      if (_photo != null) {
        try {
          await svc.uploadAnnonceMedia(
            file: _photo!,
            annonceId: parcelle.id,
            targetType: MediaTargetType.parcelle,
          );
        } catch (_) {
          photoOk = false;
        }
      }

      if (!mounted) return;
      if (!allCulturesOk) {
        Snackbars.showInfo(
          context,
          'Parcelle créée mais certaines cultures n\'ont pas été '
          'enregistrées. Réessaye depuis "Mes parcelles".',
        );
      } else if (!photoOk) {
        Snackbars.showInfo(
          context,
          'Parcelle créée mais la photo n\'a pas pu être envoyée. '
          'Tu pourras la rajouter depuis le détail de la parcelle.',
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
                'Étape ${_pageIndex + 1} sur 3',
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
              BarreProgression(index: _pageIndex, total: 3),
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  onPageChanged: (i) => setState(() => _pageIndex = i),
                  children: [_buildStep1(), _buildStep2(), _buildStep3()],
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
        return 'Où est ta parcelle ?';
      case 1:
        return 'Combien c\'est grand ?';
      case 2:
        return 'Qu\'est-ce que tu cultives ?';
      default:
        return 'Créer une parcelle';
    }
  }

  // ─── Step 1 : Localisation ─────────────────────────────────────────

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
              // Avertissement clé : la position c'est celle de la parcelle,
              // pas celle de l'utilisateur. Le producteur DOIT être sur place.
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF7E6),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: const Color(0xFFE0A800),
                    width: AppDimens.borderThin,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.info_outline,
                      size: 18,
                      color: Color(0xFFB45309),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Place-toi sur ta parcelle avant d\'appuyer. '
                        'On enregistre la position du champ, pas la tienne.',
                        style: AppTextStyles.bodySmall.copyWith(
                          fontSize: 12,
                          color: const Color(0xFFB45309),
                          fontWeight: FontWeight.w600,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              BoutonGpsLarge(
                captured: _step1Valid,
                isLoading: _capturingGps,
                onTap: _capturerEtape1,
              ),
              if (_step1Valid) ...[
                const SizedBox(height: 16),
                RecapPosition(
                  lat: _lat!,
                  lng: _lng!,
                  villeDetectee: _villeDetectee,
                  isResolving: _resolvingCity,
                  onChangerVille: _choisirVilleManuellement,
                ),
              ] else ...[
                const SizedBox(height: 10),
                Center(
                  child: TextButton(
                    onPressed: _choisirVilleManuellement,
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                    child: Text(
                      'Je ne suis pas sur place — choisir une ville',
                      style: AppTextStyles.labelMedium.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 20),
              ChampLabel(
                label: 'Nom du champ (optionnel)',
                child: TextField(
                  controller: _nomCtrl,
                  enabled: !_isSubmitting,
                  textCapitalization: TextCapitalization.sentences,
                  maxLength: 100,
                  decoration: const InputDecoration(
                    hintText: 'Ex : Champ derrière la maison',
                    counterText: '',
                  ),
                ),
              ),
            ],
          ),
        ),
        BoutonPiedDePage(
          label: 'Suivant',
          enabled: _step1Valid && !_isSubmitting,
          onTap: _suivant,
        ),
      ],
    );
  }

  // ─── Step 2 : Mesure ──────────────────────────────────────────────

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
              Text(
                'Comment veux-tu indiquer la taille de ta parcelle ?',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 16),
              CartesModeMesure(
                modeMarche: _modeMarche,
                onSelect: (marche) {
                  if (_walking) return;
                  setState(() {
                    _modeMarche = marche;
                    _aireCalculeeHa = null;
                    _walkPoints.clear();
                  });
                },
              ),
              const SizedBox(height: 20),
              if (!_modeMarche) ...[
                ChampLabel(
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
                const SizedBox(height: 6),
                Text(
                  'Ex. 0.5 ha ≈ 50m × 100m',
                  style: AppTextStyles.bodySmall.copyWith(
                    fontSize: 11,
                    color: AppColors.textSubtle,
                  ),
                ),
              ] else
                PanneauContourner(
                  walking: _walking,
                  points: _walkPoints,
                  aireHa: _aireCalculeeHa,
                  onToggle: _toggleMarche,
                ),
            ],
          ),
        ),
        BoutonPiedDePage(
          label: 'Suivant',
          enabled: _step2Valid && !_isSubmitting,
          onTap: _suivant,
        ),
      ],
    );
  }

  // ─── Step 3 : Cultures + photo ────────────────────────────────────

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
                'Sélectionne ce que tu cultives sur cette parcelle. '
                'Tu pourras en ajouter plus tard.',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 16),
              ChampLabel(
                label: 'Rechercher',
                child: TextField(
                  controller: _rechercheCtrl,
                  enabled: !_isSubmitting,
                  decoration: const InputDecoration(
                    hintText: 'Tape pour filtrer (ex: maïs)',
                    prefixIcon: Icon(
                      Icons.search,
                      size: AppDimens.iconM,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              PanneauCultures(
                selectedIds: _selectedProduitIds,
                query: _rechercheCtrl.text,
                showAll: _afficherToutes,
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
                onToggleShowAll: () =>
                    setState(() => _afficherToutes = !_afficherToutes),
              ),
              const SizedBox(height: 20),
              ChampLabel(
                label: 'Photo (optionnel)',
                child: SelecteurPhoto(
                  photo: _photo,
                  enabled: !_isSubmitting,
                  onTap: _ajouterPhoto,
                  onRemove: () => setState(() => _photo = null),
                ),
              ),
              if (_errorMessage != null) ...[
                AppDimens.vGap16,
                Text(_errorMessage!, style: AppTextStyles.errorText),
              ],
            ],
          ),
        ),
        BoutonPiedDePage(
          label: 'Enregistrer ma parcelle',
          isLoading: _isSubmitting,
          enabled: _canSubmit,
          onTap: _enregistrer,
        ),
      ],
    );
  }
}
