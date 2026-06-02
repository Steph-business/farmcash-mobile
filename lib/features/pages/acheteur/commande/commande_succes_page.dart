import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../models/commande.dart';
import '../../../../routing/route_names.dart';
import '../../../../services/providers.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../widgets/acheteur/commandes/boutons_sticky_commande_succes.dart';
import '../../../widgets/acheteur/commandes/carte_recap_succes_commande.dart';
import '../../../widgets/acheteur/commandes/header_commande_succes.dart';
import '../../../widgets/acheteur/commandes/hero_commande_succes.dart';
import '../../../widgets/acheteur/commandes/liste_etapes_commande_succes.dart';
import '../../../widgets/acheteur/commandes/pied_reference_commande_succes.dart';
import '../../../widgets/communs/chargement.dart';
import '../../../widgets/communs/vue_erreur.dart';

// ─── Provider ────────────────────────────────────────────────────────

final _commandeSuccesProvider = FutureProvider.autoDispose
    .family<Commande, String>((ref, id) async {
  return ref.read(ordersServiceProvider).getOrder(id);
});

/// Confirmation de commande après paiement réussi. Charge la commande
/// depuis l'API pour afficher la référence et les montants réels.
class CommandeSuccesPage extends ConsumerWidget {
  const CommandeSuccesPage({required this.commandeId, super.key});

  final String commandeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(_commandeSuccesProvider(commandeId));
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: async.when(
          loading: () => Column(
            children: [
              HeaderCommandeSucces(
                  onClose: () => context.go(RouteNames.accueilAcheteurPath)),
              const Expanded(child: Chargement(size: 22)),
            ],
          ),
          error: (e, _) => Column(
            children: [
              HeaderCommandeSucces(
                  onClose: () => context.go(RouteNames.accueilAcheteurPath)),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(AppDimens.pagePaddingH),
                  child: VueErreur(
                    message: 'Impossible de charger la commande. $e',
                    onRetry: () =>
                        ref.invalidate(_commandeSuccesProvider(commandeId)),
                  ),
                ),
              ),
            ],
          ),
          data: (cmd) => _build(context, cmd),
        ),
      ),
    );
  }

  Widget _build(BuildContext context, Commande cmd) {
    final reference = cmd.reference.isNotEmpty ? cmd.reference : cmd.id;
    return Column(
      children: [
        HeaderCommandeSucces(
            onClose: () => context.go(RouteNames.accueilAcheteurPath)),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
            children: [
              // Bloc 1 — Hero : ✓ + « Commande passée ! » + 1 ligne.
              const HeroCommandeSucces(),
              const SizedBox(height: 8),
              // Bloc 2 — Carte hero montant : montant en grand + 2
              //          micro-blocs (quantité + livraison). Plus de
              //          tableau verbeux 4 lignes ni de N° commande.
              CarteRecapSuccesCommande(commande: cmd),
              const SizedBox(height: 22),
              // Bloc 3 — Stepper horizontal 4 étapes. Visuel, sans
              //          paragraphe explicatif (« Et maintenant ? »
              //          retiré — le stepper se lit instantanément).
              const ListeEtapesCommandeSucces(),
              const SizedBox(height: 18),
              // Bloc 4 — Référence en footer discret, tappable pour
              //          copier. L'info reste accessible (support) mais
              //          ne pollue plus la carte montant.
              PiedReferenceCommandeSucces(reference: reference),
            ],
          ),
        ),
        BoutonsStickyCommandeSucces(commandeId: cmd.id),
      ],
    );
  }
}
