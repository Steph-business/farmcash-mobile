import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../models/traitement.dart';
import '../../../../services/providers.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';
import '../../communs/chargement.dart';
import '../../communs/vue_erreur.dart';
import 'traitement_card_analyse.dart';

/// Liste des traitements recommandés pour une analyse donnée. Va chercher
/// `getTreatmentsForAnalysis(analyseId)` côté backend. Affiche un état
/// vide explicite si aucun traitement n'est suggéré.
class TraitementsListAnalyse extends ConsumerWidget {
  const TraitementsListAnalyse({required this.analyseId, super.key});

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
              TraitementCardAnalyse(traitement: t),
              AppDimens.vGap8,
            ],
          ],
        );
      },
    );
  }
}
