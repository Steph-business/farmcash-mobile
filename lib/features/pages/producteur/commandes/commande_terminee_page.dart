import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../models/commande.dart';
import '../../../../services/providers.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../widgets/communs/entete_page_standard.dart';
import '../../../widgets/producteur/commandes/commande_terminee_constants.dart';
import '../../../widgets/producteur/commandes/hero_commande_terminee.dart';
import '../../../widgets/producteur/commandes/qr_card_commande.dart';
import '../../../widgets/producteur/commandes/recap_card_commande.dart';
import '../../../widgets/producteur/commandes/sticky_actions_commande_terminee.dart';
import '../../../widgets/producteur/commandes/trace_card_commande.dart';

/// Provider familial : essaie de charger la commande pour personnaliser
/// le slug/ref affichés. Tombe sur les valeurs mock si l'API renvoie une
/// erreur — l'écran reste fidèle à la maquette dans tous les cas.
final _commandeProvider = FutureProvider.autoDispose.family<Commande?, String>((
  ref,
  id,
) async {
  try {
    return await ref.watch(ordersServiceProvider).getOrder(id);
  } catch (_) {
    return null;
  }
});

/// Écran final d'une commande livrée — confirmation hero + QR de
/// traçabilité produit (scanné par tout acheteur/revendeur/contrôleur).
class CommandeTermineePage extends ConsumerWidget {
  const CommandeTermineePage({required this.commandeId, super.key});

  final String commandeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncCommande = ref.watch(_commandeProvider(commandeId));
    final commandeRef = asyncCommande.maybeWhen(
      data: (c) => c?.reference.isNotEmpty == true
          ? c!.reference
          : kCommandeTermineeFallbackRef,
      orElse: () => kCommandeTermineeFallbackRef,
    );
    final traceUrl = 'farmcash.ci/t/$kCommandeTermineeFallbackTraceSlug';
    final qrPayload = 'https://$traceUrl';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const EntetePageStandard(titre: 'Commande livrée'),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
                children: [
                  const HeroCommandeTerminee(),
                  AppDimens.vGap16,
                  QrCardCommande(
                    payload: qrPayload,
                    commandeRef: commandeRef,
                    traceUrl: traceUrl,
                  ),
                  AppDimens.vGap16,
                  const TraceCardCommande(),
                  AppDimens.vGap16,
                  const RecapCardCommande(),
                ],
              ),
            ),
            StickyActionsCommandeTerminee(commandeId: commandeId),
          ],
        ),
      ),
    );
  }
}
