import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../models/annonce_vente.dart';
import '../../../../models/commande.dart';
import '../../../../models/enums.dart';
import '../../../../models/livraison.dart';
import '../../../../routing/route_names.dart';
import '../../../../services/providers.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../widgets/acheteur/commandes/bandeau_info_livraison_qr.dart';
import '../../../widgets/acheteur/commandes/carte_qr_livraison.dart';
import '../../../widgets/acheteur/commandes/header_livraison_qr.dart';
import '../../../widgets/acheteur/commandes/lien_signaler_livraison.dart';
import '../../../widgets/acheteur/commandes/mini_recap_livraison_qr.dart';
import '../../../widgets/communs/chargement.dart';
import '../../../widgets/communs/vue_erreur.dart';

// ─── Provider ─────────────────────────────────────────────────────────

class _LivraisonBundle {
  const _LivraisonBundle({
    required this.commande,
    required this.qrToken,
    this.annonce,
    this.shipment,
  });
  final Commande commande;
  final AnnonceVente? annonce;
  final Livraison? shipment;

  /// Token signé HMAC à encoder dans le QR. Null tant que le backend
  /// n'a pas pu en générer un (statut shipment hors fenêtre LOADING/
  /// IN_TRANSIT, ou échec réseau) — on retombe sur l'ID commande.
  final String? qrToken;
}

final _livraisonBundleProvider = FutureProvider.autoDispose
    .family<_LivraisonBundle, String>((ref, id) async {
  final cmd = await ref.read(ordersServiceProvider).getOrder(id);

  // 1. Annonce (pour le mini récap : produit + photo).
  // `annonceId` est nullable — pour les commandes issues d'une
  // proposition (négociation), il n'y a pas d'annonce de vente source.
  AnnonceVente? annonce;
  final annonceId = cmd.annonceId;
  if (annonceId != null && annonceId.isNotEmpty) {
    try {
      annonce = await ref
          .read(marketplaceServiceProvider)
          .getAnnonceVente(annonceId);
    } catch (_) {}
  }

  // 2. Shipment associé — sert à générer le delivery QR token signé.
  //    Si la commande n'a pas encore de shipment (statut sent/accepted)
  //    on retombe gracieusement sur un QR sans token (mode dégradé).
  //    Le service retourne `null` directement quand pas de shipment.
  String? qrToken;
  final Livraison? shipment = await ref
      .read(logisticsServiceProvider)
      .getShipmentByCommande(cmd.id);

  // 3. Si shipment LOADING/IN_TRANSIT, on génère le QR token signé.
  if (shipment != null &&
      (shipment.status == ShipmentStatus.loading ||
          shipment.status == ShipmentStatus.inTransit)) {
    try {
      final tokenObj = await ref
          .read(logisticsServiceProvider)
          .generateDeliveryQrToken(shipment.id);
      qrToken = tokenObj.token;
    } catch (_) {
      // Token non récupéré — on continue avec un QR informatif sans
      // token. Le transporteur ne pourra pas valider le scan, l'acheteur
      // devra confirmer manuellement comme avant. Pas un crash.
      qrToken = null;
    }
  }

  return _LivraisonBundle(
    commande: cmd,
    annonce: annonce,
    shipment: shipment,
    qrToken: qrToken,
  );
});

/// QR de réception acheteur — à montrer au transporteur à la livraison.
///
/// Le QR encode un **token signé** (HMAC-SHA256, TTL 15 min) côté backend
/// dès que le shipment est en route. Le transporteur le scanne pour
/// déclencher automatiquement DELIVERED + libération escrow TRANSPORT.
///
/// Mode dégradé : si le shipment n'existe pas encore ou si la génération
/// du token échoue, on affiche un QR informatif (commande_id seulement)
/// et l'acheteur peut toujours "Confirmer la réception" manuellement.
class LivraisonQrPage extends ConsumerWidget {
  const LivraisonQrPage({required this.commandeId, super.key});

  final String commandeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(_livraisonBundleProvider(commandeId));
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: async.when(
          loading: () => const Column(
            children: [
              HeaderLivraisonQr(),
              Expanded(child: Chargement(size: 22)),
            ],
          ),
          error: (e, _) => Column(
            children: [
              const HeaderLivraisonQr(),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(AppDimens.pagePaddingH),
                  child: VueErreur(
                    message: 'Impossible de charger la commande. $e',
                    onRetry: () =>
                        ref.invalidate(_livraisonBundleProvider(commandeId)),
                  ),
                ),
              ),
            ],
          ),
          data: (bundle) => _build(context, bundle),
        ),
      ),
    );
  }

  Widget _build(BuildContext context, _LivraisonBundle bundle) {
    final c = bundle.commande;
    final codeCourt = c.id.substring(0, 6).toUpperCase();
    // Payload du QR : si on a un token signé, c'est lui qui est encodé
    // (le transporteur extrait le token en scannant). Sinon mode dégradé
    // avec juste l'ID commande pour info.
    final qrPayload = bundle.qrToken != null
        ? 'farmcash://delivery/${bundle.shipment?.id}?token=${bundle.qrToken}'
        : 'farmcash://commande/${c.id}?ref=$codeCourt';

    return Column(
      children: [
        const HeaderLivraisonQr(),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
            children: [
              const BandeauInfoLivraisonQr(),
              const SizedBox(height: 18),
              CarteQrLivraison(
                payload: qrPayload,
                commandeRef: codeCourt,
              ),
              const SizedBox(height: 14),
              MiniRecapLivraisonQr(commande: c, annonce: bundle.annonce),
              const SizedBox(height: 8),
              LienSignalerLivraison(
                onTap: () => context.push(
                  RouteNames.signalerProblemePathFor(c.id),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
