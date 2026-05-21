import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../models/analyse_plante.dart';
import '../../../../services/providers.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';
import '../../../widgets/communs/chargement.dart';
import '../../../widgets/communs/vue_erreur.dart';

const Color _kPrimarySoft = Color(0xFFE8F5E9);
const Color _kWarnSoft = Color(0xFFFFF8E1);
const Color _kWarn = Color(0xFFB26A00);
const Color _kRedSoft = Color(0xFFFDECEA);

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
          if (items.isEmpty) return const _EmptyState();
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
              itemBuilder: (_, i) => _AnalyseCard(analyse: items[i]),
            ),
          );
        },
      ),
    );
  }
}

class _AnalyseCard extends StatelessWidget {
  const _AnalyseCard({required this.analyse});

  final AnalysePlante analyse;

  @override
  Widget build(BuildContext context) {
    final maladie = analyse.diseaseDetected?.trim();
    final titre = (maladie != null && maladie.isNotEmpty)
        ? maladie
        : 'Diagnostic en cours';
    final risk = analyse.riskLevel?.toLowerCase();
    return InkWell(
      onTap: () => showDialog<void>(
        context: context,
        builder: (_) => _AnalyseDetailDialog(analyse: analyse),
      ),
      borderRadius: AppDimens.brCard,
      child: Container(
        padding: const EdgeInsets.all(AppDimens.space12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppDimens.brCard,
          border: Border.all(
            color: AppColors.border,
            width: AppDimens.borderThin,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.surfaceSoft,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: AppColors.border,
                  width: AppDimens.borderThin,
                ),
              ),
              clipBehavior: Clip.antiAlias,
              child: analyse.imageUrl.isNotEmpty
                  ? Image.network(
                      analyse.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => const Icon(
                        Icons.image_outlined,
                        color: AppColors.textSubtle,
                        size: 24,
                      ),
                    )
                  : const Icon(
                      Icons.eco_outlined,
                      color: AppColors.textSubtle,
                      size: 24,
                    ),
            ),
            const SizedBox(width: 12),
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
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatDate(analyse.createdAt),
                    style: AppTextStyles.bodySmall.copyWith(fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            if (risk != null && risk.isNotEmpty) _ChipRisque(risk: risk),
            const SizedBox(width: 4),
            const Icon(
              Icons.chevron_right,
              color: AppColors.textSubtle,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

class _ChipRisque extends StatelessWidget {
  const _ChipRisque({required this.risk});

  final String risk;

  @override
  Widget build(BuildContext context) {
    final (label, bg, fg) = switch (risk) {
      'high' || 'eleve' || 'haut' => ('Élevé', _kRedSoft, AppColors.error),
      'medium' || 'moyen' => ('Moyen', _kWarnSoft, _kWarn),
      'low' || 'faible' => ('Faible', _kPrimarySoft, AppColors.primary),
      _ => (risk, AppColors.surfaceSoft, AppColors.textSecondary),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: AppTextStyles.labelSmall.copyWith(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: fg,
        ),
      ),
    );
  }
}

class _AnalyseDetailDialog extends StatelessWidget {
  const _AnalyseDetailDialog({required this.analyse});

  final AnalysePlante analyse;

  @override
  Widget build(BuildContext context) {
    final maladie = analyse.diseaseDetected?.trim();
    final recommandations = analyse.recommendations?.trim();
    return Dialog(
      shape: const RoundedRectangleBorder(borderRadius: AppDimens.brCard),
      backgroundColor: AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(AppDimens.space16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (analyse.imageUrl.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: AspectRatio(
                  aspectRatio: 16 / 10,
                  child: Image.network(
                    analyse.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => Container(
                      color: AppColors.surfaceSoft,
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.image_outlined,
                        color: AppColors.textSubtle,
                      ),
                    ),
                  ),
                ),
              ),
            AppDimens.vGap12,
            Text(
              (maladie != null && maladie.isNotEmpty)
                  ? maladie
                  : 'Analyse en cours',
              style: AppTextStyles.titleLarge.copyWith(
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
            AppDimens.vGap4,
            Text(
              _formatDate(analyse.createdAt),
              style: AppTextStyles.bodySmall.copyWith(fontSize: 12),
            ),
            AppDimens.vGap12,
            if (recommandations != null && recommandations.isNotEmpty)
              Text(recommandations, style: AppTextStyles.bodyMedium)
            else
              Text(
                "Aucune recommandation détaillée n'a été fournie.",
                style: AppTextStyles.bodySmall,
              ),
            AppDimens.vGap16,
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Fermer'),
              ),
            ),
          ],
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
              Icons.eco_outlined,
              size: 40,
              color: AppColors.textSubtle.withValues(alpha: 0.9),
            ),
            const SizedBox(height: AppDimens.space12),
            Text(
              "Tu n'as pas encore lancé d'analyse",
              style: AppTextStyles.titleSmall,
            ),
            AppDimens.vGap4,
            Text(
              'Reviens ici une fois que tu auras diagnostiqué une plante.',
              style: AppTextStyles.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

String _formatDate(DateTime? d) {
  if (d == null) return '';
  return DateFormat('d MMM yyyy · HH:mm', 'fr_FR').format(d);
}
