import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../models/payout.dart';
import '../../../../services/providers.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';
import '../../../widgets/communs/chargement.dart';
import '../../../widgets/communs/vue_erreur.dart';
import '../../../widgets/cooperative/finance/carte_compteur_payouts.dart';
import '../../../widgets/cooperative/finance/carte_payout.dart';
import '../../../widgets/cooperative/finance/entete_payouts.dart';
import '../../../widgets/cooperative/finance/format_montant_fcfa.dart';
import '../../../widgets/cooperative/finance/onglets_payouts.dart';

/// Provider qui charge les batches du backend.
final _payoutsProvider = FutureProvider.autoDispose<List<PayoutBatch>>((ref) {
  return ref.read(financeServiceProvider).listPayoutBatches();
});

/// Page Distributions coopérative — liste des batches de payouts.
class PayoutsCooperativePage extends ConsumerStatefulWidget {
  const PayoutsCooperativePage({super.key});

  @override
  ConsumerState<PayoutsCooperativePage> createState() =>
      _PayoutsCooperativePageState();
}

class _PayoutsCooperativePageState
    extends ConsumerState<PayoutsCooperativePage> {
  PayoutTab _tab = PayoutTab.aDistribuer;

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(_payoutsProvider);
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const EntetePayouts(),
            Expanded(
              child: async.when(
                loading: () => const Padding(
                  padding: EdgeInsets.only(top: 48),
                  child: Chargement(size: 22),
                ),
                error: (e, _) => Padding(
                  padding: const EdgeInsets.all(AppDimens.pagePaddingH),
                  child: VueErreur(
                    message: 'Impossible de charger les distributions. $e',
                    onRetry: () => ref.invalidate(_payoutsProvider),
                  ),
                ),
                data: (all) {
                  final aDistribuer = all
                      .where((p) =>
                          p.status.toUpperCase() == 'PENDING' ||
                          p.status.toUpperCase() == 'PROCESSING')
                      .toList(growable: false);
                  final historique = all
                      .where((p) =>
                          p.status.toUpperCase() != 'PENDING' &&
                          p.status.toUpperCase() != 'PROCESSING')
                      .toList(growable: false);
                  final tabList = _tab == PayoutTab.aDistribuer
                      ? aDistribuer
                      : historique;
                  final totalMontant = aDistribuer.fold<double>(
                    0,
                    (acc, p) => acc + p.totalAmount,
                  );
                  return RefreshIndicator(
                    color: AppColors.primary,
                    onRefresh: () async {
                      ref.invalidate(_payoutsProvider);
                      await ref.read(_payoutsProvider.future);
                    },
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(
                        AppDimens.pagePaddingH,
                        0,
                        AppDimens.pagePaddingH,
                        AppDimens.space16,
                      ),
                      children: [
                        CarteCompteurPayouts(
                          value:
                              '${aDistribuer.length} distribution(s) à faire',
                          sub: '${formatMontantFcfa(totalMontant)} F total',
                        ),
                        AppDimens.vGap16,
                        OngletsPayouts(
                          tab: _tab,
                          aDistribuerCount: aDistribuer.length,
                          historiqueCount: historique.length,
                          onChange: (t) => setState(() => _tab = t),
                        ),
                        AppDimens.vGap16,
                        if (tabList.isEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 24),
                            child: Center(
                              child: Text(
                                _tab == PayoutTab.aDistribuer
                                    ? 'Aucune distribution en attente.'
                                    : 'Aucun historique pour le moment.',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                          )
                        else
                          for (final p in tabList) ...[
                            CartePayout(payout: p),
                            const SizedBox(height: 12),
                          ],
                      ],
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
