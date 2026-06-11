// =====================================================================
//  SheetPreviewOcr — bottom sheet preview résultat OCR
//  ---------------------------------------------------------------------
//  Présente les champs extraits par l'IA (CNI, RCCM, …) sous forme d'une
//  fiche compacte. L'user peut :
//    - accepter et utiliser les infos (callback `onAccept`)
//    - choisir la saisie manuelle à la place (Cancel)
//
//  Affiche des badges contextuels :
//    - icône succès si confidence > 0.7
//    - alerte ambrée « Mode simulation » si isMock = true
//    - alerte rouge « Lecture incertaine » si confidence < 0.5
//
//  Le sheet est indépendant du type de document → on lui passe une liste
//  de [OcrPreviewField] (label + value). L'appelant choisit quels champs
//  surfacer dans l'ordre voulu.
// =====================================================================

import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_dimens.dart';
import '../../../theme/app_text_styles.dart';

/// Un champ extrait à présenter dans le preview.
///
/// `value` peut être null → on affiche « — non trouvé » et le champ est
/// marqué comme non auto-rempli (pas de chip vert).
class OcrPreviewField {
  const OcrPreviewField({
    required this.label,
    required this.value,
    this.icon,
  });

  final String label;
  final String? value;
  final IconData? icon;

  bool get isFilled => value != null && value!.trim().isNotEmpty;
}

/// Bottom sheet preview pour résultat OCR.
///
/// Utilisation typique depuis ScannerDocumentPage.buildPreview :
/// ```dart
/// SheetPreviewOcr(
///   title: 'Infos extraites du RCCM',
///   fields: [
///     OcrPreviewField(label: 'Nom de l'entreprise', value: extraction.companyName),
///     OcrPreviewField(label: 'Numéro RCCM', value: extraction.rccmNumber),
///   ],
///   confidence: extraction.confidence,
///   isMock: extraction.isMock,
///   onAccept: () { /* close + apply */ },
/// )
/// ```
class SheetPreviewOcr extends StatelessWidget {
  const SheetPreviewOcr({
    super.key,
    required this.title,
    required this.fields,
    required this.confidence,
    required this.isMock,
    required this.onAccept,
    this.acceptLabel = 'Utiliser ces infos',
    this.cancelLabel = 'Saisie manuelle à la place',
  });

  final String title;
  final List<OcrPreviewField> fields;
  final double confidence;
  final bool isMock;
  final VoidCallback onAccept;
  final String acceptLabel;
  final String cancelLabel;

  bool get _highConfidence => confidence >= 0.7;
  bool get _lowConfidence => confidence < 0.5;
  bool get _anyFilled => fields.any((f) => f.isFilled);

  /// Helper pour ouvrir le sheet depuis un scanner page.
  /// Renvoie `true` quand l'user a accepté les infos.
  static Future<bool?> show(
    BuildContext context, {
    required String title,
    required List<OcrPreviewField> fields,
    required double confidence,
    required bool isMock,
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => SheetPreviewOcr(
        title: title,
        fields: fields,
        confidence: confidence,
        isMock: isMock,
        onAccept: () => Navigator.of(ctx).pop(true),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    return SafeArea(
      top: false,
      child: Container(
        margin: EdgeInsets.only(bottom: media.viewInsets.bottom),
        decoration: const BoxDecoration(
          color: AppColors.background,
          borderRadius: AppDimens.brBottomSheet,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Container(
              width: 38,
              height: 4,
              margin: const EdgeInsets.only(top: 10, bottom: 6),
              decoration: BoxDecoration(
                color: AppColors.borderStrong,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _HeaderTitre(
                      title: title,
                      highConfidence: _highConfidence,
                      anyFilled: _anyFilled,
                    ),
                    if (isMock) ...[
                      const SizedBox(height: 12),
                      const _BadgeSimulation(),
                    ],
                    if (_lowConfidence && !isMock && _anyFilled) ...[
                      const SizedBox(height: 12),
                      const _AlerteIncertaine(),
                    ],
                    if (!_anyFilled) ...[
                      const SizedBox(height: 14),
                      const _EtatAucunChamp(),
                    ] else ...[
                      const SizedBox(height: 16),
                      for (int i = 0; i < fields.length; i++) ...[
                        _LigneChamp(field: fields[i]),
                        if (i < fields.length - 1)
                          const Divider(
                            height: 16,
                            thickness: 1,
                            color: AppColors.border,
                          ),
                      ],
                    ],
                  ],
                ),
              ),
            ),
            _Footer(
              onAccept: _anyFilled ? onAccept : null,
              acceptLabel: acceptLabel,
              cancelLabel: cancelLabel,
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderTitre extends StatelessWidget {
  const _HeaderTitre({
    required this.title,
    required this.highConfidence,
    required this.anyFilled,
  });
  final String title;
  final bool highConfidence;
  final bool anyFilled;

  @override
  Widget build(BuildContext context) {
    final showSuccess = highConfidence && anyFilled;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: showSuccess
                ? AppColors.success.withValues(alpha: 0.14)
                : AppColors.primary.withValues(alpha: 0.10),
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Icon(
            showSuccess ? Icons.check_circle_rounded : Icons.auto_awesome_rounded,
            size: 20,
            color: showSuccess ? AppColors.success : AppColors.primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: AppTextStyles.titleLarge.copyWith(
              fontFamily: 'Poppins',
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: AppColors.text,
              height: 1.3,
            ),
          ),
        ),
      ],
    );
  }
}

class _BadgeSimulation extends StatelessWidget {
  const _BadgeSimulation();

  @override
  Widget build(BuildContext context) {
    const Color amber = Color(0xFFB45309);
    const Color amberSoft = Color(0xFFFEF3C7);
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        color: amberSoft,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: amber.withValues(alpha: 0.35)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.science_outlined,
            size: 17,
            color: amber,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Mode simulation',
                  style: AppTextStyles.labelSmall.copyWith(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: amber,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  "L'IA n'a pas vraiment lu ton document : ces valeurs sont des "
                  'exemples. Vérifie chaque champ avant de continuer.',
                  style: AppTextStyles.bodySmall.copyWith(
                    fontSize: 12.5,
                    color: AppColors.text,
                    height: 1.4,
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

class _AlerteIncertaine extends StatelessWidget {
  const _AlerteIncertaine();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFEE2E2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFCA5A5)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            size: 17,
            color: Color(0xFF991B1B),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Lecture incertaine — vérifie bien chaque champ. Tu pourras '
              'corriger ensuite sur le formulaire.',
              style: AppTextStyles.bodySmall.copyWith(
                fontSize: 12.5,
                color: const Color(0xFF991B1B),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EtatAucunChamp extends StatelessWidget {
  const _EtatAucunChamp();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 16, 14, 16),
      decoration: BoxDecoration(
        color: AppColors.surfaceSoft,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.sentiment_dissatisfied_rounded,
            size: 28,
            color: AppColors.textSubtle,
          ),
          const SizedBox(height: 8),
          Text(
            "Aucun champ détecté sur la photo.",
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "Essaie avec une photo plus nette, ou continue en saisie manuelle.",
            textAlign: TextAlign.center,
            style: AppTextStyles.bodySmall.copyWith(
              fontSize: 12.5,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _LigneChamp extends StatelessWidget {
  const _LigneChamp({required this.field});
  final OcrPreviewField field;

  @override
  Widget build(BuildContext context) {
    final filled = field.isFilled;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          margin: const EdgeInsets.only(top: 2),
          decoration: BoxDecoration(
            color: filled
                ? AppColors.primary.withValues(alpha: 0.10)
                : AppColors.surfaceSoft,
            borderRadius: BorderRadius.circular(9),
          ),
          alignment: Alignment.center,
          child: Icon(
            field.icon ?? Icons.label_outline_rounded,
            size: 16,
            color: filled ? AppColors.primary : AppColors.textSubtle,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      field.label,
                      style: AppTextStyles.labelMedium.copyWith(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                        letterSpacing: 0.1,
                      ),
                    ),
                  ),
                  if (filled) const _ChipAutoRempli(),
                ],
              ),
              const SizedBox(height: 3),
              Text(
                filled ? field.value!.trim() : 'Non trouvé',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontSize: 14.5,
                  fontWeight: filled ? FontWeight.w700 : FontWeight.w500,
                  color: filled ? AppColors.text : AppColors.textSubtle,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ChipAutoRempli extends StatelessWidget {
  const _ChipAutoRempli();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.auto_awesome_rounded,
            size: 10,
            color: AppColors.primary,
          ),
          const SizedBox(width: 3),
          Text(
            'auto-rempli',
            style: AppTextStyles.labelSmall.copyWith(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: AppColors.primary,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer({
    required this.onAccept,
    required this.acceptLabel,
    required this.cancelLabel,
  });

  final VoidCallback? onAccept;
  final String acceptLabel;
  final String cancelLabel;

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
                  color: onAccept == null
                      ? AppColors.primary.withValues(alpha: 0.35)
                      : AppColors.primary,
                  borderRadius: AppDimens.brButton,
                  child: InkWell(
                    borderRadius: AppDimens.brButton,
                    onTap: onAccept,
                    child: Center(
                      child: Text(
                        acceptLabel,
                        style: AppTextStyles.button.copyWith(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              SizedBox(
                height: 42,
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.of(context).maybePop(false),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.textSecondary,
                    padding: EdgeInsets.zero,
                  ),
                  child: Text(
                    cancelLabel,
                    style: AppTextStyles.button.copyWith(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
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
