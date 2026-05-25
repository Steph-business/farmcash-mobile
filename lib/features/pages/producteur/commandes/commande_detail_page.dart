import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../models/commande.dart';
import '../../../../models/enums.dart';
import '../../../../routing/route_names.dart';
import '../../../../services/providers.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';
import '../../../widgets/communs/chargement.dart';
import '../../../widgets/communs/section_titre.dart';
import '../../../widgets/communs/suivi_commande.dart';
import '../../../widgets/communs/vue_erreur.dart';
import '../../../widgets/producteur/commandes/actions_commande_producteur.dart';
import '../../../widgets/producteur/commandes/entete_commande_detail.dart';
import '../../../widgets/producteur/commandes/section_acheteur.dart';
import '../../../widgets/producteur/commandes/section_montants.dart';

// ─── Provider ────────────────────────────────────────────────────────────

final _commandeProvider = FutureProvider.autoDispose
    .family<Commande, String>((ref, id) async {
  return ref.watch(ordersServiceProvider).getOrder(id);
});

/// Détail d'une commande côté producteur. Composition pure et alignée
/// sur le détail acheteur (même layout, même hiérarchie visuelle) :
///   - Header avec ref + back
///   - **Suivi en TÊTE** (l'info la plus importante)
///   - Acheteur (avec adresse + chat)
///   - Montants nets (brut − 3% frais)
///   - Sticky actions (voir conversation / marquer expédiée)
///
/// Volontairement enlevés :
///   - Hero photo (générique, sans valeur ajoutée)
///   - Carte « Mon argent » (la section Montants dit déjà combien il
///     touchera, et le Suivi indique à quelle étape l'argent arrive)
///
/// Quand le transporteur est en route (IN_PROGRESS), le producteur peut
/// cliquer sur le suivi pour voir la position GPS du transporteur.
class CommandeDetailPage extends ConsumerWidget {
  const CommandeDetailPage({required this.commandeId, super.key});

  final String commandeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(_commandeProvider(commandeId));

    return Scaffold(
      backgroundColor: AppColors.surfaceSoft,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            EnteteCommandeDetail(commandeId: commandeId),
            Expanded(
              child: async.when(
                loading: () => const Padding(
                  padding: EdgeInsets.only(top: AppDimens.space32),
                  child: Chargement(size: 22),
                ),
                error: (e, _) => Padding(
                  padding: const EdgeInsets.all(AppDimens.pagePaddingH),
                  child: VueErreur(
                    message: 'Impossible de charger la commande.',
                    onRetry: () => ref.invalidate(_commandeProvider(commandeId)),
                  ),
                ),
                data: (commande) => _Body(commande: commande),
              ),
            ),
            async.maybeWhen(
              data: (commande) => ActionsCommandeProducteur(
                commande: commande,
                onAfterShipped: () =>
                    ref.invalidate(_commandeProvider(commandeId)),
              ),
              orElse: () => const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.commande});

  final Commande commande;

  @override
  Widget build(BuildContext context) {
    final qte = commande.quantiteKg;
    final prixKg = commande.prixUnitaireKg;
    final brut = commande.montantTotal > 0
        ? commande.montantTotal
        : qte * prixKg;
    final frais = (brut * 0.03).round().toDouble();
    final net = brut - frais;
    // Tracking du transporteur dispo seulement quand il est en route.
    // Avant ça il n'y a pas encore de position GPS à montrer.
    final canTrack = commande.status == OrderStatus.inProgress;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      children: [
        // 1. SUIVI EN TÊTE — comme côté acheteur, le producteur voit en
        //    premier où en est sa commande.
        SectionTitre(
          titre: 'Suivi de la commande',
          encadre: true,
          child: _SuiviCliquableProducteur(
            commandeId: commande.id,
            enabled: canTrack,
            child: SuiviCommande(
              commande: commande,
              viewerIsBuyer: false,
              // Montant net (après frais 3%) — affiché sur l'étape
              // « argent dans wallet » pour ne pas tromper avec le brut.
              montantNet: net,
            ),
          ),
        ),
        AppDimens.vGap12,
        // 2. Acheteur (avec adresse + bouton message).
        SectionAcheteur(commande: commande),
        AppDimens.vGap12,
        // 3. Montants nets — répond à « combien je touche ? ».
        SectionMontants(
          brut: brut,
          frais: frais,
          net: net,
          qte: qte,
          prixKg: prixKg,
        ),
      ],
    );
  }
}

/// Wrapper qui rend la section suivi cliquable côté producteur pour
/// ouvrir la page tracking GPS du transporteur. Désactivé tant que le
/// statut n'est pas `IN_PROGRESS` — avant, il n'y a rien à suivre.
class _SuiviCliquableProducteur extends StatelessWidget {
  const _SuiviCliquableProducteur({
    required this.commandeId,
    required this.enabled,
    required this.child,
  });

  final String commandeId;
  final bool enabled;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        child,
        if (enabled) ...[
          const SizedBox(height: 12),
          InkWell(
            // Le producteur réutilise la page tracking acheteur — c'est
            // la même donnée GPS (position du transporteur), même UI.
            onTap: () => context.push(
              RouteNames.acheteurLivraisonTrackingPathFor(commandeId),
            ),
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 11,
              ),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: AppColors.primary,
                  width: AppDimens.borderThin,
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.location_on_outlined,
                    size: 18,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Voir la position du transporteur',
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right,
                    size: 18,
                    color: AppColors.primary,
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}
