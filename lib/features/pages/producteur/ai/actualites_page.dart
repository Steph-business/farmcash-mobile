import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../models/ai_content.dart';
import '../../../../routing/route_names.dart';
import '../../../../services/providers.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';
import '../../../widgets/communs/chargement.dart';
import '../../../widgets/communs/vue_erreur.dart';

const Color _kPrimarySoft = Color(0xFFE8F5E9);

/// 20 actualités les plus récentes. V1 : pas de pagination infinie.
final _newsListProvider =
    FutureProvider.autoDispose<List<NewsItem>>((ref) async {
  final page =
      await ref.watch(aiServiceProvider).listNews(page: 1, limit: 20);
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
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: const BackButton(color: AppColors.text),
        title: Text(
          'Actualités',
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
            message: 'Impossible de charger les actualités.',
            onRetry: () => ref.invalidate(_newsListProvider),
          ),
        ),
        data: (items) {
          if (items.isEmpty) return const _EmptyState();
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
              itemBuilder: (_, i) => _NewsCard(news: items[i]),
            ),
          );
        },
      ),
    );
  }
}

class _NewsCard extends StatelessWidget {
  const _NewsCard({required this.news});

  final NewsItem news;

  @override
  Widget build(BuildContext context) {
    final image = news.imageUrl;
    final resume = news.resume?.trim() ?? '';
    final categorie = news.targetRoles.isNotEmpty
        ? _libelleRole(news.targetRoles.first)
        : null;
    return Material(
      color: AppColors.surface,
      borderRadius: AppDimens.brCard,
      child: InkWell(
        onTap: () => context.push(
          RouteNames.producteurAiActualiteDetailPathFor(news.id),
        ),
        borderRadius: AppDimens.brCard,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: AppDimens.brCard,
            border: Border.all(
              color: AppColors.border,
              width: AppDimens.borderThin,
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
                padding: const EdgeInsets.all(AppDimens.space16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (categorie != null) ...[
                      _CategorieChip(label: categorie),
                      AppDimens.vGap8,
                    ],
                    Text(
                      news.titre,
                      style: AppTextStyles.titleSmall.copyWith(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (resume.isNotEmpty) ...[
                      AppDimens.vGap4,
                      Text(
                        resume,
                        style: AppTextStyles.bodySmall.copyWith(fontSize: 13),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    AppDimens.vGap8,
                    Text(
                      _formatDate(news.publishedAt ?? news.createdAt),
                      style: AppTextStyles.labelSmall.copyWith(fontSize: 11),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategorieChip extends StatelessWidget {
  const _CategorieChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: _kPrimarySoft,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: AppTextStyles.labelSmall.copyWith(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: AppColors.primary,
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimens.space24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.newspaper_outlined,
              size: 40,
              color: AppColors.textSubtle.withValues(alpha: 0.9),
            ),
            const SizedBox(height: AppDimens.space12),
            Text(
              "Aucune actualité pour l'instant",
              style: AppTextStyles.titleSmall,
            ),
            AppDimens.vGap4,
            Text(
              'Les nouvelles seront publiées ici dès que disponibles.',
              style: AppTextStyles.bodySmall,
              textAlign: TextAlign.center,
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
    final detailProvider =
        FutureProvider.autoDispose<NewsItem>((ref) async {
      return ref.watch(aiServiceProvider).getNews(id);
    });
    final async = ref.watch(detailProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: const BackButton(color: AppColors.text),
        title: Text(
          'Actualité',
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
            message: "Impossible de charger l'actualité.",
            onRetry: () => ref.invalidate(detailProvider),
          ),
        ),
        data: (news) {
          final image = news.imageUrl;
          final categorie = news.targetRoles.isNotEmpty
              ? _libelleRole(news.targetRoles.first)
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
                      _CategorieChip(label: categorie),
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
                      _formatDate(news.publishedAt ?? news.createdAt),
                      style: AppTextStyles.bodySmall.copyWith(fontSize: 12),
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
    );
  }
}

// ─── Helpers ────────────────────────────────────────────────────────────

String _libelleRole(String role) {
  switch (role.toUpperCase()) {
    case 'FARMER':
      return 'Producteur';
    case 'BUYER':
      return 'Acheteur';
    case 'COOPERATIVE':
      return 'Coopérative';
    case 'TRANSPORTER':
      return 'Transporteur';
    case 'ADMIN':
      return 'Admin';
    default:
      return role;
  }
}

String _formatDate(DateTime? d) {
  if (d == null) return '';
  return DateFormat('d MMMM yyyy', 'fr_FR').format(d);
}
