import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../models/analyse_plante.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';
import 'traitements_list_analyse.dart';

/// Phase 2 du flow diagnostic : affiche la photo (prise par l'utilisateur
/// ou retournée par le backend), la maladie détectée + confiance, les
/// recommandations textuelles puis la liste des traitements suggérés. Le
/// bouton "Nouvelle analyse" permet de revenir au formulaire vide.
class ResultatViewAnalyse extends ConsumerWidget {
  const ResultatViewAnalyse({
    required this.analyse,
    required this.photo,
    required this.onRecommencer,
    super.key,
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
                      errorBuilder: (_, _, _) => const _PhotoFallbackResultat(),
                    )
                  : const _PhotoFallbackResultat()),
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
        TraitementsListAnalyse(analyseId: analyse.id),
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

/// Icône de fallback affichée si la photo est introuvable ou échoue à se
/// charger dans la phase résultat.
class _PhotoFallbackResultat extends StatelessWidget {
  const _PhotoFallbackResultat();

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
