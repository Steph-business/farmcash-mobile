// =====================================================================
//  ScannerDocumentPage<T> — page générique de scan de document
//  ---------------------------------------------------------------------
//  Page paramétrable pour scanner un document (CNI, RCCM, …) et afficher
//  un preview du résultat. Le typage générique [T] permet d'utiliser la
//  même page pour différents types d'extraction (IdentityCardExtraction,
//  RccmExtraction, etc.).
//
//  Anatomie :
//   - Header simple avec back
//   - Hero scanner (cadre + icône scan)
//   - Sous-titre explicatif
//   - Bouton primary « Prendre une photo » (camera)
//   - Bouton text secondaire « Choisir depuis la galerie »
//   - Pendant upload : overlay plein écran + texte « Lecture en cours… »
//   - Après extraction : affichage du preview via [buildPreview]
//
//  Le caller est responsable de :
//   - exécuter l'appel API via [onScanned]
//   - rendre le preview (souvent un bottom sheet via [buildPreview]) qui
//     gère lui-même les CTA d'acceptation / saisie manuelle.
// =====================================================================

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../api_client/api_exception.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_dimens.dart';
import '../../../theme/app_text_styles.dart';
import 'snackbars.dart';

/// Page de scan générique avec preview du résultat extrait.
///
/// Usage type :
/// ```dart
/// Navigator.push(context, MaterialPageRoute(
///   builder: (_) => ScannerDocumentPage<RccmExtraction>(
///     title: 'Scanner mon RCCM',
///     subtitle: 'Place le document dans le cadre, bien à plat.',
///     onScanned: (file) => ocr.extractRccm(file),
///     buildPreview: (ctx, extraction) => SheetPreviewOcrRccm(
///       extraction: extraction,
///       onAccept: (e) { ... },
///     ),
///   ),
/// ));
/// ```
class ScannerDocumentPage<T> extends StatefulWidget {
  const ScannerDocumentPage({
    super.key,
    required this.title,
    required this.subtitle,
    required this.onScanned,
    required this.buildPreview,
    this.helpLine,
    this.heroIcon = Icons.document_scanner_outlined,
  });

  /// Titre de la page (ex. « Scanner mon RCCM »).
  final String title;

  /// Sous-titre court (ex. « Place le document dans le cadre »).
  final String subtitle;

  /// Ligne d'aide optionnelle affichée sous les CTA (ex. « JPEG ou PNG,
  /// jusqu'à 10 Mo. »).
  final String? helpLine;

  /// Icône hero du cadre (par défaut document_scanner).
  final IconData heroIcon;

  /// Callback qui upload la photo et renvoie l'extraction typée [T].
  final Future<T> Function(File photo) onScanned;

  /// Builder du preview affiché APRÈS extraction. Retourne le widget
  /// (typiquement un bottom sheet) qui présente les champs et les CTA
  /// « Utiliser ces infos » / « Saisie manuelle ». Le widget doit appeler
  /// `Navigator.of(ctx).pop(true)` pour signaler l'acceptation et
  /// `Navigator.of(ctx).pop(false)` (ou null) pour annuler. La page
  /// scanner se chargera elle-même de pop avec l'extraction.
  final Widget Function(BuildContext context, T extraction) buildPreview;

  @override
  State<ScannerDocumentPage<T>> createState() => _ScannerDocumentPageState<T>();
}

class _ScannerDocumentPageState<T> extends State<ScannerDocumentPage<T>> {
  final ImagePicker _picker = ImagePicker();
  bool _busy = false;

  Future<void> _pickAndScan(ImageSource source) async {
    if (_busy) return;
    try {
      final picked = await _picker.pickImage(
        source: source,
        imageQuality: 85,
        // Cap la résolution pour limiter la taille (10 MB max backend).
        maxWidth: 2400,
        maxHeight: 2400,
      );
      if (picked == null) return;
      if (!mounted) return;
      setState(() => _busy = true);
      final extraction = await widget.onScanned(File(picked.path));
      if (!mounted) return;
      setState(() => _busy = false);
      await _showPreview(extraction);
    } on ApiException catch (e) {
      if (mounted) {
        setState(() => _busy = false);
        Snackbars.showErreur(context, e.message);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _busy = false);
        Snackbars.showErreurInattendue(context, e);
      }
    }
  }

  Future<void> _showPreview(T extraction) async {
    final accepted = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => widget.buildPreview(ctx, extraction),
    );
    if (!mounted) return;
    // L'user a validé → on remonte l'extraction au wizard appelant.
    if (accepted == true) {
      Navigator.of(context).pop(extraction);
    }
    // Sinon (annulé / dismiss) → l'user reste sur la page scanner et
    // peut retenter ou revenir au wizard manuellement via le back.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            Column(
              children: [
                _Header(title: widget.title),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _ScannerFrame(icon: widget.heroIcon),
                        const SizedBox(height: 24),
                        Text(
                          widget.subtitle,
                          textAlign: TextAlign.center,
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontSize: 14.5,
                            color: AppColors.textSecondary,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 18),
                        _ConseilsRapides(),
                      ],
                    ),
                  ),
                ),
                _StickyFooter(
                  busy: _busy,
                  onCamera: () => _pickAndScan(ImageSource.camera),
                  onGallery: () => _pickAndScan(ImageSource.gallery),
                  helpLine: widget.helpLine,
                ),
              ],
            ),
            if (_busy) const _OverlayLecture(),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(6, 6, 12, 6),
      child: Row(
        children: [
          InkWell(
            onTap: () => Navigator.of(context).maybePop(),
            borderRadius: BorderRadius.circular(20),
            child: const Padding(
              padding: EdgeInsets.all(8),
              child: Icon(
                Icons.arrow_back,
                size: AppDimens.iconL,
                color: AppColors.text,
              ),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              title,
              style: AppTextStyles.titleMedium.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.text,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

/// Cadre stylisé — preview visuel du « scanner » avant capture.
class _ScannerFrame extends StatelessWidget {
  const _ScannerFrame({required this.icon});
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.55,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceSoft,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.18),
            width: 1.2,
          ),
        ),
        child: Stack(
          children: [
            // Coins style "framing"
            const Positioned(top: 10, left: 10, child: _Coin(tl: true)),
            const Positioned(top: 10, right: 10, child: _Coin(tr: true)),
            const Positioned(bottom: 10, left: 10, child: _Coin(bl: true)),
            const Positioned(bottom: 10, right: 10, child: _Coin(br: true)),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.10),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Icon(icon, size: 30, color: AppColors.primary),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Cadre suggéré',
                    style: AppTextStyles.labelSmall.copyWith(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                      letterSpacing: 0.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Coin extends StatelessWidget {
  const _Coin({
    this.tl = false,
    this.tr = false,
    this.bl = false,
    this.br = false,
  });
  final bool tl, tr, bl, br;

  @override
  Widget build(BuildContext context) {
    const Color color = AppColors.primary;
    const double thickness = 2.2;
    const double length = 20;
    final BorderSide side = BorderSide(color: color, width: thickness);
    return SizedBox(
      width: length,
      height: length,
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(
            top: tl || tr ? side : BorderSide.none,
            left: tl || bl ? side : BorderSide.none,
            right: tr || br ? side : BorderSide.none,
            bottom: bl || br ? side : BorderSide.none,
          ),
        ),
      ),
    );
  }
}

class _ConseilsRapides extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final tips = const [
      'Bonne lumière, pas de reflet sur le document.',
      'Cadrage serré : tout le document doit être visible.',
      'Document à plat, ni plié, ni froissé.',
    ];
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.tips_and_updates_outlined,
                size: 16,
                color: AppColors.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'Pour une lecture optimale',
                style: AppTextStyles.labelSmall.copyWith(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          for (final t in tips)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 5),
                    child: Icon(
                      Icons.check_rounded,
                      size: 12,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      t,
                      style: AppTextStyles.bodySmall.copyWith(
                        fontSize: 12.5,
                        color: AppColors.text,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _StickyFooter extends StatelessWidget {
  const _StickyFooter({
    required this.busy,
    required this.onCamera,
    required this.onGallery,
    this.helpLine,
  });

  final bool busy;
  final VoidCallback onCamera;
  final VoidCallback onGallery;
  final String? helpLine;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: AppDimens.buttonHeight,
                width: double.infinity,
                child: Material(
                  color: busy
                      ? AppColors.primary.withValues(alpha: 0.4)
                      : AppColors.primary,
                  borderRadius: AppDimens.brButton,
                  child: InkWell(
                    borderRadius: AppDimens.brButton,
                    onTap: busy ? null : onCamera,
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.photo_camera_rounded,
                            size: 18,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'Prendre une photo',
                            style: AppTextStyles.button.copyWith(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 42,
                width: double.infinity,
                child: TextButton.icon(
                  onPressed: busy ? null : onGallery,
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    padding: EdgeInsets.zero,
                  ),
                  icon: const Icon(
                    Icons.photo_library_outlined,
                    size: 17,
                  ),
                  label: Text(
                    'Choisir depuis la galerie',
                    style: AppTextStyles.button.copyWith(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
              if (helpLine != null) ...[
                const SizedBox(height: 4),
                Text(
                  helpLine!,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.labelSmall.copyWith(
                    fontSize: 11,
                    color: AppColors.textSubtle,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Overlay pleine page pendant l'upload + extraction.
class _OverlayLecture extends StatelessWidget {
  const _OverlayLecture();

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: ColoredBox(
        color: Colors.black.withValues(alpha: 0.55),
        child: Center(
          child: Container(
            padding: const EdgeInsets.fromLTRB(22, 22, 22, 20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(
                  width: 36,
                  height: 36,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'Lecture en cours…',
                  style: AppTextStyles.titleSmall.copyWith(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.text,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "L'IA analyse ton document.",
                  style: AppTextStyles.bodySmall.copyWith(
                    fontSize: 12.5,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
