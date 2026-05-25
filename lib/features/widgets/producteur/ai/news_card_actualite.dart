import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../models/ai_content.dart';
import '../../../../routing/route_names.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';
import 'actualites_constants.dart';
import 'categorie_chip_actualite.dart';

/// Carte cliquable d'une actualite dans le feed. Affiche image hero,
/// chip categorie, titre, resume et date. Tap → page de detail.
class NewsCardActualite extends StatelessWidget {
  const NewsCardActualite({required this.news, super.key});

  final NewsItem news;

  @override
  Widget build(BuildContext context) {
    final image = news.imageUrl;
    final resume = news.resume?.trim() ?? '';
    final categorie = news.targetRoles.isNotEmpty
        ? libelleRoleActualite(news.targetRoles.first)
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
                      CategorieChipActualite(label: categorie),
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
                      formatDateActualite(news.publishedAt ?? news.createdAt),
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
