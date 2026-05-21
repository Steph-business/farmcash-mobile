import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../models/sollicitation.dart';
import '../../../../routing/route_names.dart';
import '../../../../services/providers.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';
import '../../../widgets/communs/chargement.dart';
import '../../../widgets/communs/vue_erreur.dart';

// ─── Couleurs accent (warn-soft pour chip urgent) ────────────────────────

const Color _kWarnSoft = Color(0xFFFFF8E1);
const Color _kWarn = Color(0xFFB26A00);

const String _kFallbackThumb =
    'https://images.unsplash.com/photo-1601493700631-2b16ec4b4716?w=200&h=200&fit=crop&auto=format';

/// Récupère la liste des sollicitations actives ciblant le producteur courant
/// via `CooperativesService.listSollicitations`.
final _sollicitationsProvider =
    FutureProvider.autoDispose<List<Sollicitation>>((ref) async {
  final paginated = await ref
      .watch(cooperativesServiceProvider)
      .listSollicitations(status: 'OPEN', limit: 50);
  return paginated.data;
});

/// Liste des sollicitations reçues par le producteur de sa coopérative.
class SollicitationsRecuesPage extends ConsumerWidget {
  const SollicitationsRecuesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(_sollicitationsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            async.when(
              data: (list) => _Header(count: list.length),
              loading: () => const _Header(count: 0),
              error: (_, _) => const _Header(count: 0),
            ),
            Expanded(
              child: async.when(
                loading: () => const Padding(
                  padding: EdgeInsets.only(top: AppDimens.space32),
                  child: Chargement(size: 22),
                ),
                error: (_, _) => Padding(
                  padding: const EdgeInsets.all(AppDimens.pagePaddingH),
                  child: VueErreur(
                    message:
                        'Impossible de charger les sollicitations de ta coop.',
                    onRetry: () => ref.invalidate(_sollicitationsProvider),
                  ),
                ),
                data: (items) => RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: () async =>
                      ref.invalidate(_sollicitationsProvider),
                  child: items.isEmpty
                      ? ListView(
                          padding: const EdgeInsets.symmetric(vertical: 48),
                          children: [
                            Center(
                              child: Text(
                                'Aucune sollicitation active pour l\'instant.',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        )
                      : _Body(items: items),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Header ──────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  const _Header({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppDimens.pagePaddingH,
        AppDimens.space8,
        AppDimens.pagePaddingH,
        AppDimens.space12,
      ),
      child: Row(
        children: [
          InkWell(
            onTap: () => Navigator.of(context).pop(),
            borderRadius: BorderRadius.circular(20),
            child: const SizedBox(
              width: 40,
              height: 40,
              child: Icon(
                Icons.arrow_back_ios_new,
                size: 20,
                color: AppColors.text,
              ),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Sollicitations de ma coop ($count)',
                  style: AppTextStyles.titleSmall.copyWith(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Réponds pour participer',
                  style: AppTextStyles.bodySmall.copyWith(
                    fontSize: 12,
                    color: AppColors.textSecondary,
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

// ─── Body ────────────────────────────────────────────────────────────────

class _Body extends StatelessWidget {
  const _Body({required this.items});

  final List<Sollicitation> items;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(
        AppDimens.pagePaddingH,
        AppDimens.space8,
        AppDimens.pagePaddingH,
        AppDimens.space16,
      ),
      itemCount: items.length,
      itemBuilder: (_, i) => Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: _SolCard(sol: items[i]),
      ),
    );
  }
}

// ─── Carte sollicitation ─────────────────────────────────────────────────

class _SolCard extends StatelessWidget {
  const _SolCard({required this.sol});

  final Sollicitation sol;

  @override
  Widget build(BuildContext context) {
    final quantite = sol.quantiteCibleKg ?? 0;
    final offerte = sol.totalQuantiteOfferte;
    final dejaRepondu = sol.totalResponses;
    final total = sol.totalRecipients;

    final besoin = sol.message?.isNotEmpty == true
        ? sol.message!
        : 'Besoin de ${quantite.toStringAsFixed(0)} kg';

    final timing = _formatTiming(sol.createdAt);

    final urgent = _isUrgent(sol.expiresAt);

    final progression =
        '$dejaRepondu / $total farmers ont répondu '
        '(${offerte.toStringAsFixed(0)} kg engagés sur '
        '${quantite.toStringAsFixed(0)} kg)';

    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.border,
          width: AppDimens.borderThin,
        ),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header card (avatar + nom coop + chip urgent)
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.groups_outlined,
                  size: 18,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Ma coopérative',
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      timing,
                      style: AppTextStyles.bodySmall.copyWith(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (urgent) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _kWarnSoft,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    'Urgent',
                    style: AppTextStyles.labelSmall.copyWith(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: _kWarn,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),

          // Besoin + vignette produit
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  besoin,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    height: 1.4,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceSoft,
                    border: Border.all(
                      color: AppColors.border,
                      width: AppDimens.borderThin,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  clipBehavior: Clip.hardEdge,
                  child: CachedNetworkImage(
                    imageUrl: _kFallbackThumb,
                    fit: BoxFit.cover,
                    placeholder: (_, _) =>
                        Container(color: AppColors.surfaceSoft),
                    errorWidget: (_, _, _) =>
                        Container(color: AppColors.surfaceSoft),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Progression
          Text(
            progression,
            style: AppTextStyles.bodySmall.copyWith(
              fontSize: 12,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 14),

          Align(
            alignment: Alignment.centerRight,
            child: InkWell(
              onTap: () => context.push(
                RouteNames.producteurSollicitationRepondrePathFor(sol.id),
              ),
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: AppColors.primary,
                    width: AppDimens.borderThin,
                  ),
                ),
                child: Text(
                  'Je peux fournir',
                  style: AppTextStyles.button.copyWith(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTiming(DateTime? createdAt) {
    if (createdAt == null) return 'Sollicitation reçue';
    final now = DateTime.now();
    final diff = now.difference(createdAt);
    if (diff.inMinutes < 60) return 'Reçue il y a ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'Reçue il y a ${diff.inHours} h';
    if (diff.inDays == 1) return 'Reçue hier';
    if (diff.inDays < 7) return 'Reçue il y a ${diff.inDays} j';
    return 'Reçue le ${DateFormat('d MMM', 'fr_FR').format(createdAt)}';
  }

  bool _isUrgent(DateTime? expiresAt) {
    if (expiresAt == null) return false;
    final remaining = expiresAt.difference(DateTime.now());
    return remaining.inHours <= 48 && remaining.inSeconds > 0;
  }
}
