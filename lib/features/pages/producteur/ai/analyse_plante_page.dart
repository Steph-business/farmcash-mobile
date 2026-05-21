import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../../../models/analyse_plante.dart';
import '../../../../models/parcelle.dart';
import '../../../../models/traitement.dart';
import '../../../../routing/route_names.dart';
import '../../../../services/providers.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';
import '../../../widgets/communs/chargement.dart';
import '../../../widgets/communs/snackbars.dart';
import '../../../widgets/communs/vue_erreur.dart';

const Color _kPrimarySoft = Color(0xFFE8F5E9);
const Color _kWarnSoft = Color(0xFFFFF8E1);
const Color _kWarn = Color(0xFFB26A00);
const Color _kRedSoft = Color(0xFFFDECEA);

/// 5 dernières analyses récentes (historique court inline sur la page).
final _recentAnalysesProvider =
    FutureProvider.autoDispose<List<AnalysePlante>>((ref) async {
  final page = await ref
      .watch(aiServiceProvider)
      .listPlantAnalyses(page: 1, limit: 5);
  return page.data;
});

/// Parcelles du farmer pour le dropdown — fail silencieusement à liste vide.
final _parcellesPourAnalyseProvider =
    FutureProvider.autoDispose<List<Parcelle>>((ref) async {
  try {
    return await ref.watch(marketplaceServiceProvider).listParcelles();
  } catch (_) {
    return const <Parcelle>[];
  }
});

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
            notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
          );
      if (!mounted) return;
      setState(() {
        _result = analyse;
        _isAnalyzing = false;
      });
      // Rafraîchit l'historique court (5 dernières) en arrière-plan.
      ref.invalidate(_recentAnalysesProvider);
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
          ? _ResultatView(
              analyse: _result!,
              photo: _photo,
              onRecommencer: _recommencer,
            )
          : _SaisieView(
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

// ─── Phase 1 : Saisie (photo + parcelle + notes) ────────────────────────

class _SaisieView extends ConsumerWidget {
  const _SaisieView({
    required this.photo,
    required this.parcelleId,
    required this.notesCtrl,
    required this.isAnalyzing,
    required this.onPickPhoto,
    required this.onChangeParcelle,
    required this.onLancer,
  });

  final File? photo;
  final String? parcelleId;
  final TextEditingController notesCtrl;
  final bool isAnalyzing;
  final VoidCallback onPickPhoto;
  final ValueChanged<String?> onChangeParcelle;
  final VoidCallback onLancer;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final parcellesAsync = ref.watch(_parcellesPourAnalyseProvider);

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppDimens.pagePaddingH,
        AppDimens.space16,
        AppDimens.pagePaddingH,
        AppDimens.space24,
      ),
      children: [
        _Hero(photo: photo, onTap: onPickPhoto),
        if (photo != null) ...[
          AppDimens.vGap24,
          _Label('Parcelle (optionnel)'),
          AppDimens.vGap8,
          parcellesAsync.when(
            loading: () => const SizedBox(
              height: 50,
              child: Chargement(size: 18),
            ),
            error: (_, _) => _ParcelleDropdown(
              value: null,
              parcelles: const [],
              onChanged: onChangeParcelle,
            ),
            data: (parcelles) => _ParcelleDropdown(
              value: parcelleId,
              parcelles: parcelles,
              onChanged: onChangeParcelle,
            ),
          ),
          AppDimens.vGap16,
          _Label('Notes (optionnel)'),
          AppDimens.vGap8,
          _NotesField(controller: notesCtrl),
          AppDimens.vGap24,
          _BtnLancer(isAnalyzing: isAnalyzing, onTap: onLancer),
        ],
        AppDimens.vGap32,
        const _HistoriqueCourt(),
      ],
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero({required this.photo, required this.onTap});

  final File? photo;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: AppDimens.brCard,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppDimens.brCard,
        child: Container(
          height: 240,
          decoration: BoxDecoration(
            color: photo == null ? AppColors.surfaceSoft : AppColors.surface,
            borderRadius: AppDimens.brCard,
            border: Border.all(
              color: AppColors.border,
              width: AppDimens.borderThin,
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: photo != null
              ? Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.file(photo!, fit: BoxFit.cover),
                    Positioned(
                      right: 12,
                      bottom: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppColors.border,
                            width: AppDimens.borderThin,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.cached,
                              size: 14,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Changer',
                              style: AppTextStyles.labelSmall.copyWith(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: const BoxDecoration(
                        color: _kPrimarySoft,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.photo_camera_outlined,
                        size: 26,
                        color: AppColors.primary,
                      ),
                    ),
                    AppDimens.vGap12,
                    Text(
                      'Touche pour prendre en photo',
                      style: AppTextStyles.titleSmall.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    AppDimens.vGap4,
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Text(
                        'Cadre une feuille malade pour le diagnostic.',
                        style: AppTextStyles.bodySmall,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: AppTextStyles.labelMedium.copyWith(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: AppColors.text,
      ),
    );
  }
}

class _ParcelleDropdown extends StatelessWidget {
  const _ParcelleDropdown({
    required this.value,
    required this.parcelles,
    required this.onChanged,
  });

  final String? value;
  final List<Parcelle> parcelles;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppDimens.inputHeight,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppDimens.brInput,
        border: Border.all(
          color: AppColors.borderStrong,
          width: AppDimens.borderThin,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String?>(
          value: value,
          isExpanded: true,
          hint: Text(
            parcelles.isEmpty
                ? 'Aucune parcelle enregistrée'
                : 'Sélectionner une parcelle',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSubtle,
            ),
          ),
          icon: const Icon(
            Icons.keyboard_arrow_down,
            color: AppColors.textSecondary,
          ),
          items: [
            const DropdownMenuItem<String?>(
              value: null,
              child: Text('Aucune parcelle'),
            ),
            ...parcelles.map(
              (p) => DropdownMenuItem<String?>(
                value: p.id,
                child: Text(
                  p.nom,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
          onChanged: parcelles.isEmpty ? null : onChanged,
        ),
      ),
    );
  }
}

class _NotesField extends StatelessWidget {
  const _NotesField({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      minLines: 3,
      maxLines: 5,
      style: AppTextStyles.bodyMedium,
      decoration: InputDecoration(
        hintText: 'Ex : taches jaunes apparues après la pluie…',
        hintStyle: AppTextStyles.hint,
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
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
    );
  }
}

class _BtnLancer extends StatelessWidget {
  const _BtnLancer({required this.isAnalyzing, required this.onTap});

  final bool isAnalyzing;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppDimens.buttonHeight,
      child: ElevatedButton(
        onPressed: isAnalyzing ? null : onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.5),
          elevation: 0,
          shape: const RoundedRectangleBorder(
            borderRadius: AppDimens.brButton,
          ),
        ),
        child: isAnalyzing
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.onPrimary,
                ),
              )
            : Text("Lancer l'analyse", style: AppTextStyles.button),
      ),
    );
  }
}

// ─── Historique court (5 dernières analyses) ────────────────────────────

class _HistoriqueCourt extends ConsumerWidget {
  const _HistoriqueCourt();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(_recentAnalysesProvider);
    return async.when(
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: AppDimens.space16),
        child: Chargement(size: 18),
      ),
      error: (_, _) => Padding(
        padding: const EdgeInsets.symmetric(vertical: AppDimens.space16),
        child: VueErreur(
          message: "Impossible de charger l'historique.",
          onRetry: () => ref.invalidate(_recentAnalysesProvider),
        ),
      ),
      data: (items) {
        if (items.isEmpty) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: AppDimens.space12),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Analyses précédentes',
                      style: AppTextStyles.titleSmall.copyWith(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () => context.push(
                      RouteNames.producteurAiAnalysesHistoriquePath,
                    ),
                    borderRadius: BorderRadius.circular(6),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 2,
                      ),
                      child: Text(
                        'Voir tout',
                        style: AppTextStyles.link.copyWith(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: AppDimens.brCard,
                border: Border.all(
                  color: AppColors.border,
                  width: AppDimens.borderThin,
                ),
              ),
              child: Column(
                children: List.generate(items.length, (i) {
                  return _AnalyseListTile(
                    analyse: items[i],
                    isLast: i == items.length - 1,
                  );
                }),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Tile compact pour une analyse (utilisé inline ici + dans la page
/// historique complète). Public pour partage avec `_AnalyseListTile`
/// dans `analyses_historique_page.dart`.
class _AnalyseListTile extends StatelessWidget {
  const _AnalyseListTile({required this.analyse, required this.isLast});

  final AnalysePlante analyse;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final maladie = analyse.diseaseDetected?.trim();
    final libelle =
        (maladie != null && maladie.isNotEmpty) ? maladie : 'En cours…';
    final risk = analyse.riskLevel?.toLowerCase();
    final date = analyse.createdAt;
    return InkWell(
      onTap: () {
        // V1 : pas de page détail dédiée. On affiche un dialog compact.
        showDialog<void>(
          context: context,
          builder: (_) => _AnalyseDetailDialog(analyse: analyse),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimens.space16,
          vertical: 12,
        ),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isLast ? Colors.transparent : AppColors.border,
              width: AppDimens.borderThin,
            ),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.surfaceSoft,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.border,
                  width: AppDimens.borderThin,
                ),
              ),
              clipBehavior: Clip.antiAlias,
              child: analyse.imageUrl.isNotEmpty
                  ? Image.network(
                      analyse.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => const Icon(
                        Icons.image_outlined,
                        color: AppColors.textSubtle,
                        size: 20,
                      ),
                    )
                  : const Icon(
                      Icons.eco_outlined,
                      color: AppColors.textSubtle,
                      size: 20,
                    ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    libelle,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _formatDate(date),
                    style: AppTextStyles.bodySmall.copyWith(fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (risk != null && risk.isNotEmpty) ...[
              _ChipRisque(risk: risk),
              const SizedBox(width: 8),
            ],
            const Icon(
              Icons.chevron_right,
              color: AppColors.textSubtle,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

class _ChipRisque extends StatelessWidget {
  const _ChipRisque({required this.risk});

  final String risk;

  @override
  Widget build(BuildContext context) {
    final (label, bg, fg) = switch (risk) {
      'high' || 'eleve' || 'haut' => ('Élevé', _kRedSoft, AppColors.error),
      'medium' || 'moyen' => ('Moyen', _kWarnSoft, _kWarn),
      'low' || 'faible' => ('Faible', _kPrimarySoft, AppColors.primary),
      _ => (risk, AppColors.surfaceSoft, AppColors.textSecondary),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: AppTextStyles.labelSmall.copyWith(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: fg,
        ),
      ),
    );
  }
}

class _AnalyseDetailDialog extends ConsumerWidget {
  const _AnalyseDetailDialog({required this.analyse});

  final AnalysePlante analyse;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final maladie = analyse.diseaseDetected?.trim();
    return Dialog(
      shape: const RoundedRectangleBorder(
        borderRadius: AppDimens.brCard,
      ),
      backgroundColor: AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(AppDimens.space16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              (maladie != null && maladie.isNotEmpty)
                  ? maladie
                  : 'Analyse en cours',
              style: AppTextStyles.titleLarge.copyWith(
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
            AppDimens.vGap8,
            Text(
              _formatDate(analyse.createdAt),
              style: AppTextStyles.bodySmall.copyWith(fontSize: 12),
            ),
            AppDimens.vGap16,
            if (analyse.recommendations != null &&
                analyse.recommendations!.trim().isNotEmpty)
              Text(
                analyse.recommendations!.trim(),
                style: AppTextStyles.bodyMedium,
              )
            else
              Text(
                "Aucune recommandation détaillée n'a été fournie pour cette "
                'analyse.',
                style: AppTextStyles.bodySmall,
              ),
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
    );
  }
}

// ─── Phase 2 : Résultat ─────────────────────────────────────────────────

class _ResultatView extends ConsumerWidget {
  const _ResultatView({
    required this.analyse,
    required this.photo,
    required this.onRecommencer,
  });

  final AnalysePlante analyse;
  final File? photo;
  final VoidCallback onRecommencer;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final maladie = analyse.diseaseDetected?.trim();
    final confidence = analyse.confidenceScore;
    final recommandations = analyse.recommendations?.trim();

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppDimens.pagePaddingH,
        AppDimens.space16,
        AppDimens.pagePaddingH,
        AppDimens.space32,
      ),
      children: [
        // Photo
        Container(
          height: 220,
          decoration: BoxDecoration(
            color: AppColors.surfaceSoft,
            borderRadius: AppDimens.brCard,
            border: Border.all(
              color: AppColors.border,
              width: AppDimens.borderThin,
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: photo != null
              ? Image.file(photo!, fit: BoxFit.cover)
              : (analyse.imageUrl.isNotEmpty
                  ? Image.network(
                      analyse.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) =>
                          const _PhotoFallback(),
                    )
                  : const _PhotoFallback()),
        ),
        AppDimens.vGap24,
        // Maladie + confiance
        Text(
          (maladie != null && maladie.isNotEmpty)
              ? maladie
              : 'Diagnostic indisponible',
          style: AppTextStyles.headlineMedium.copyWith(
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        if (confidence != null) ...[
          AppDimens.vGap4,
          Text(
            'Confiance : ${(confidence * 100).clamp(0, 100).toStringAsFixed(0)}%',
            style: AppTextStyles.bodySmall.copyWith(fontSize: 13),
          ),
        ],
        AppDimens.vGap16,
        // Recommandations
        if (recommandations != null && recommandations.isNotEmpty)
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: AppDimens.brCard,
              border: Border.all(
                color: AppColors.border,
                width: AppDimens.borderThin,
              ),
            ),
            padding: const EdgeInsets.all(AppDimens.space16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Recommandations',
                  style: AppTextStyles.titleSmall.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                AppDimens.vGap8,
                Text(recommandations, style: AppTextStyles.bodyMedium),
              ],
            ),
          ),
        AppDimens.vGap24,
        // Traitements recommandés
        Text(
          'Traitements recommandés',
          style: AppTextStyles.titleSmall.copyWith(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
        AppDimens.vGap12,
        _TraitementsList(analyseId: analyse.id),
        AppDimens.vGap24,
        // Recommencer
        SizedBox(
          height: AppDimens.buttonHeight,
          child: OutlinedButton(
            onPressed: onRecommencer,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: const BorderSide(
                color: AppColors.borderStrong,
                width: AppDimens.borderThin,
              ),
              shape: const RoundedRectangleBorder(
                borderRadius: AppDimens.brButton,
              ),
            ),
            child: Text(
              'Nouvelle analyse',
              style: AppTextStyles.button.copyWith(
                color: AppColors.primary,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _PhotoFallback extends StatelessWidget {
  const _PhotoFallback();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Icon(
        Icons.image_outlined,
        color: AppColors.textSubtle,
        size: 32,
      ),
    );
  }
}

class _TraitementsList extends ConsumerWidget {
  const _TraitementsList({required this.analyseId});

  final String analyseId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final futureProvider =
        FutureProvider.autoDispose<List<Traitement>>((ref) async {
      return ref.watch(aiServiceProvider).getTreatmentsForAnalysis(analyseId);
    });
    final async = ref.watch(futureProvider);
    return async.when(
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: AppDimens.space16),
        child: Chargement(size: 18),
      ),
      error: (_, _) => Padding(
        padding: const EdgeInsets.symmetric(vertical: AppDimens.space8),
        child: VueErreur(
          message: 'Impossible de charger les traitements.',
          onRetry: () => ref.invalidate(futureProvider),
        ),
      ),
      data: (items) {
        if (items.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(AppDimens.space16),
            decoration: BoxDecoration(
              color: AppColors.surfaceSoft,
              borderRadius: AppDimens.brCard,
              border: Border.all(
                color: AppColors.border,
                width: AppDimens.borderThin,
              ),
            ),
            child: Text(
              'Aucun traitement spécifique recommandé.',
              style: AppTextStyles.bodySmall,
            ),
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final t in items) ...[
              _TraitementCard(traitement: t),
              AppDimens.vGap8,
            ],
          ],
        );
      },
    );
  }
}

class _TraitementCard extends StatelessWidget {
  const _TraitementCard({required this.traitement});

  final Traitement traitement;

  @override
  Widget build(BuildContext context) {
    final dosage = traitement.dosage?.trim();
    final mode = traitement.mode?.trim();
    return Container(
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
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
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
              if (traitement.isBio) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: _kPrimarySoft,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    'BIO',
                    style: AppTextStyles.labelSmall.copyWith(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ],
          ),
          if (dosage != null && dosage.isNotEmpty) ...[
            AppDimens.vGap4,
            Text(
              'Dosage : $dosage',
              style: AppTextStyles.bodySmall.copyWith(fontSize: 12),
            ),
          ],
          if (mode != null && mode.isNotEmpty) ...[
            AppDimens.vGap4,
            Text(
              'Mode : $mode',
              style: AppTextStyles.bodySmall.copyWith(fontSize: 12),
            ),
          ],
          if (traitement.description != null &&
              traitement.description!.trim().isNotEmpty) ...[
            AppDimens.vGap8,
            Text(
              traitement.description!.trim(),
              style: AppTextStyles.bodyMedium.copyWith(fontSize: 13),
            ),
          ],
        ],
      ),
    );
  }
}

// ─── Helpers ────────────────────────────────────────────────────────────

String _formatDate(DateTime? d) {
  if (d == null) return '';
  return DateFormat('d MMM yyyy · HH:mm', 'fr_FR').format(d);
}
