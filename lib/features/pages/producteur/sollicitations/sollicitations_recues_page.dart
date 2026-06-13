import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../models/sollicitation.dart';
import '../../../../services/providers.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';
import '../../../widgets/communs/chargement.dart';
import '../../../widgets/communs/entete_page_standard.dart';
import '../../../widgets/communs/vue_erreur.dart';
import '../../../widgets/producteur/sollicitations/liste_sollicitations_recues.dart';

/// Récupère la liste des sollicitations actives **dont le producteur est
/// destinataire** (table `sollicitation_recipients`).
/// L'ancien appel `listSollicitations` est COOP-only → 403 pour FARMER.
final _sollicitationsProvider = FutureProvider.autoDispose<List<Sollicitation>>(
  (ref) async {
    final paginated = await ref
        .watch(cooperativesServiceProvider)
        .listSollicitationsPourMoi(status: 'OPEN', limit: 50);
    return paginated.data;
  },
);

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
            const EntetePageStandard(titre: 'Sollicitations de ma coop'),
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
                      : ListeSollicitationsRecues(items: items),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
