// =====================================================================
//  Page : Mes plans d'approvisionnement (acheteur)
//  ---------------------------------------------------------------------
//  Liste premium des plans créés par l'acheteur, avec statut + volume +
//  durée + nombre de candidatures. FAB pour créer un nouveau plan.
//  Chantier 2 — Phase 2 mobile.
// =====================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../models/supply_plan.dart';
import '../../../../services/providers.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';
import '../../../widgets/communs/entete_page_compacte_acheteur.dart';
import 'package:go_router/go_router.dart';
import '../../../../routing/route_names.dart';

final _mesPlansProvider =
    FutureProvider.autoDispose<List<SupplyPlan>>((ref) async {
  return ref.watch(supplyPlansServiceProvider).listMyPlans();
});

class MesPlansPage extends ConsumerWidget {
  const MesPlansPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plansAsync = ref.watch(_mesPlansProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const EntetePageCompacteAcheteur(title: 'Mes plans B2B'),
            Expanded(
              child: plansAsync.when(
                data: (plans) => plans.isEmpty
                    ? const _EmptyState()
                    : RefreshIndicator(
                        onRefresh: () async =>
                            ref.invalidate(_mesPlansProvider),
                        child: ListView.separated(
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
                          itemCount: plans.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 10),
                          itemBuilder: (ctx, i) {
                            final p = plans[i];
                            return _CartePlan(
                              plan: p,
                              onTap: () async {
                                await ctx.push<void>(
                                  RouteNames
                                      .acheteurDetailPlanPathFor(p.id),
                                );
                                // Au retour, on rafraîchit pour refléter
                                // les éventuelles accept/reject.
                                ref.invalidate(_mesPlansProvider);
                              },
                            );
                          },
                        ),
                      ),
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      'Erreur : $e',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodyMedium,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        onPressed: () async {
          // Navigation vers le wizard de création. Au retour, on
          // rafraîchit la liste si un plan a bien été créé.
          final created =
              await context.push<bool>(RouteNames.acheteurCreerPlanPath);
          if (created == true) {
            ref.invalidate(_mesPlansProvider);
          }
        },
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'Nouveau plan',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

// ───────────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState();
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(28, 12, 28, 80),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 84,
              height: 84,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.10),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.factory_outlined,
                size: 38,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'Aucun plan d\'approvisionnement',
              textAlign: TextAlign.center,
              style: AppTextStyles.titleMedium.copyWith(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w800,
                color: AppColors.text,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Crée un plan pour engager un volume mensuel garanti '
              'sur 3 à 12 mois — idéal pour brasseries, exportateurs, '
              'agro-industriels.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ───────────────────────────────────────────────────────────────────

class _CartePlan extends StatelessWidget {
  const _CartePlan({required this.plan, required this.onTap});
  final SupplyPlan plan;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final nf = NumberFormat('#,##0', 'fr_FR');
    final statusColor = _colorForStatus(plan.status);

    return Material(
      color: Colors.white,
      borderRadius: AppDimens.brCard,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppDimens.brCard,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: AppDimens.brCard,
            border: Border.all(color: AppColors.border),
          ),
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      plan.produitNom ?? 'Plan',
                      style: AppTextStyles.titleSmall.copyWith(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w800,
                        color: AppColors.text,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      labelStatutPlan(plan.status),
                      style: AppTextStyles.labelSmall.copyWith(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        color: statusColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                '${nf.format(plan.qtyPerMonthKg.round())} kg/mois '
                '× ${plan.durationMonths} mois '
                '· ${nf.format(plan.pricePerKg.round())} F/kg',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(
                    Icons.calendar_month_outlined,
                    size: 13,
                    color: AppColors.textSubtle,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Début ${plan.formatStartMonth()}',
                    style: AppTextStyles.bodySmall.copyWith(
                      fontSize: 11.5,
                      color: AppColors.textSubtle,
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Icon(
                    Icons.location_on_outlined,
                    size: 13,
                    color: AppColors.textSubtle,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    plan.deliveryCity,
                    style: AppTextStyles.bodySmall.copyWith(
                      fontSize: 11.5,
                      color: AppColors.textSubtle,
                    ),
                  ),
                  const Spacer(),
                  if (plan.candidaturesCount != null &&
                      plan.candidaturesCount! > 0) ...[
                    const Icon(
                      Icons.handshake_outlined,
                      size: 13,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${plan.candidaturesCount} candidature'
                      '${plan.candidaturesCount! > 1 ? 's' : ''}',
                      style: AppTextStyles.bodySmall.copyWith(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ],
              ),
              if (plan.status == 'REJECTED' &&
                  plan.adminRejectionReason != null) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.fromLTRB(10, 7, 10, 7),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEE2E2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.error_outline_rounded,
                        size: 14,
                        color: Color(0xFF991B1B),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Motif : ${plan.adminRejectionReason}',
                          style: AppTextStyles.bodySmall.copyWith(
                            fontSize: 11,
                            color: const Color(0xFF991B1B),
                            height: 1.35,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Color _colorForStatus(String status) {
    switch (status) {
      case 'PUBLISHED':
      case 'ACTIVE':
        return AppColors.primary;
      case 'NEGOTIATING':
        return const Color(0xFFD97706); // orange
      case 'PENDING_VALIDATION':
        return const Color(0xFF6B7280); // gris
      case 'REJECTED':
      case 'CANCELLED':
        return const Color(0xFF991B1B); // rouge
      case 'COMPLETED':
        return const Color(0xFF1B7F3A); // vert succès
      default:
        return AppColors.textSecondary;
    }
  }
}
