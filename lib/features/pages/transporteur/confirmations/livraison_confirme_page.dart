import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../models/livraison.dart';
import '../../../../services/providers.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../widgets/communs/chargement.dart';
import '../../../widgets/transporteur/confirmations/banniere_credit_wallet.dart';
import '../../../widgets/transporteur/confirmations/barre_actions_livraison.dart';
import '../../../widgets/transporteur/confirmations/carte_recap_livraison.dart';
import '../../../widgets/transporteur/confirmations/entete_livraison_confirme.dart';
import '../../../widgets/transporteur/confirmations/hero_check_livraison.dart';
import '../../../widgets/transporteur/confirmations/mini_timeline_livraison.dart';
import '../../../widgets/transporteur/confirmations/titre_section_confirme.dart';

final NumberFormat _nf = NumberFormat('#,##0', 'fr_FR');

/// Provider qui cherche la mission livrée parmi les missions du
/// transporteur (statut DELIVERED).
final _missionLivreeProvider = FutureProvider.autoDispose
    .family<Livraison?, String>((ref, id) async {
  final svc = ref.read(logisticsServiceProvider);
  final list = await svc.getMyMissions();
  for (final m in list) {
    if (m.id == id) return m;
  }
  return null;
});

/// Confirmation finale de livraison + crédit wallet transporteur.
class LivraisonConfirmePage extends ConsumerWidget {
  const LivraisonConfirmePage({required this.missionId, super.key});

  final String missionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(_missionLivreeProvider(missionId));
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const EnteteLivraisonConfirme(title: 'Livraison confirmée'),
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
            BarreActionsLivraison(missionId: missionId),
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
    final prix = m?.prixFinal ?? m?.prixDevis;
    final montantTxt = prix != null
        ? '+${_nf.format(prix.round())} F crédités sur ton wallet'
        : 'Paiement en cours de crédit sur ton wallet';
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
      children: [
        HeroCheckLivraison(
          title: 'Livraison confirmée !',
          subtitle: montantTxt,
        ),
        AppDimens.vGap24,
        if (m != null) CarteRecapLivraison(mission: m),
        AppDimens.vGap16,
        if (prix != null) BanniereCreditWallet(montant: prix),
        if (prix != null) AppDimens.vGap16,
        const TitreSectionConfirme('Étapes complétées'),
        AppDimens.vGap8,
        const MiniTimelineLivraison(
          items: [
            DonneeEtapeTimeline(icon: Icons.check, label: 'Enlèvement confirmé'),
            DonneeEtapeTimeline(
                icon: Icons.check, label: 'Livraison confirmée chez acheteur'),
          ],
        ),
      ],
    );
  }
}
