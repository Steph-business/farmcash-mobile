import 'package:flutter/material.dart';

import '../../../../models/ai_content.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';
import 'accueil_constants.dart';
import 'section_head.dart';

/// Section "Conseils du jour" : bandeau vert pâle affichant la première
/// tendance issue des insights IA du farmer (titre + sous-titre court).
/// Masquée si pas d'insight disponible.
class SectionConseils extends StatelessWidget {
  const SectionConseils({super.key, required this.tendance});

  final AiInsightItem tendance;

  @override
  Widget build(BuildContext context) {
    final titre = tendance.titre.isNotEmpty
        ? tendance.titre
        : 'Nouvelle tendance disponible';
    final sub = tendance.body ?? '';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionHead(titre: 'Conseils du jour'),
        Container(
          decoration: BoxDecoration(
            color: kAccueilPrimarySoft,
            borderRadius: kAccueilBrCard,
            border:
                Border.all(color: AppColors.border, width: AppDimens.borderThin),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
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
                    if (sub.isNotEmpty) ...[
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
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
