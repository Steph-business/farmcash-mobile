import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../api_client/api_exception.dart';
import '../../../../models/commande.dart';
import '../../../../models/enums.dart';
import '../../../../routing/route_names.dart';
import '../../../../services/providers.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';
import '../../communs/litige/motifs_litige.dart';
import '../../communs/snackbars.dart';

/// Bandeau d'actions sticky en bas de la page détail commande côté
/// producteur. Deux boutons : « Voir la conversation » (gauche, secondaire)
/// et « Marquer comme expédiée » (droite, primaire).
///
/// Le bouton expédié n'est actif que tant que la commande est avant
/// l'étape `IN_PROGRESS`. Après, on grise pour éviter qu'un farmer
/// re-clique alors que la commande est déjà partie chez le transporteur.
///
/// Le parent fournit [onAfterShipped] pour invalider son provider de
/// commande après le passage `SENT` → `IN_PROGRESS`.
class ActionsCommandeProducteur extends ConsumerStatefulWidget {
  const ActionsCommandeProducteur({
    required this.commande,
    required this.onAfterShipped,
    super.key,
  });

  final Commande commande;

  /// Appelé après que l'API `updateOrderStatus(IN_PROGRESS)` ait réussi —
  /// le parent doit invalider son `FutureProvider` pour rafraîchir la
  /// page (statut + timeline).
  final VoidCallback onAfterShipped;

  @override
  ConsumerState<ActionsCommandeProducteur> createState() =>
      _ActionsCommandeProducteurState();
}

class _ActionsCommandeProducteurState
    extends ConsumerState<ActionsCommandeProducteur> {
  bool _busy = false;

  bool get _canShip {
    switch (widget.commande.status) {
      case OrderStatus.sent:
      case OrderStatus.accepted:
        return true;
      case OrderStatus.inProgress:
      case OrderStatus.delivered:
      case OrderStatus.completed:
      case OrderStatus.disputed:
      case OrderStatus.cancelled:
      case OrderStatus.rejected:
      case OrderStatus.unknown:
        return false;
    }
  }

  /// Le QR d'enlèvement n'a de sens qu'au statut ACCEPTED — l'acheteur
  /// a payé, le producteur a accepté, le transporteur va arriver bientôt.
  /// Sur SENT (vendeur n'a pas encore accepté) on cache. Sur IN_PROGRESS
  /// + après (transporteur déjà parti / livré) on cache aussi.
  bool get _canShowQr =>
      widget.commande.status == OrderStatus.accepted;

  Future<void> _markShipped() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await ref.read(ordersServiceProvider).updateOrderStatus(
            id: widget.commande.id,
            newStatus: OrderStatus.inProgress,
          );
      if (!mounted) return;
      Snackbars.showSucces(context, 'Commande marquée comme expédiée.');
      widget.onAfterShipped();
    } on ApiException catch (e) {
      if (!mounted) return;
      Snackbars.showErreur(context, e.message);
    } catch (_) {
      if (!mounted) return;
      Snackbars.showErreur(context, 'Impossible de marquer comme expédiée.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final shipEnabled = _canShip && !_busy;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        // Légère ombre haute pour décoller la barre du contenu — donne
        // l'effet « plateau flottant » premium plutôt qu'un simple trait.
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
        border: const Border(
          top: BorderSide(
            color: AppColors.border,
            width: AppDimens.borderThin,
          ),
        ),
      ),
      // SafeArea bottom — sans ça, sur iPhone avec home indicator, le
      // bouton est collé au bord inférieur (pas de respiration, et la
      // zone de tap déborde sur le swipe-home).
      child: SafeArea(
        top: false,
        minimum: const EdgeInsets.only(bottom: 8),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
          // CTA principal : QR d'enlèvement (statut ACCEPTED). C'est le
          // déclencheur du flow — montrer ce QR au transporteur qui
          // arrive. Pas de "Confirmer" à taper côté producteur : le
          // scan transporteur fait tout. Sur les autres statuts on
          // affiche "Marquer expédiée" comme avant (fallback manuel
          // si le QR ne passe pas).
          if (_canShowQr)
            SizedBox(
              width: double.infinity,
              child: Material(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(14),
                elevation: 0,
                child: InkWell(
                  onTap: () => context.push(
                    RouteNames.producteurCommandeEnlevementQrPathFor(
                      widget.commande.id,
                    ),
                  ),
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    height: 56,
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.qr_code_2_rounded,
                          size: 22,
                          color: AppColors.onPrimary,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Voir mon QR d\'enlèvement',
                          style: AppTextStyles.button.copyWith(
                            fontSize: 15,
                            color: AppColors.onPrimary,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            )
          else
            SizedBox(
              width: double.infinity,
              child: Opacity(
                opacity: shipEnabled ? 1 : 0.5,
                child: Material(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(14),
                  child: InkWell(
                    onTap: shipEnabled ? _markShipped : null,
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      height: 56,
                      alignment: Alignment.center,
                      child: _busy
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.white,
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.local_shipping_outlined,
                                  size: 20,
                                  color: AppColors.onPrimary,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  shipEnabled
                                      ? 'Marquer comme expédiée'
                                      : 'Déjà expédiée',
                                  style: AppTextStyles.button.copyWith(
                                    fontSize: 15,
                                    color: AppColors.onPrimary,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                ),
              ),
            ),
          // « Signaler un problème » : visible tant que la commande est
          // active et que l'escrow n'a pas été libéré. C'est le dernier
          // recours du producteur (acheteur disparaît / refuse la
          // livraison sans raison / etc.). Au-delà de COMPLETED, il faut
          // passer par le support — on retire le bouton ici pour éviter
          // les doublons admin.
          if (_signalerVisible(widget.commande)) ...[
            const SizedBox(height: 4),
            TextButton.icon(
              onPressed: () async {
                final result = await context.push<bool>(
                  RouteNames.signalerProblemePathFor(widget.commande.id),
                );
                // Litige créé → on demande au parent de rafraîchir le
                // provider (`onAfterShipped` est aussi utilisé pour ça
                // — il est branché sur `ref.invalidate(_commandeProvider)`
                // côté page parente). Effet : statut DISPUTED s'affiche
                // immédiatement, les autres actions sont masquées.
                if (result == true) widget.onAfterShipped();
              },
              icon: const Icon(
                Icons.flag_outlined,
                size: 16,
                color: AppColors.error,
              ),
              label: Text(
                'Signaler un problème',
                style: AppTextStyles.bodySmall.copyWith(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.error,
                ),
              ),
            ),
          ],
        ],
      ),
        ),
      ),
    );
  }

  /// Bouton « Signaler un problème » : visible uniquement quand le
  /// backend autorise l'ouverture d'un litige — c.-à-d. statuts
  /// `IN_PROGRESS` ou `DELIVERED`. Sur les autres statuts on cache le
  /// lien pour ne pas tenter l'utilisateur avec une action qui
  /// renverra 400.
  bool _signalerVisible(Commande c) => peutOuvrirLitige(c.status);
}
