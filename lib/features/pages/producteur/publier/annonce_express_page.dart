import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

import '../../../../api_client/api_exception.dart';
import '../../../../models/enums.dart';
import '../../../../models/extracted_annonce.dart';
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
import '../../../widgets/producteur/publier/bouton_pied_page.dart';
import '../../../widgets/producteur/publier/carte_radio.dart';
import '../../../widgets/producteur/publier/carte_radio_option.dart';
import '../../../widgets/producteur/publier/carte_recap.dart';
import '../../../widgets/producteur/publier/carte_total.dart';
import '../../../widgets/producteur/publier/champ_label.dart';
import '../../../widgets/producteur/publier/chips_kg_rapides.dart';
import '../../../widgets/producteur/publier/puce_publier.dart';
import '../../../widgets/producteur/publier/titre_section.dart';

enum _ExpressState { selectMedia, recordingAudio, processing, editFields }

enum _PostSubmitAction { mesAnnonces, republier }

class AnnonceExpressPage extends ConsumerStatefulWidget {
  const AnnonceExpressPage({super.key});

  @override
  ConsumerState<AnnonceExpressPage> createState() => _AnnonceExpressPageState();
}

class _AnnonceExpressPageState extends ConsumerState<AnnonceExpressPage> {
  _ExpressState _state = _ExpressState.selectMedia;

  // Bootstrap data
  bool _loadingCultures = true;
  List<Parcelle> _parcelles = const [];
  List<Culture> _cultures = const [];

  // Media references
  File? _mediaFile;
  bool _mediaIsVideo = true;

  // Enregistrement audio réel (package record).
  final AudioRecorder _audioRecorder = AudioRecorder();
  Timer? _recordingTimer;
  int _recordingSeconds = 0;
  StreamSubscription<Amplitude>? _ampSub;

  /// Amplitude micro normalisée 0..1 — pilote les barres du visualiseur
  /// pour donner un retour visuel *réel* que le micro capte bien (le
  /// producteur doit voir que sa voix est prise en compte).
  double _amplitude = 0;

  // Fields (populated by AI or user edits)
  Culture? _culture;
  final _qteCtrl = TextEditingController();
  final _prixCtrl = TextEditingController();
  ProductQuality _qualite = ProductQuality.standard;
  DateTime? _dateRecolte;
  final _titreCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();
  bool _audienceCoop = false;
  final Set<String> _certifications = {};
  final Set<String> _traitements = {};
  final _certifAutreCtrl = TextEditingController();
  final _traitementAutreCtrl = TextEditingController();

  bool _isSubmitting = false;

  /// `true` si la dernière extraction venait de la simulation locale
  /// (IA non connectée). Pilote une bannière d'avertissement en relecture.
  bool _isSimulation = false;

  @override
  void initState() {
    super.initState();
    _qteCtrl.addListener(_onChange);
    _prixCtrl.addListener(_onChange);
    _titreCtrl.addListener(_onChange);
    _descriptionCtrl.addListener(_onChange);
    _certifAutreCtrl.addListener(_onChange);
    _traitementAutreCtrl.addListener(_onChange);
    WidgetsBinding.instance.addPostFrameCallback((_) => _bootstrap());
  }

  @override
  void dispose() {
    _recordingTimer?.cancel();
    _ampSub?.cancel();
    _audioRecorder.dispose();
    _qteCtrl.dispose();
    _prixCtrl.dispose();
    _titreCtrl.dispose();
    _descriptionCtrl.dispose();
    _certifAutreCtrl.dispose();
    _traitementAutreCtrl.dispose();
    super.dispose();
  }

  void _onChange() {
    if (mounted) setState(() {});
  }

  Future<void> _bootstrap() async {
    try {
      final svc = ref.read(marketplaceServiceProvider);
      final results = await Future.wait([
        svc.listParcelles(),
        svc.listCultures(),
      ]);
      if (!mounted) return;
      setState(() {
        _parcelles = results[0] as List<Parcelle>;
        _cultures = results[1] as List<Culture>;
        _loadingCultures = false;
      });
    } catch (_) {
      if (mounted) {
        setState(() => _loadingCultures = false);
      }
      if (context.mounted) {
        Snackbars.showErreur(context, 'Impossible de charger tes cultures.');
      }
    }
  }

  // ─── Actions Média ────────────────────────────────────────────────

  Future<void> _pickVideo(ImageSource source) async {
    try {
      final picked = await ImagePicker().pickVideo(
        source: source,
        maxDuration: const Duration(seconds: 60),
      );
      if (picked == null || !mounted) return;
      setState(() {
        _mediaFile = File(picked.path);
        _mediaIsVideo = true;
      });
      _startAIProcessing();
    } catch (_) {
      if (context.mounted) {
        Snackbars.showErreur(context, 'Impossible d\'importer la vidéo.');
      }
    }
  }

  /// Démarre un *vrai* enregistrement micro vers un fichier .m4a temp.
  ///
  /// Avant, cette méthode était un mock (timer + faux fichier vide) :
  /// l'IA recevait un fichier sans son → extraction « n'importe quoi ».
  /// Maintenant on capture réellement la voix, avec retour visuel
  /// d'amplitude pour que le producteur voie que le micro fonctionne.
  Future<void> _startAudioRecording() async {
    try {
      // Permission micro (le package gère la demande système). Si
      // refusée, on prévient au lieu d'enregistrer dans le vide.
      final autorise = await _audioRecorder.hasPermission();
      if (!autorise) {
        if (mounted) {
          Snackbars.showErreur(
            context,
            "Autorise l'accès au micro pour enregistrer une note vocale.",
          );
        }
        return;
      }

      // Fichier cible dans le dossier temporaire de l'app. On enregistre
      // en WAV 16 kHz mono : format universellement accepté par les IA
      // (Gemini, Whisper) — contrairement au .m4a/mp4 dont le conteneur
      // pose souci à Gemini. 16 kHz mono = idéal voix + fichier léger.
      final dir = await getTemporaryDirectory();
      final chemin =
          '${dir.path}/annonce_express_${DateTime.now().millisecondsSinceEpoch}.wav';

      await _audioRecorder.start(
        const RecordConfig(
          encoder: AudioEncoder.wav,
          sampleRate: 16000,
          numChannels: 1,
        ),
        path: chemin,
      );

      if (!mounted) return;
      setState(() {
        _state = _ExpressState.recordingAudio;
        _recordingSeconds = 0;
        _amplitude = 0;
      });

      // Chrono d'affichage.
      _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (mounted) setState(() => _recordingSeconds++);
      });

      // Amplitude réelle → barres du visualiseur. `current` est en dBFS
      // (≈ -45 silence … 0 fort). On normalise sur 0..1.
      _ampSub = _audioRecorder
          .onAmplitudeChanged(const Duration(milliseconds: 200))
          .listen((amp) {
        if (!mounted) return;
        final norm = ((amp.current + 45) / 45).clamp(0.0, 1.0);
        setState(() => _amplitude = norm);
      });
    } catch (_) {
      if (mounted) setState(() => _state = _ExpressState.selectMedia);
      if (context.mounted) {
        Snackbars.showErreur(
          context,
          "Impossible de démarrer l'enregistrement. Réessaie.",
        );
      }
    }
  }

  /// Stoppe l'enregistrement et lance l'analyse IA — sauf si la capture
  /// est vide/trop courte (garde-fou contre les fichiers inexploitables).
  Future<void> _stopAudioRecording() async {
    _recordingTimer?.cancel();
    await _ampSub?.cancel();
    _ampSub = null;
    try {
      final chemin = await _audioRecorder.stop();
      if (chemin == null) {
        _retourSelectionAvecErreur('Aucun son capté. Réessaie.');
        return;
      }
      final fichier = File(chemin);
      // Garde-fou : un fichier < 2 Ko = quasi silence (micro coupé,
      // appui trop bref). Inutile d'envoyer ça à l'IA.
      final taille = await fichier.length();
      if (taille < 2048) {
        _retourSelectionAvecErreur(
          'Note vocale trop courte. Parle un peu plus longtemps.',
        );
        return;
      }
      if (!mounted) return;
      setState(() {
        _mediaFile = fichier;
        _mediaIsVideo = false;
      });
      _startAIProcessing();
    } catch (_) {
      _retourSelectionAvecErreur("Erreur à l'arrêt de l'enregistrement.");
    }
  }

  /// Annule l'enregistrement en cours (bouton Annuler / retour) en
  /// arrêtant proprement le recorder pour libérer le micro.
  Future<void> _cancelAudioRecording() async {
    _recordingTimer?.cancel();
    await _ampSub?.cancel();
    _ampSub = null;
    try {
      if (await _audioRecorder.isRecording()) {
        await _audioRecorder.stop();
      }
    } catch (_) {
      // Best-effort : on ignore, l'important est de revenir à l'écran.
    }
    if (mounted) setState(() => _state = _ExpressState.selectMedia);
  }

  void _retourSelectionAvecErreur(String message) {
    if (mounted) setState(() => _state = _ExpressState.selectMedia);
    if (context.mounted) Snackbars.showErreur(context, message);
  }

  // ─── Traitement IA ───────────────────────────────────────────────

  Future<void> _startAIProcessing() async {
    if (_mediaFile == null) return;
    setState(() {
      _state = _ExpressState.processing;
    });

    try {
      // Obtenir la localisation pour l'envoi de la requête IA
      var lat = 5.3484; // Abidjan par défaut
      var lng = -4.0244;
      try {
        final serviceOk = await Geolocator.isLocationServiceEnabled();
        if (serviceOk) {
          var permission = await Geolocator.checkPermission();
          if (permission == LocationPermission.denied) {
            permission = await Geolocator.requestPermission();
          }
          if (permission == LocationPermission.whileInUse ||
              permission == LocationPermission.always) {
            final pos = await Geolocator.getCurrentPosition(
              locationSettings: const LocationSettings(
                accuracy: LocationAccuracy.low,
              ),
            );
            lat = pos.latitude;
            lng = pos.longitude;
          }
        }
      } catch (_) {}

      final aiSvc = ref.read(aiServiceProvider);
      final ExtractedAnnonce result = await aiSvc.extractAnnonceFromMedia(
        file: _mediaFile!,
        lat: lat,
        lng: lng,
      );

      if (!mounted) return;

      // Associer le nom de produit extrait par l'IA avec une Culture réelle du farmer
      Culture? matchedCulture;
      if (result.productName != null && _cultures.isNotEmpty) {
        try {
          matchedCulture = _cultures.firstWhere(
            (c) =>
                c.produitNom != null &&
                c.produitNom!.toLowerCase().contains(result.productName!.toLowerCase()),
          );
        } catch (_) {
          // Si aucun match exact, on prend la première par défaut
          matchedCulture = _cultures.first;
        }
      } else if (_cultures.isNotEmpty) {
        matchedCulture = _cultures.first;
      }

      setState(() {
        _isSimulation = result.isSimulation;
        _culture = matchedCulture;
        if (result.quantiteKg != null) {
          _qteCtrl.text = _formatNombre(result.quantiteKg!);
        }
        if (result.prixParKg != null) {
          _prixCtrl.text = result.prixParKg!.toStringAsFixed(0);
        }
        if (result.qualite != null) {
          _qualite = result.qualite!;
        }
        if (result.description != null) {
          _descriptionCtrl.text = result.description!;
        }
        if (result.dateRecolte != null) {
          _dateRecolte = result.dateRecolte!;
        }

        // Certifications et traitements extraits
        _certifications.clear();
        if (result.certifications != null) {
          _certifications.addAll(result.certifications!);
        }
        _traitements.clear();
        if (result.traitements != null) {
          _traitements.addAll(result.traitements!);
        }

        _state = _ExpressState.editFields;
      });

      // Avertit clairement quand l'IA n'a pas été appelée (clé backend
      // absente, 404, réseau) : les champs sont alors des exemples, pas
      // ce que le producteur a réellement dit.
      if (_isSimulation && context.mounted) {
        Snackbars.showInfo(
          context,
          'Mode démo : IA non connectée, données d\'exemple. Vérifie tout.',
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _state = _ExpressState.selectMedia);
      }
      if (context.mounted) {
        Snackbars.showErreur(context, "L'analyse a échoué. Réessaie avec un autre fichier.");
      }
    }
  }

  // ─── Publication Finale ──────────────────────────────────────────

  Future<void> _publier() async {
    if (_culture == null || _qte == null || _prix == null || _isSubmitting) return;
    setState(() => _isSubmitting = true);

    try {
      // Capture GPS obligatoire
      final serviceOk = await Geolocator.isLocationServiceEnabled();
      if (!mounted) return;
      if (!serviceOk) {
        Snackbars.showErreur(context, 'Active la localisation de ton téléphone.');
        setState(() => _isSubmitting = false);
        return;
      }
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (!mounted) return;
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        Snackbars.showErreur(context, 'Accès à la position refusé.');
        setState(() => _isSubmitting = false);
        return;
      }
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );
      if (!mounted) return;

      final user = ref.read(currentUserProvider);
      final svc = ref.read(marketplaceServiceProvider);

      // Titre auto-généré ou saisi
      final produitNom = _culture!.produitNom ?? 'Produit';
      final titreSaisi = _titreCtrl.text.trim();
      final titre = titreSaisi.isEmpty
          ? '$produitNom ${_libelleQualite(_qualite)} — ${_formatNombre(_qte!)}kg'
          : titreSaisi;

      // Audience coop
      final coopId = (_audienceCoop && user?.cooperativeId != null)
          ? user!.cooperativeId
          : null;

      // Consolidations certifs & traitements
      final certifs = <String>{..._certifications};
      if (_certifAutreCtrl.text.trim().isNotEmpty) {
        certifs.add(_certifAutreCtrl.text.trim());
      }
      final traitements = <Map<String, dynamic>>[
        for (final t in _traitements) {'produit_traitement_nom': t},
      ];
      if (_traitementAutreCtrl.text.trim().isNotEmpty) {
        traitements.add({'produit_traitement_nom': _traitementAutreCtrl.text.trim()});
      }

      // Création de l'annonce
      final annonce = await svc.createAnnonceVente(
        produitId: _culture!.produitId,
        titre: titre,
        quantiteKg: _qte!,
        prixParKg: _prix!,
        lat: position.latitude,
        lng: position.longitude,
        qualite: _qualite,
        description: _descriptionCtrl.text.trim().isEmpty ? null : _descriptionCtrl.text.trim(),
        dateRecolte: _dateRecolte,
        assignedToCooperativeId: coopId,
        certifications: certifs.toList(growable: false),
        traitements: traitements.isEmpty ? null : traitements,
      );

      // Upload du fichier média réel (vidéo ImagePicker ou note vocale
      // .m4a enregistrée). On joint l'enregistrement à l'annonce pour
      // traçabilité (l'acheteur pourra écouter/voir la source).
      var mediaOk = true;
      if (_mediaFile != null && await _mediaFile!.exists()) {
        try {
          await svc.uploadAnnonceMedia(
            file: _mediaFile!,
            annonceId: annonce.id,
            type: _mediaIsVideo ? 'VIDEO' : 'AUDIO',
          );
        } catch (_) {
          mediaOk = false;
        }
      }

      if (!mounted) return;
      await _afficherSuccesEtChoix(mediaOk: mediaOk);
    } on ApiException catch (e) {
      if (mounted) Snackbars.showErreur(context, e.message);
    } catch (e) {
      if (mounted) Snackbars.showErreur(context, 'Erreur de publication : $e');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _afficherSuccesEtChoix({required bool mediaOk}) async {
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
          mediaOk
              ? 'Ton annonce express a été générée par l\'IA et est maintenant en ligne !'
              : 'Annonce publiée, mais l\'enregistrement n\'a pas pu être téléversé.',
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
        Navigator.of(context).pop(); // ferme la page express
        context.push(RouteNames.producteurMesPublicationsPath);
        break;
      case _PostSubmitAction.republier:
        setState(() {
          _state = _ExpressState.selectMedia;
          _mediaFile = null;
          _culture = null;
          _qteCtrl.clear();
          _prixCtrl.clear();
          _qualite = ProductQuality.standard;
          _descriptionCtrl.clear();
          _titreCtrl.clear();
          _certifAutreCtrl.clear();
          _traitementAutreCtrl.clear();
          _certifications.clear();
          _traitements.clear();
          _dateRecolte = null;
          _audienceCoop = false;
        });
        break;
      case null:
        Navigator.of(context).pop();
    }
  }

  // ─── Helpers Métier ──────────────────────────────────────────────

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
    return double.tryParse(raw);
  }

  double? get _prix {
    final raw = _prixCtrl.text.trim().replaceAll(',', '.');
    if (raw.isEmpty) return null;
    return double.tryParse(raw);
  }

  double get _total => (_qte ?? 0) * (_prix ?? 0);

  bool get _isValid => _culture != null && _qte != null && _prix != null;

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

  Future<void> _choisirDateRecolte() async {
    FocusScope.of(context).unfocus();
    final now = DateTime.now();
    final initial = _dateRecolte ?? now;
    await showCupertinoModalPopup<DateTime>(
      context: context,
      builder: (BuildContext context) => Container(
        height: 250,
        padding: const EdgeInsets.only(top: 6.0),
        margin: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
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

  // ─── Build UI ────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_isSubmitting && _state != _ExpressState.processing,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          elevation: 0,
          scrolledUnderElevation: 0,
          toolbarHeight: 64,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, size: AppDimens.iconL),
            onPressed: (_isSubmitting || _state == _ExpressState.processing)
                ? null
                : () {
                    if (_state == _ExpressState.recordingAudio) {
                      _cancelAudioRecording();
                    } else if (_state == _ExpressState.editFields) {
                      setState(() => _state = _ExpressState.selectMedia);
                    } else {
                      Navigator.of(context).pop();
                    }
                  },
          ),
          title: Text(
            'Annonce Express par IA',
            style: AppTextStyles.titleMedium.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        body: SafeArea(
          child: _loadingCultures
              ? const Center(child: Chargement(size: 24))
              : _buildCurrentState(),
        ),
      ),
    );
  }

  Widget _buildCurrentState() {
    switch (_state) {
      case _ExpressState.selectMedia:
        return _buildSelectMedia();
      case _ExpressState.recordingAudio:
        return _buildRecordingAudio();
      case _ExpressState.processing:
        return _buildProcessing();
      case _ExpressState.editFields:
        return _buildEditFields();
    }
  }

  // ── Étape 1 : Choix du média ─────────────────────────────────────

  Widget _buildSelectMedia() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimens.pagePaddingH),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppDimens.vGap16,
          Text(
            'Publie ton annonce en 1 clic. Enregistre une courte vidéo de ta récolte en parlant, ou laisse simplement une note vocale décrivant ton produit.',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
          AppDimens.vGap32,
          _buildMediaOptionCard(
            icon: Icons.videocam_outlined,
            title: 'Enregistrer une vidéo',
            subtitle: 'Filme ta récolte en disant la quantité et le prix',
            onTap: () => _pickVideo(ImageSource.camera),
          ),
          AppDimens.vGap16,
          _buildMediaOptionCard(
            icon: Icons.mic_none_outlined,
            title: 'Enregistrer une note vocale',
            subtitle: 'Parle librement pour décrire ce que tu vends',
            onTap: _startAudioRecording,
          ),
          AppDimens.vGap16,
          _buildMediaOptionCard(
            icon: Icons.video_library_outlined,
            title: 'Choisir une vidéo existante',
            subtitle: 'Sélectionne un enregistrement depuis ta galerie',
            onTap: () => _pickVideo(ImageSource.gallery),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.only(bottom: AppDimens.space24),
            child: TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Retourner à la saisie manuelle',
                style: AppTextStyles.titleSmall.copyWith(
                  color: AppColors.primary,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMediaOptionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimens.radiusCard),
      child: Container(
        padding: const EdgeInsets.all(AppDimens.space16),
        decoration: BoxDecoration(
          color: AppColors.background,
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(AppDimens.radiusCard),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                color: kSoftBgPublier,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Icon(icon, size: 22, color: AppColors.primary),
            ),
            AppDimens.hGap16,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.titleMedium.copyWith(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.textSubtle),
          ],
        ),
      ),
    );
  }

  // ── Étape 2 : Recording Audio Mock UI ────────────────────────────

  Widget _buildRecordingAudio() {
    String formatTime(int sec) {
      final m = (sec ~/ 60).toString().padLeft(2, '0');
      final s = (sec % 60).toString().padLeft(2, '0');
      return '$m:$s';
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Spacer(),
        Text(
          'Enregistrement en cours...',
          style: AppTextStyles.titleMedium.copyWith(
            color: AppColors.textSecondary,
            fontSize: 15,
          ),
        ),
        AppDimens.vGap16,
        Text(
          formatTime(_recordingSeconds),
          style: AppTextStyles.titleLarge.copyWith(
            fontSize: 48,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
          ),
        ),
        AppDimens.vGap32,
        // Visualiseur d'ondes piloté par l'amplitude *réelle* du micro
        // (sobre, pas de look « IA »). Les barres bougent quand le
        // producteur parle → preuve visible que sa voix est captée.
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(7, (i) {
            // Facteur par barre pour un rendu vivant (barres centrales
            // plus hautes), multiplié par l'amplitude instantanée.
            final facteur = (i == 3) ? 1.0 : (i.isEven ? 0.55 : 0.8);
            final hauteur = 6.0 + (54.0 * _amplitude * facteur);
            return AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: 5,
              height: hauteur,
              decoration: BoxDecoration(
                color: AppColors.primary
                    .withValues(alpha: 0.4 + 0.5 * _amplitude),
                borderRadius: BorderRadius.circular(3),
              ),
            );
          }),
        ),
        const Spacer(),
        Padding(
          padding: const EdgeInsets.all(AppDimens.space24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ElevatedButton(
                onPressed: _stopAudioRecording,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppDimens.radius),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  "J'ai terminé de parler",
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
              ),
              AppDimens.vGap12,
              TextButton(
                onPressed: _cancelAudioRecording,
                child: const Text(
                  'Annuler',
                  style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Étape 3 : Chargement IA ──────────────────────────────────────

  Widget _buildProcessing() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: AppDimens.pagePaddingH),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Chargement(size: 32),
            AppDimens.vGap24,
            Text(
              "Extraction des informations...",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.text,
              ),
            ),
            AppDimens.vGap8,
            Text(
              "L'IA analyse ton enregistrement pour déterminer la culture, la quantité, le prix et la qualité.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Étape 4 : Relecture & validation du formulaire ────────────────

  Widget _buildEditFields() {
    if (_cultures.isEmpty) {
      return const Center(child: Text("Erreur: aucune culture déclarée"));
    }

    final user = ref.watch(currentUserProvider);
    final aDesCoop = user?.cooperativeId != null && user!.cooperativeId!.isNotEmpty;

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
              // Bannière d'avertissement quand l'IA n'a PAS été appelée
              // (clé backend absente, 404, réseau) : les champs ci-dessous
              // sont des exemples génériques, pas les vraies paroles.
              if (_isSimulation) ...[
                Container(
                  padding: const EdgeInsets.all(AppDimens.space12),
                  decoration: BoxDecoration(
                    // Ambre « attention » (pas de AppColors.warning dans le
                    // thème) — distinct du rouge erreur et du vert succès.
                    color: const Color(0xFFB45309).withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(AppDimens.radius),
                    border: Border.all(
                      color: const Color(0xFFB45309).withValues(alpha: 0.4),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.info_outline,
                          size: 20, color: Color(0xFFB45309)),
                      AppDimens.hGap12,
                      Expanded(
                        child: Text(
                          "Mode démo : l'IA n'est pas connectée (clé API "
                          'manquante côté serveur). Les valeurs ci-dessous '
                          'sont des exemples — corrige-les avant de publier.',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.text,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                AppDimens.vGap16,
              ],
              Text(
                "Vérifie et ajuste les données extraites par l'IA avant de valider la publication de ton annonce.",
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ),
              AppDimens.vGap24,

              // 1. Sélection de la culture
              const TitreSection('Culture détectée'),
              AppDimens.vGap12,
              DropdownButtonFormField<Culture>(
                initialValue: _culture,
                isExpanded: true,
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
                items: _cultures.map((c) {
                  final p = _parcelleDeLaCulture(c);
                  final extraStr = p != null ? ' (${p.nom})' : '';
                  return DropdownMenuItem<Culture>(
                    value: c,
                    child: Text(
                      '${c.produitNom ?? "Produit"}$extraStr',
                      style: AppTextStyles.bodyMedium,
                    ),
                  );
                }).toList(),
                onChanged: (val) => setState(() => _culture = val),
              ),
              const SizedBox(height: 20),

              // 2. Quantité
              const TitreSection('Quantité'),
              AppDimens.vGap12,
              TextField(
                controller: _qteCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))],
                decoration: const InputDecoration(
                  hintText: '0',
                  suffixText: 'kg',
                ),
              ),
              AppDimens.vGap8,
              ChipsKgRapides(onPick: (kg) => _qteCtrl.text = kg.toString()),
              const SizedBox(height: 20),

              // 3. Prix par kg
              const TitreSection('Prix par kg'),
              AppDimens.vGap12,
              TextField(
                controller: _prixCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))],
                decoration: const InputDecoration(
                  hintText: '0',
                  suffixText: 'F CFA / kg',
                ),
              ),
              if (_prix != null) ...[
                AppDimens.vGap8,
                ApercuPrixNet(prixBrutKg: _prix!, tauxFarmcash: 0.03),
              ],
              if (_total > 0) ...[
                AppDimens.vGap12,
                CarteTotal(totalFormate: _formatMontant(_total)),
              ],
              const SizedBox(height: 20),

              // 4. Qualité
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
              const SizedBox(height: 20),

              // 5. Audience
              const TitreSection('Audience'),
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
                  CarteRadioOption(
                    emoji: '🤝',
                    title: 'Ma coopérative',
                    subtitle: aDesCoop
                        ? 'La coop valide et agrège avant publication'
                        : 'Rejoins d\'abord une coopérative dans ton profil',
                    selected: aDesCoop && _audienceCoop,
                    enabled: aDesCoop && !_isSubmitting,
                    onTap: aDesCoop ? () => setState(() => _audienceCoop = true) : null,
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // 6. Autres champs optionnels
              const TitreSection('Informations complémentaires (optionnel)'),
              AppDimens.vGap12,
              ChampLabel(
                label: 'Titre de l\'annonce',
                child: TextField(
                  controller: _titreCtrl,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(hintText: 'Auto-généré si vide'),
                ),
              ),
              const SizedBox(height: 14),
              ChampLabel(
                label: 'Description',
                child: TextField(
                  controller: _descriptionCtrl,
                  maxLines: 2,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(hintText: 'Donne plus de détails sur le lot'),
                ),
              ),
              const SizedBox(height: 14),
              ChampLabel(
                label: 'Date de récolte',
                child: InkWell(
                  onTap: _choisirDateRecolte,
                  borderRadius: AppDimens.brInput,
                  child: Container(
                    height: AppDimens.inputHeight,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: AppDimens.brInput,
                      border: Border.all(color: AppColors.borderStrong, width: AppDimens.borderThin),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            _dateRecolte == null
                                ? 'Optionnel — quand as-tu récolté ?'
                                : _formatDate(_dateRecolte!),
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: _dateRecolte == null ? AppColors.textSubtle : AppColors.text,
                            ),
                          ),
                        ),
                        if (_dateRecolte != null)
                          InkWell(
                            onTap: () => setState(() => _dateRecolte = null),
                            child: const Icon(Icons.close, size: 16, color: AppColors.textSubtle),
                          )
                        else
                          const Icon(Icons.calendar_today_outlined, size: AppDimens.iconM, color: AppColors.textSecondary),
                      ],
                    ),
                  ),
                ),
              ),
              AppDimens.vGap24,

              if (_culture != null)
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
          enabled: _isValid && !_isSubmitting,
          onTap: _publier,
        ),
      ],
    );
  }
}
