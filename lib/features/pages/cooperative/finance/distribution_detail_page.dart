import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../models/payout.dart';
import '../../../../services/providers.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';
import '../../../widgets/communs/chargement.dart';
import '../../../widgets/communs/vue_erreur.dart';
import '../../../widgets/cooperative/finance/bouton_sticky_confirmer_distribution.dart';
import '../../../widgets/cooperative/finance/entete_distribution_detail.dart';
import '../../../widgets/cooperative/finance/hero_info_distribution.dart';
import '../../../widgets/cooperative/finance/section_beneficiaires.dart';

/// Provider qui retrouve un batch via `listPayoutBatches()` + filtre par id.
/// Pas d'endpoint `GET /finance/payout-batches/:id` côté backend.
final _payoutDetailProvider = FutureProvider.autoDispose
    .family<PayoutBatch?, String>((ref, id) async {
  final all = await ref.read(financeServiceProvider).listPayoutBatches();
  for (final p in all) {
    if (p.id == id) return p;
  }
  return null;
});

/// Page Distribution détail — items réels du `PayoutBatch`.
///
/// CRITIQUE — règle 3b : la coop voit ses membres FULL (nom complet).
/// Mais les items du batch ne portent qu'un `userId` + montant côté API ;
/// l'enrichissement nom/photo nécessitera un endpoint dédié.
class DistributionDetailPage extends ConsumerWidget {
  const DistributionDetailPage({super.key, required this.payoutId});

  /// Identifiant du payout batch.
  final String payoutId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(_payoutDetailProvider(payoutId));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const EnteteDistributionDetail(),
            Expanded(
              child: async.when(
                loading: () => const Padding(
                  padding: EdgeInsets.only(top: 48),
                  child: Chargement(size: 22),
                ),
                error: (e, _) => Padding(
                  padding: const EdgeInsets.all(AppDimens.pagePaddingH),
                  child: VueErreur(
                    message: 'Impossible de charger ce batch. $e',
                    onRetry: () =>
                        ref.invalidate(_payoutDetailProvider(payoutId)),
                  ),
                ),
                data: (batch) {
                  if (batch == null) {
                    return Padding(
                      padding: const EdgeInsets.all(AppDimens.pagePaddingH),
                      child: Text(
                        'Distribution introuvable.',
                        style: AppTextStyles.bodyMedium,
                      ),
                    );
                  }
                  return _Body(batch: batch);
                },
              ),
            ),
            async.maybeWhen(
              data: (b) => b != null
                  ? BoutonStickyConfirmerDistribution(payoutId: payoutId)
                  : const SizedBox.shrink(),
              orElse: () => const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.batch});

  final PayoutBatch batch;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppDimens.pagePaddingH,
        0,
        AppDimens.pagePaddingH,
        AppDimens.space16,
      ),
      children: [
        HeroInfoDistribution(batch: batch),
        AppDimens.vGap24,
        SectionBeneficiaires(batch: batch),
      ],
    );
  }
}
