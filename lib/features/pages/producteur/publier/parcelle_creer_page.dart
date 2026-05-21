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
import '../../../../models/produit.dart';
import '../../../../models/ville.dart';
import '../../../../services/marketplace_service.dart';
import '../../../../services/providers.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';
import '../../../widgets/communs/bouton_principal.dart';
import '../../../widgets/communs/chargement.dart';
import '../../../widgets/communs/snackbars.dart';

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

/// Top 6 cultures les plus fréquentes en Côte d'Ivoire — affichées en
/// premier dans la liste pour réduire la friction. Les autres sont
/// accessibles via "Voir toutes" / la recherche.
const _kTopCulturesCI = <String>[
  'Maïs',
  'Manioc',
  'Banane plantain',
  'Tomate',
  'Arachide',
  'Riz',
];

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

  bool get _canSubmit =>
      !_isSubmitting && _step1Valid && _step2Valid;

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
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
      ),
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
      final ville = (addr['city'] ??
              addr['town'] ??
              addr['village'] ??
              addr['suburb'] ??
              addr['county']) as String?;
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
      final villes = await ref.read(_villesProvider.future);
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
    final villes = await ref.read(_villesProvider.future);
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
        initialId: _selectedVille?.id,
      ),
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

    _walkSub = Geolocator.getPositionStream(
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
      final dx = (p.longitude - pts.first.longitude) *
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
              _ProgressBar(index: _pageIndex, total: 3),
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  onPageChanged: (i) => setState(() => _pageIndex = i),
                  children: [
                    _buildStep1(),
                    _buildStep2(),
                    _buildStep3(),
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
              _BigGpsButton(
                captured: _step1Valid,
                isLoading: _capturingGps,
                onTap: _capturerEtape1,
              ),
              if (_step1Valid) ...[
                const SizedBox(height: 16),
                _PositionRecap(
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
              _ChampLabel(
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
        _FooterButton(
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
              _ModeMesureCards(
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
                const SizedBox(height: 6),
                Text(
                  'Ex. 0.5 ha ≈ 50m × 100m',
                  style: AppTextStyles.bodySmall.copyWith(
                    fontSize: 11,
                    color: AppColors.textSubtle,
                  ),
                ),
              ] else
                _WalkAroundPanel(
                  walking: _walking,
                  points: _walkPoints,
                  aireHa: _aireCalculeeHa,
                  onToggle: _toggleMarche,
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
              _ChampLabel(
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
              _CulturesPanel(
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
              _ChampLabel(
                label: 'Photo (optionnel)',
                child: _PhotoPicker(
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
        _FooterButton(
          label: 'Enregistrer ma parcelle',
          isLoading: _isSubmitting,
          enabled: _canSubmit,
          onTap: _enregistrer,
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

// ─── Étape 1 ───────────────────────────────────────────────────────────

/// Gros bouton GPS dominant en haut de l'étape 1.
class _BigGpsButton extends StatelessWidget {
  const _BigGpsButton({
    required this.captured,
    required this.isLoading,
    required this.onTap,
  });

  final bool captured;
  final bool isLoading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isLoading ? null : onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
          decoration: BoxDecoration(
            color: captured ? const Color(0xFFE8F5E9) : AppColors.primary,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.primary,
              width: captured ? 1 : 0,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isLoading)
                SizedBox(
                  width: 26,
                  height: 26,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.6,
                    color: captured ? AppColors.primary : AppColors.onPrimary,
                  ),
                )
              else
                Icon(
                  captured ? Icons.check_circle : Icons.my_location,
                  size: 26,
                  color: captured ? AppColors.primary : AppColors.onPrimary,
                ),
              const SizedBox(width: 12),
              Flexible(
                child: Text(
                  captured
                      ? 'Position de la parcelle enregistrée'
                      : 'Je suis sur ma parcelle',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.titleMedium.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: captured ? AppColors.primary : AppColors.onPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Récap position GPS + ville détectée (avec lien "Changer").
class _PositionRecap extends StatelessWidget {
  const _PositionRecap({
    required this.lat,
    required this.lng,
    required this.villeDetectee,
    required this.isResolving,
    required this.onChangerVille,
  });

  final double lat;
  final double lng;
  final String? villeDetectee;
  final bool isResolving;
  final VoidCallback onChangerVille;

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
          Row(
            children: [
              const Icon(Icons.location_on_outlined,
                  size: 18, color: AppColors.primary),
              const SizedBox(width: 8),
              Expanded(
                child: isResolving
                    ? Row(
                        children: [
                          Text(
                            'Détection de la ville…',
                            style: AppTextStyles.bodyMedium.copyWith(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      )
                    : Text(
                        villeDetectee ?? 'Ville inconnue',
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
              ),
              if (!isResolving)
                TextButton(
                  onPressed: onChangerVille,
                  style: TextButton.styleFrom(
                    minimumSize: const Size(0, 0),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    'Changer',
                    style: AppTextStyles.labelMedium.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'lat: ${lat.toStringAsFixed(5)} · lng: ${lng.toStringAsFixed(5)}',
            style: AppTextStyles.bodySmall.copyWith(
              fontSize: 11,
              color: AppColors.textSubtle,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Étape 2 : Mode mesure ─────────────────────────────────────────────

class _ModeMesureCards extends StatelessWidget {
  const _ModeMesureCards({required this.modeMarche, required this.onSelect});
  final bool modeMarche;
  final ValueChanged<bool> onSelect;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ModeCard(
            icon: Icons.edit_outlined,
            title: 'Je saisis',
            subtitle: 'En hectares',
            selected: !modeMarche,
            onTap: () => onSelect(false),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _ModeCard(
            icon: Icons.directions_walk,
            title: 'Je marche autour',
            subtitle: 'GPS auto',
            selected: modeMarche,
            onTap: () => onSelect(true),
          ),
        ),
      ],
    );
  }
}

class _ModeCard extends StatelessWidget {
  const _ModeCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.fromLTRB(12, 14, 12, 14),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFFE8F5E9) : AppColors.background,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? AppColors.primary : AppColors.border,
              width: selected ? 1.5 : AppDimens.borderThin,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 28,
                color: selected ? AppColors.primary : AppColors.textSecondary,
              ),
              const SizedBox(height: 6),
              Text(
                title,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: selected ? AppColors.primary : AppColors.text,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: AppTextStyles.bodySmall.copyWith(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Panel "marcher autour" : explication, bouton démarrer/arrêter,
/// compteur de points, résultat aire calculée.
class _WalkAroundPanel extends StatelessWidget {
  const _WalkAroundPanel({
    required this.walking,
    required this.points,
    required this.aireHa,
    required this.onToggle,
  });

  final bool walking;
  final List<Position> points;
  final double? aireHa;
  final VoidCallback onToggle;

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
            walking
                ? 'Marche autour de ta parcelle. Chaque pas est enregistré.'
                : 'Pars du coin de ta parcelle et fais le tour à pied. '
                    'L\'app calcule la superficie automatiquement.',
            style: AppTextStyles.bodyMedium.copyWith(
              fontSize: 13,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.border,
                    width: AppDimens.borderThin,
                  ),
                ),
                child: Text(
                  '${points.length} points',
                  style: AppTextStyles.bodySmall.copyWith(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.text,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              if (aireHa != null)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.primary,
                      width: AppDimens.borderThin,
                    ),
                  ),
                  child: Text(
                    '${aireHa!.toStringAsFixed(2)} ha',
                    style: AppTextStyles.bodySmall.copyWith(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onToggle,
              icon: Icon(walking ? Icons.stop_circle : Icons.play_arrow),
              label: Text(
                walking ? 'Terminer la marche' : 'Démarrer la marche',
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: walking ? AppColors.error : AppColors.primary,
                side: BorderSide(
                  color: walking ? AppColors.error : AppColors.primary,
                  width: 1.5,
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Étape 3 : Cultures + photo ───────────────────────────────────────

final _produitsProvider = FutureProvider<List<Produit>>((ref) async {
  return ref.watch(marketplaceServiceProvider).listProduits();
});

final _villesProvider = FutureProvider<List<Ville>>((ref) async {
  return ref.watch(marketplaceServiceProvider).listVilles();
});

class _CulturesPanel extends ConsumerWidget {
  const _CulturesPanel({
    required this.selectedIds,
    required this.query,
    required this.showAll,
    required this.enabled,
    required this.onToggle,
    required this.onToggleShowAll,
  });

  final Set<String> selectedIds;
  final String query;
  final bool showAll;
  final bool enabled;
  final ValueChanged<String> onToggle;
  final VoidCallback onToggleShowAll;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(_produitsProvider);
    return async.when(
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: AppDimens.space12),
        child: Chargement(size: 18),
      ),
      error: (_, _) => Text(
        'Impossible de charger les produits.',
        style: AppTextStyles.bodySmall.copyWith(color: AppColors.error),
      ),
      data: (produits) {
        final q = query.trim().toLowerCase();
        if (q.isNotEmpty) {
          final filtered = produits
              .where((p) => p.nom.toLowerCase().contains(q))
              .toList(growable: false);
          return _Chips(
            produits: filtered,
            selectedIds: selectedIds,
            enabled: enabled,
            onToggle: onToggle,
          );
        }
        if (showAll) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Chips(
                produits: produits,
                selectedIds: selectedIds,
                enabled: enabled,
                onToggle: onToggle,
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: onToggleShowAll,
                child: const Text('Réduire'),
              ),
            ],
          );
        }
        // Vue par défaut : top 6 + bouton "Voir toutes".
        final top = produits
            .where((p) => _kTopCulturesCI.any((t) =>
                p.nom.toLowerCase().contains(t.toLowerCase())))
            .toList(growable: false);
        final fallback = top.isEmpty ? produits.take(6).toList() : top;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 2, bottom: 8),
              child: Text(
                'Cultures populaires',
                style: AppTextStyles.bodySmall.copyWith(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            _Chips(
              produits: fallback,
              selectedIds: selectedIds,
              enabled: enabled,
              onToggle: onToggle,
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: onToggleShowAll,
              icon: const Icon(Icons.unfold_more, size: 16),
              label: Text('Voir toutes (${produits.length})'),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _Chips extends StatelessWidget {
  const _Chips({
    required this.produits,
    required this.selectedIds,
    required this.enabled,
    required this.onToggle,
  });

  final List<Produit> produits;
  final Set<String> selectedIds;
  final bool enabled;
  final ValueChanged<String> onToggle;

  @override
  Widget build(BuildContext context) {
    if (produits.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Text(
          'Aucun produit trouvé.',
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      );
    }
    return Wrap(
      spacing: AppDimens.space8,
      runSpacing: AppDimens.space8,
      children: [
        for (final p in produits)
          _Chip(
            label: p.nom,
            selected: selectedIds.contains(p.id),
            enabled: enabled,
            onTap: () => onToggle(p.id),
          ),
      ],
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

class _PhotoPicker extends StatelessWidget {
  const _PhotoPicker({
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
          height: 100,
          decoration: BoxDecoration(
            color: AppColors.surfaceSoft,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.borderStrong,
              width: AppDimens.borderThin,
              style: BorderStyle.solid,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.add_a_photo_outlined,
                size: 24,
                color: AppColors.textSecondary,
              ),
              const SizedBox(height: 6),
              Text(
                'Ajouter une photo',
                style: AppTextStyles.bodySmall.copyWith(
                  fontSize: 12,
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
            height: 160,
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

// ─── Bottom sheet sélection ville manuelle ────────────────────────────

class _SelectionVilleSheet extends StatefulWidget {
  const _SelectionVilleSheet({required this.villes, this.initialId});

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
              Expanded(
                child: _filtered.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.all(AppDimens.space24),
                        child: Text(
                          'Aucune ville trouvée.',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(
                          vertical: AppDimens.space8,
                        ),
                        itemCount: _filtered.length,
                        separatorBuilder: (_, _) => const Divider(
                          height: 1,
                          thickness: AppDimens.borderThin,
                          color: AppColors.border,
                        ),
                        itemBuilder: (ctx, i) {
                          final v = _filtered[i];
                          final isCurrent = widget.initialId == v.id;
                          return ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: AppDimens.space24,
                              vertical: 2,
                            ),
                            title: Text(
                              v.displayWithRegion,
                              style: AppTextStyles.titleSmall,
                            ),
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
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
