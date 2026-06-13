import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../models/ai_content.dart';
import '../../../../services/providers.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';
import '../../../widgets/communs/chargement.dart';
import '../../../widgets/communs/entete_page_standard.dart';
import '../../../widgets/communs/vue_erreur.dart';
import '../../../widgets/producteur/ai/actualites_constants.dart';
import '../../../widgets/producteur/ai/categorie_chip_actualite.dart';
import '../../../widgets/producteur/ai/empty_actualites.dart';
import '../../../widgets/producteur/ai/news_card_actualite.dart';

/// 20 actualités les plus récentes. V1 : pas de pagination infinie.
final _newsListProvider = FutureProvider.autoDispose<List<NewsItem>>((
  ref,
) async {
  final page = await ref.watch(aiServiceProvider).listNews(page: 1, limit: 20);
  return page.data;
});

/// Feed d'actualités IA filtré par le backend selon le rôle utilisateur.
class ActualitesPage extends ConsumerWidget {
  const ActualitesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(_newsListProvider);
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const EntetePageStandard(titre: 'Actualités'),
            Expanded(
              child: async.when(
                loading: () => const Padding(
                  padding: EdgeInsets.only(top: AppDimens.space32),
                  child: Chargement(size: 22),
                ),
                error: (_, _) => Padding(
                  padding: const EdgeInsets.all(AppDimens.pagePaddingH),
                  child: VueErreur(
                    message: 'Impossible de charger les actualités.',
                    onRetry: () => ref.invalidate(_newsListProvider),
                  ),
                ),
                data: (items) {
                  if (items.isEmpty) return const EmptyActualites();
                  return RefreshIndicator(
                    color: AppColors.primary,
                    onRefresh: () async => ref.invalidate(_newsListProvider),
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(
                        AppDimens.pagePaddingH,
                        AppDimens.space16,
                        AppDimens.pagePaddingH,
                        AppDimens.space24,
                      ),
                      itemCount: items.length,
                      separatorBuilder: (_, _) => AppDimens.vGap16,
                      itemBuilder: (_, i) => NewsCardActualite(news: items[i]),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Détail d'une actualité ─────────────────────────────────────────────

class ActualiteDetailPage extends ConsumerWidget {
  const ActualiteDetailPage({required this.id, super.key});

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailProvider = FutureProvider.autoDispose<NewsItem>((ref) async {
      return ref.watch(aiServiceProvider).getNews(id);
    });
    final async = ref.watch(detailProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const EntetePageStandard(titre: 'Actualité'),
            Expanded(
              child: async.when(
                loading: () => const Padding(
                  padding: EdgeInsets.only(top: AppDimens.space32),
                  child: Chargement(size: 22),
                ),
                error: (_, _) => Padding(
                  padding: const EdgeInsets.all(AppDimens.pagePaddingH),
                  child: VueErreur(
                    message: "Impossible de charger l'actualité.",
                    onRetry: () => ref.invalidate(detailProvider),
                  ),
                ),
                data: (news) {
                  final image = news.imageUrl;
                  final categorie = news.targetRoles.isNotEmpty
                      ? libelleRoleActualite(news.targetRoles.first)
                      : null;
                  final body = news.body?.trim() ?? '';
                  return ListView(
                    padding: EdgeInsets.zero,
                    children: [
                      if (image != null && image.isNotEmpty)
                        AspectRatio(
                          aspectRatio: 16 / 9,
                          child: CachedNetworkImage(
                            imageUrl: image,
                            fit: BoxFit.cover,
                            placeholder: (_, _) =>
                                const ColoredBox(color: AppColors.surfaceSoft),
                            errorWidget: (_, _, _) => Container(
                              color: AppColors.surfaceSoft,
                              alignment: Alignment.center,
                              child: const Icon(
                                Icons.image_outlined,
                                color: AppColors.textSubtle,
                              ),
                            ),
                          ),
                        ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(
                          AppDimens.pagePaddingH,
                          AppDimens.space16,
                          AppDimens.pagePaddingH,
                          AppDimens.space32,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (categorie != null) ...[
                              CategorieChipActualite(label: categorie),
                              AppDimens.vGap12,
                            ],
                            Text(
                              news.titre,
                              style: AppTextStyles.headlineMedium.copyWith(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            AppDimens.vGap8,
                            Text(
                              formatDateActualite(
                                news.publishedAt ?? news.createdAt,
                              ),
                              style: AppTextStyles.bodySmall.copyWith(
                                fontSize: 12,
                              ),
                            ),
                            AppDimens.vGap16,
                            if (news.resume != null &&
                                news.resume!.trim().isNotEmpty) ...[
                              Text(
                                news.resume!.trim(),
                                style: AppTextStyles.bodyLarge.copyWith(
                                  fontWeight: FontWeight.w500,
                                  height: 1.5,
                                ),
                              ),
                              AppDimens.vGap16,
                            ],
                            if (body.isNotEmpty)
                              Text(body, style: AppTextStyles.bodyMedium)
                            else
                              Text(
                                'Contenu non disponible.',
                                style: AppTextStyles.bodySmall,
                              ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
