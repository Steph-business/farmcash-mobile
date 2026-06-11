// =====================================================================
//  Page : Plans d'approvisionnement disponibles (coop / producteur)
//  ---------------------------------------------------------------------
//  Affiche les plans PUBLISHED + NEGOTIATING visibles aux fournisseurs.
//  Tap sur une carte → ouvre la sheet candidature.
//  Chantier 2 — Phase 3 mobile (côté fournisseur).
// =====================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../models/supply_plan.dart';
import '../../../../services/providers.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';
import '../../../widgets/communs/entete_page_compacte_coop.dart';
import '../../../widgets/cooperative/supply_plans/sheet_candidater_plan.dart';

final plansPublicsProvider =
    FutureProvider.autoDispose<List<SupplyPlan>>((ref) async {
  return ref.read(supplyPlansServiceProvider).listPublicPlans();
});

class PlansPublicsPage extends ConsumerWidget {
  const PlansPublicsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plansAsync = ref.watch(plansPublicsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const EntetePageCompacteCoop(title: 'Plans B2B disponibles'),
            Expanded(
              child: plansAsync.when(
                data: (plans) => plans.isEmpty
                    ? const _EmptyState()
                    : RefreshIndicator(
                        onRefresh: () async =>
                            ref.invalidate(plansPublicsProvider),
                        child: ListView.separated(
                          padding:
                              const EdgeInsets.fromLTRB(16, 12, 16, 16),
                          itemCount: plans.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 10),
                          itemBuilder: (_, i) => _CartePlanPublic(
                            plan: plans[i],
                            onTap: () => _ouvrirCandidature(
                                context, ref, plans[i]),
                          ),
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
    );
  }

  Future<void> _ouvrirCandidature(
    BuildContext context,
    WidgetRef ref,
    SupplyPlan plan,
  ) async {
    final candidatureCreee = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => SheetCandidaterPlan(plan: plan),
    );
    if (candidatureCreee == true) {
      ref.invalidate(plansPublicsProvider);
    }
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
                Icons.search_off_rounded,
                size: 38,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'Aucun plan disponible',
              textAlign: TextAlign.center,
              style: AppTextStyles.titleMedium.copyWith(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w800,
                color: AppColors.text,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Les plans d\'approvisionnement B2B publiés par les '
              'acheteurs apparaîtront ici. Reviens plus tard.',
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

class _CartePlanPublic extends StatelessWidget {
  const _CartePlanPublic({required this.plan, required this.onTap});
  final SupplyPlan plan;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final nf = NumberFormat('#,##0', 'fr_FR');

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
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(9),
                    ),
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.factory_outlined,
                      color: AppColors.primary,
                      size: 19,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          plan.produitNom ?? 'Plan B2B',
                          style: AppTextStyles.titleSmall.copyWith(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w800,
                            color: AppColors.text,
                          ),
                        ),
                        if (plan.buyerName != null)
                          Text(
                            'par ${plan.buyerName}',
                            style: AppTextStyles.bodySmall.copyWith(
                              fontSize: 11.5,
                              color: AppColors.textSecondary,
                            ),
                          ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 9, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${nf.format(plan.pricePerKg.round())} F/kg',
                      style: AppTextStyles.labelSmall.copyWith(
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                decoration: BoxDecoration(
                  color: AppColors.surfaceSoft,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    _miniInfo(
                      Icons.inventory_2_outlined,
                      '${nf.format(plan.qtyPerMonthKg.round())} kg/mois',
                    ),
                    const SizedBox(width: 12),
                    _miniInfo(
                      Icons.schedule_rounded,
                      '${plan.durationMonths} mois',
                    ),
                    const SizedBox(width: 12),
                    _miniInfo(
                      Icons.calendar_today_outlined,
                      'Dès ${plan.formatStartMonth()}',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(
                    Icons.location_on_outlined,
                    size: 14,
                    color: AppColors.textSubtle,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Livraison : ${plan.deliveryCity}',
                    style: AppTextStyles.bodySmall.copyWith(
                      fontSize: 11.5,
                      color: AppColors.textSubtle,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'Candidater →',
                    style: AppTextStyles.labelSmall.copyWith(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _miniInfo(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: AppColors.textSecondary),
        const SizedBox(width: 4),
        Text(
          text,
          style: AppTextStyles.bodySmall.copyWith(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppColors.text,
          ),
        ),
      ],
    );
  }
}
