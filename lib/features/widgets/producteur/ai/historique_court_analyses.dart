import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../models/analyse_plante.dart';
import '../../../../routing/route_names.dart';
import '../../../../services/providers.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';
import '../../communs/chargement.dart';
import '../../communs/vue_erreur.dart';
import 'analyse_list_tile.dart';

/// 5 dernières analyses récentes (historique court inline sur la page
/// diagnostic). Exporté ici pour que la page parent puisse l'invalider
/// après chaque nouvelle analyse réussie.
final recentAnalysesAiProvider =
    FutureProvider.autoDispose<List<AnalysePlante>>((ref) async {
  final page =
      await ref.watch(aiServiceProvider).listPlantAnalyses(page: 1, limit: 5);
  return page.data;
});

/// Bloc inline "Analyses précédentes" (5 dernières) avec lien "Voir tout"
/// vers la page historique complète. Affiche un loader/erreur, et un
/// `SizedBox.shrink` si la liste est vide.
class HistoriqueCourtAnalyses extends ConsumerWidget {
  const HistoriqueCourtAnalyses({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(recentAnalysesAiProvider);
    return async.when(
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: AppDimens.space16),
        child: Chargement(size: 18),
      ),
      error: (_, _) => Padding(
        padding: const EdgeInsets.symmetric(vertical: AppDimens.space16),
        child: VueErreur(
          message: "Impossible de charger l'historique.",
          onRetry: () => ref.invalidate(recentAnalysesAiProvider),
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
                  return AnalyseListTile(
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
