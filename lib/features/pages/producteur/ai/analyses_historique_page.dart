import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../models/analyse_plante.dart';
import '../../../../services/providers.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';
import '../../../widgets/communs/chargement.dart';
import '../../../widgets/communs/vue_erreur.dart';
import '../../../widgets/producteur/ai/analyse_historique_card.dart';
import '../../../widgets/producteur/ai/empty_analyses_historique.dart';

/// Toutes les analyses paginées (page 1, limit 50 — V1 sans pagination
/// infinie : on charge un buffer large et c'est suffisant pour l'historique
/// d'un farmer).
final _analysesHistoriqueProvider =
    FutureProvider.autoDispose<List<AnalysePlante>>((ref) async {
  final page = await ref
      .watch(aiServiceProvider)
      .listPlantAnalyses(page: 1, limit: 50);
  return page.data;
});

/// Liste paginée des analyses de plante passées du farmer.
class AnalysesHistoriquePage extends ConsumerWidget {
  const AnalysesHistoriquePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(_analysesHistoriqueProvider);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: const BackButton(color: AppColors.text),
        title: Text(
          'Historique des analyses',
          style: AppTextStyles.titleSmall.copyWith(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: false,
      ),
      body: async.when(
        loading: () => const Padding(
          padding: EdgeInsets.only(top: AppDimens.space32),
          child: Chargement(size: 22),
        ),
        error: (_, _) => Padding(
          padding: const EdgeInsets.all(AppDimens.pagePaddingH),
          child: VueErreur(
            message: 'Impossible de charger les analyses.',
            onRetry: () => ref.invalidate(_analysesHistoriqueProvider),
          ),
        ),
        data: (items) {
          if (items.isEmpty) return const EmptyAnalysesHistorique();
          return RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () async => ref.invalidate(_analysesHistoriqueProvider),
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(
                AppDimens.pagePaddingH,
                AppDimens.space16,
                AppDimens.pagePaddingH,
                AppDimens.space24,
              ),
              itemCount: items.length,
              separatorBuilder: (_, _) => AppDimens.vGap12,
              itemBuilder: (_, i) => AnalyseHistoriqueCard(analyse: items[i]),
            ),
          );
        },
      ),
    );
  }
}
