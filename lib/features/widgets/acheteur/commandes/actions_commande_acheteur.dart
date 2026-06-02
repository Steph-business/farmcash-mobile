import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../models/commande.dart';
import '../../../../models/enums.dart';
import '../../../../routing/route_names.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';
import '../../communs/litige/motifs_litige.dart';

/// Bandeau d'actions sticky en bas de la page détail commande côté
/// acheteur. L'action affichée dépend du statut commande :
///
///   - DELIVERED non confirmée → bouton primaire « Confirmer la
///     réception · libérer le paiement »
///   - IN_PROGRESS → bouton primaire « Voir mon QR de réception »
///   - SENT / ACCEPTED → bannière jaune d'attente (pas de CTA — le
///     vendeur n'a pas encore expédié, l'acheteur ne peut rien faire)
///   - COMPLETED / DELIVERED → bouton secondaire « Évaluer le transport »
///
/// Le bouton « Signaler un problème » apparaît tant que la commande est
/// active et que l'escrow n'a pas été libéré.
///
/// Affichage exclusif : l'acheteur voit toujours **une seule** action
/// claire, jamais un mur de boutons.
class ActionsCommandeAcheteur extends StatelessWidget {
  const ActionsCommandeAcheteur({
    required this.commande,
    required this.busy,
    required this.onConfirmerReception,
    required this.onAfterLitige,
    super.key,
  });

  final Commande commande;

  /// `true` pendant l'appel `confirmDelivery` — désactive le bouton et
  /// affiche un loader.
  final bool busy;

  /// Callback appelé sur tap « Confirmer la réception ». Le composant
  /// parent doit afficher la confirmation modale et faire l'appel API.
  final VoidCallback onConfirmerReception;

  /// Callback appelé après création d'un litige depuis la page litige.
  /// Permet au parent d'invalider son provider pour refléter le statut
  /// `DISPUTED` côté UI (sinon le bouton « Confirmer la réception »
  /// reste visible avec un état cache).
  final VoidCallback onAfterLitige;

  @override
  Widget build(BuildContext context) {
    // Strictement aligné sur la règle backend `confirmDelivery` :
    // `commande.status === DELIVERED` ET escrow non encore libéré.
    // Sur IN_PROGRESS le bouton n'a pas de sens (le colis n'est pas
    // encore arrivé) — on affiche le QR à la place. Sur DISPUTED /
    // COMPLETED / CANCELLED on ne propose rien (états figés).
    final showConfirm = !commande.escrowReleased &&
        commande.status == OrderStatus.delivered;
    final showEvaluation = commande.status == OrderStatus.delivered ||
        commande.status == OrderStatus.completed;
    // Le QR n'a de sens que pendant le transit. Sur DELIVERED + !escrow,
    // c'est l'étape « Confirmer la réception » qui prend le relais.
    final showQrReception =
        commande.status == OrderStatus.inProgress;
    final showAttente = commande.status == OrderStatus.sent ||
        commande.status == OrderStatus.accepted;
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(
          top: BorderSide(
            color: AppColors.border,
            width: AppDimens.borderThin,
          ),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
      child: Column(
        children: [
          if (showConfirm)
            _BoutonConfirmer(busy: busy, onTap: onConfirmerReception)
          else if (showQrReception)
            _BoutonQr(commandeId: commande.id)
          else if (showAttente)
            _BannereAttente(status: commande.status),
          if (showEvaluation) ...[
            const SizedBox(height: 8),
            _BoutonEvaluation(commandeId: commande.id),
          ],
          // Aligné sur la règle backend : litige autorisé seulement sur
          // IN_PROGRESS et DELIVERED. Sur les autres statuts le backend
          // renverrait 400 — on cache donc le lien plutôt que d'afficher
          // un message d'erreur incompréhensible.
          if (peutOuvrirLitige(commande.status)) ...[
            const SizedBox(height: 6),
            Center(
              child: TextButton.icon(
                onPressed: () async {
                  final result = await context.push<bool>(
                    RouteNames.signalerProblemePathFor(commande.id),
                  );
                  // Litige créé → on demande au parent de rafraîchir le
                  // provider pour que le statut DISPUTED apparaisse et
                  // que les boutons d'action soient masqués.
                  if (result == true) onAfterLitige();
                },
                icon: const Icon(
                  Icons.flag_outlined,
                  size: 16,
                  color: AppColors.error,
                ),
                label: Text(
                  'Signaler un problème',
                  style: AppTextStyles.bodySmall.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.error,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _BoutonConfirmer extends StatelessWidget {
  const _BoutonConfirmer({required this.busy, required this.onTap});
  final bool busy;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: InkWell(
        onTap: busy ? null : onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 13),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(10),
          ),
          alignment: Alignment.center,
          child: busy
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Colors.white,
                  ),
                )
              : Text(
                  'Confirmer la réception · libérer le paiement',
                  style: AppTextStyles.button.copyWith(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onPrimary,
                  ),
                ),
        ),
      ),
    );
  }
}

class _BoutonQr extends StatelessWidget {
  const _BoutonQr({required this.commandeId});
  final String commandeId;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: InkWell(
        onTap: () => context.push(
          RouteNames.acheteurLivraisonQrPathFor(commandeId),
        ),
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 13),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(10),
          ),
          alignment: Alignment.center,
          child: Text(
            'Voir mon QR de réception',
            style: AppTextStyles.button.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.onPrimary,
            ),
          ),
        ),
      ),
    );
  }
}

class _BoutonEvaluation extends StatelessWidget {
  const _BoutonEvaluation({required this.commandeId});
  final String commandeId;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: InkWell(
        onTap: () => context.push(
          RouteNames.acheteurCommandeEvaluationPathFor(commandeId),
        ),
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 13),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: AppColors.primary,
              width: AppDimens.borderThin,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            'Évaluer le transport',
            style: AppTextStyles.button.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
        ),
      ),
    );
  }
}

class _BannereAttente extends StatelessWidget {
  const _BannereAttente({required this.status});
  final OrderStatus status;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppColors.border,
          width: AppDimens.borderThin,
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.schedule,
            size: 18,
            color: Color(0xFFB26A00),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              status == OrderStatus.sent
                  ? 'En attente que le vendeur accepte ta commande.'
                  : 'Le vendeur prépare ta commande. Tu seras notifié dès l\'expédition.',
              style: AppTextStyles.bodySmall.copyWith(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: const Color(0xFFB26A00),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
