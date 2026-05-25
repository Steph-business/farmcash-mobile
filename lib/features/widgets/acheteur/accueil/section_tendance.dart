import 'package:flutter/material.dart';

import '../../../../models/ai_content.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';
import 'accueil_acheteur_constants.dart';
import 'section_accueil_acheteur.dart';

/// Bandeau "Tendances du marché" — affiche l'insight IA principal s'il
/// est disponible, sinon un fallback statique. Fond vert pâle, icône
/// `trending_up` à gauche.
class SectionTendance extends StatelessWidget {
  const SectionTendance({super.key, required this.tendance});

  final AiInsightItem? tendance;

  @override
  Widget build(BuildContext context) {
    // Fallback statique si pas d'insights backend.
    final titre = (tendance != null && tendance!.titre.isNotEmpty)
        ? tendance!.titre
        : 'Prix du Maïs en hausse';
    final sub = (tendance?.body != null && tendance!.body!.isNotEmpty)
        ? tendance!.body!
        : '+ 8 % cette semaine · achète maintenant';

    return SectionAccueilAcheteur(
      titre: 'Tendances du marché',
      child: Container(
        decoration: BoxDecoration(
          color: kAccueilPrimarySoft,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: AppColors.border,
            width: AppDimens.borderThin,
          ),
        ),
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: AppColors.surface,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.trending_up,
                size: 22,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    titre,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    sub,
                    style: AppTextStyles.bodySmall.copyWith(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
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
