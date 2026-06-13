import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../models/livraison.dart';
import '../../../../services/providers.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../widgets/communs/chargement.dart';
import '../../../widgets/communs/entete_page_standard.dart';
import '../../../widgets/transporteur/confirmations/barre_action_demarrer_livraison.dart';
import '../../../widgets/transporteur/confirmations/carte_recap_enlevement.dart';
import '../../../widgets/transporteur/confirmations/hero_check_enlevement.dart';
import '../../../widgets/transporteur/confirmations/mini_timeline_enlevement.dart';
import '../../../widgets/transporteur/confirmations/titre_section_enlevement.dart';

/// Provider qui récupère une mission via `getMyMissions()` (la mission est
/// nécessairement acceptée par le transporteur à ce stade — sinon elle ne
/// serait pas LOADING).
final _missionByIdProvider = FutureProvider.autoDispose
    .family<Livraison?, String>((ref, id) async {
  final svc = ref.read(logisticsServiceProvider);
  final list = await svc.getMyMissions();
  for (final m in list) {
    if (m.id == id) return m;
  }
  return null;
});

/// Confirmation d'enlèvement chez le producteur — hero check vert,
/// récap mission, mini timeline et CTA pour démarrer la livraison.
class EnlevementConfirmePage extends ConsumerWidget {
  const EnlevementConfirmePage({required this.missionId, super.key});

  final String missionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(_missionByIdProvider(missionId));
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const EntetePageStandard(titre: 'Enlèvement confirmé'),
            Expanded(
              child: async.when(
                loading: () => const Padding(
                  padding: EdgeInsets.only(top: 48),
                  child: Chargement(size: 22),
                ),
                error: (_, _) => const _Contenu(mission: null),
                data: (m) => _Contenu(mission: m),
              ),
            ),
            BarreActionDemarrerLivraison(missionId: missionId),
          ],
        ),
      ),
    );
  }
}

class _Contenu extends StatelessWidget {
  const _Contenu({required this.mission});

  final Livraison? mission;

  @override
  Widget build(BuildContext context) {
    final m = mission;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
      children: [
        const HeroCheckEnlevement(
          title: 'Colis chargé !',
          subtitle: 'Direction le point de livraison',
        ),
        AppDimens.vGap24,
        if (m != null) CarteRecapEnlevement(mission: m),
        AppDimens.vGap16,
        const TitreSectionEnlevement('Prochaine étape'),
        AppDimens.vGap8,
        const MiniTimelineEnlevement(
          items: [
            DonneeEtapeEnlevement(
              icon: Icons.check,
              label: 'Enlèvement confirmé',
              state: EtatEtapeEnlevement.done,
            ),
            DonneeEtapeEnlevement(
              icon: Icons.local_shipping,
              label: 'Livraison en cours',
              state: EtatEtapeEnlevement.current,
            ),
            DonneeEtapeEnlevement(
              icon: Icons.qr_code_scanner,
              label: 'Scan QR livraison chez acheteur',
              state: EtatEtapeEnlevement.pending,
            ),
          ],
        ),
      ],
    );
  }
}
