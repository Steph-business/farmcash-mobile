import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../models/analyse_plante.dart';
import '../../../../services/providers.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';
import '../../../widgets/communs/snackbars.dart';
import '../../../widgets/producteur/ai/historique_court_analyses.dart';
import '../../../widgets/producteur/ai/resultat_view_analyse.dart';
import '../../../widgets/producteur/ai/saisie_view_analyse.dart';

/// Diagnostiquer une plante — flow complet : tap-pour-photo → photo + champs
/// optionnels (parcelle, notes) → upload → résultat (maladie, traitements).
///
/// La page gère elle-même son state (sélection / analyse / résultat) sans
/// pousser une nouvelle route pour le résultat (UX d'un wizard à 3 phases).
class AnalysePlantePage extends ConsumerStatefulWidget {
  const AnalysePlantePage({super.key});

  @override
  ConsumerState<AnalysePlantePage> createState() => _AnalysePlantePageState();
}

class _AnalysePlantePageState extends ConsumerState<AnalysePlantePage> {
  File? _photo;
  String? _parcelleId;
  final _notesCtrl = TextEditingController();
  bool _isAnalyzing = false;
  AnalysePlante? _result;

  @override
  void dispose() {
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
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
                  'Photo de la plante',
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
      if (!mounted) return;
      if (picked == null) return;
      setState(() => _photo = File(picked.path));
    } catch (_) {
      if (!mounted) return;
      Snackbars.showErreur(context, "Impossible d'ajouter la photo.");
    }
  }

  Future<void> _lancerAnalyse() async {
    if (_photo == null || _isAnalyzing) return;
    setState(() => _isAnalyzing = true);
    try {
      final analyse = await ref.read(aiServiceProvider).analyzePlant(
            imagePath: _photo!.path,
            parcelleId: _parcelleId,
            notes:
                _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
          );
      if (!mounted) return;
      setState(() {
        _result = analyse;
        _isAnalyzing = false;
      });
      // Rafraîchit l'historique court (5 dernières) en arrière-plan.
      ref.invalidate(recentAnalysesAiProvider);
    } catch (_) {
      if (!mounted) return;
      setState(() => _isAnalyzing = false);
      Snackbars.showErreur(
        context,
        "L'analyse a échoué. Réessaie dans quelques instants.",
      );
    }
  }

  void _recommencer() {
    setState(() {
      _photo = null;
      _parcelleId = null;
      _notesCtrl.clear();
      _result = null;
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
          'Diagnostiquer une plante',
          style: AppTextStyles.titleSmall.copyWith(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: false,
      ),
      body: _result != null
          ? ResultatViewAnalyse(
              analyse: _result!,
              photo: _photo,
              onRecommencer: _recommencer,
            )
          : SaisieViewAnalyse(
              photo: _photo,
              parcelleId: _parcelleId,
              notesCtrl: _notesCtrl,
              isAnalyzing: _isAnalyzing,
              onPickPhoto: _pickImage,
              onChangeParcelle: (v) => setState(() => _parcelleId = v),
              onLancer: _lancerAnalyse,
            ),
    );
  }
}
